//
//  File.swift
//  
//
//  Created by SeanHuang on 3/26/24.
//

import CoreBluetooth
import Foundation
import Combine

//CoreBluetooth does not handle timeout by itself, it is developers' job
//to handle the events produced by CoreBluetooth framework
//1.Queue to handle actions

//Not Connected vs Connected
//2.Timer to time-out and stop discover bt device (race: stop vs final discovery, didDiscoverPeripherials)
//3.Timer to stop trying to connect to Peripherial
//4.Timer to disconnect after no action  period

//Action: connect -> discoverServices -> discoverCharactersitc -> readValue
//Event: read -> didConnect -> didDiscoverServices -> didDiscoverCharacteristic -> didReadValue


//Service Class / Partial ViewModel to handle central's blt events and UI events
@available(macOS 14, *)
public class CBluetoothCentralVM : NSObject, ObservableObject{
    private var central : CBCentralManager?
    @Published public var connectedPeripherials: [CBPeripheral] = []
    @Published public var peripherials : [CBPeripheral] = []
    @Published public var connected =  false
    @Published public var scanning = false
    @Published var timeRemaining = Int.scanTime
    private var timer : AnyCancellable?
    //private var eventQ :[BltState] =  []
    override public init(){
        super.init()
        self.central = CBCentral(delegate: self, queue: .main)//have to setup self first so CBCentralManager is init after
        self.resetTimer()
        print("CBCentral finished init")
        print("CBCentral state \(self.central!.state)")
    }
    
    
    
    func connectPeripherial(Index idx : Int){
        print("try connecting peripherial:\(idx) \(peripherials[idx].name!)")
        self.central!.connect(peripherials[idx])
        Timer.scheduledTimer(withTimeInterval: 30, repeats: false){[weak self] timer in
            if !(self!.connected){
                self!.central!.cancelPeripheralConnection((self?.peripherials[idx])!)
            }
        }
    }
    
    public func flipScanning(){
        if(scanning){
            print("Central cancelled scanning")
            cancelScanning()
        }else{
            print("Central starts scanning")
            tryScan()
        }
        
    }
    
    private func resetTimer(){
        timer?.cancel()
        timeRemaining = Int.scanTime
        timer = Timer.publish(every: 1, on: .main , in: .common).autoconnect().receive(on: DispatchQueue.main).sink{[weak self]_ in
            if(self!.scanning){
                print(self!.timeRemaining)
                self!.timeRemaining -= 1
                if(self!.timeRemaining <= 0){
                    self!.cancelScanning()
                }
            }
        }
    }
//    private func resetTimer(){
//        timer?.cancel()
//        timeRemaining = Int.adTime
//        timer = Timer.publish(every:1, on: .main, in: .common).autoconnect().receive(on: DispatchQueue.main).sink{[weak self]_ in
//            if(self!.advertising){
//                print(self!.timeRemaining)
//                self!.timeRemaining -= 1
//                if(self!.timeRemaining <= 0){
//                    self!.cancelAdvertising()
//                }
//            }
//        }
//    }
    
    private func cancelScanning(){
        timer?.cancel()
        scanning = false
        central?.stopScan()
        resetTimer()
    }
    
    public func tryScan(){
        if(central!.state == .poweredOn ){
            self.scanning = true
            print("Trying to scan")
            central!.scanForPeripherals(withServices: [CBUUID.serivceUUID], options: nil)
        }
    }
    
    
}


//Inherieted to implemnt timers
//CBCentralManager use for CBUUID:(...) service
class CBCentral : CBCentralManager{
    init(delegate : CBCentralManagerDelegate, queue : DispatchQueue){
        super.init(delegate: delegate , queue: queue,options: nil)
    }
}


@available(macOS 14, *)
extension CBluetoothCentralVM : CBCentralManagerDelegate{
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
                
            case .unknown:
                print("Central update to state unknown")
            case .resetting:
                print("Central update to state resetting")
            case .unsupported:
                print("Central update to state unsupported")
            case .unauthorized:
                print("Central update to state unauthorized")
            case .poweredOff:
                print("Central update to state poweredOff")
            case .poweredOn:
                print("Central update to state poweredOn")
            @unknown default:
                print("Central update to state default")
        }
        
    }
    
    
   public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherials.contains(peripheral){
            self.peripherials.append(peripheral)
            print("Discovered: \(peripheral)")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected:\(peripheral.identifier)")
        self.connected = true
        //Timer to disconnect after action
    }
    
}

@available(iOS 17,macOS 14, *)
@available(watchOS, unavailable)
extension CBluetoothPeripherialVM : CBPeripheralManagerDelegate{
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state{
                
            case .unknown:
                print("Peripherial update to state unknown")
            case .resetting:
                print("Peripherial update to state resetting")
            case .unsupported:
                print("Peripherial update to state unsupported")
            case .unauthorized:
                print("Peripherial update to state unauthorized")
            case .poweredOff:
                print("Peripherial update to state poweredOff")
            case .poweredOn:
                print("Peripherial update to state poweredOn")
                
            @unknown default:
                print("Peripherial update to state default")
        }
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("\(peripheral.description) started adevertising" )
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Peri Received requests")
        print(requests)
    }
    
}

//Service Class / Partial ViewModel to handle peripherial's blt events and UI events
@available(iOS 17,macOS 14, *)
@available(watchOS, unavailable)//at the time being watchOS does not support Peripherial mode
public class CBluetoothPeripherialVM : NSObject, ObservableObject{
    private var peripheral : CBPeripheralManager?
    @Published public var  connected =  false
    @Published public var  advertising = false
    var  timer : Cancellable?
    @Published public var timeRemaining : Int = Int.adTime
  
    public override init() {
        super.init()
        resetTimer()
        self.peripheral = CBPeripheralManager(delegate: self, queue: .main)
    }
    
    private func cancelAdvertising(){
        timer?.cancel()
        advertising = false
        peripheral?.stopAdvertising()
        resetTimer()
    }
    
    private func resetTimer(){
        timer?.cancel()
        timeRemaining = Int.adTime
        timer = Timer.publish(every:1, on: .main, in: .common).autoconnect().receive(on: DispatchQueue.main).sink{[weak self]_ in
            if(self!.advertising){
                print(self!.timeRemaining)
                self!.timeRemaining -= 1
                if(self!.timeRemaining <= 0){
                    self!.cancelAdvertising()
                }
            }
        }
    }
    
    public func flipAdvertising(){
        if self.advertising {
            print("Peri canceled advertising")
            cancelAdvertising()
        }else{
            print("Peri started advertising")
            tryAdvertising()
        }
    }
    
    private func tryAdvertising(){
        self.advertising = true
        if(peripheral!.state == .poweredOn){
            print("Trying to advertise")
            peripheral?.startAdvertising([CBAdvertisementDataServiceUUIDsKey:CBUUID.serivceUUID])
            print(peripheral?.value(forKey: .serivceUUID) ?? "null")
        }
}
}





