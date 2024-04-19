//
//  File.swift
//  
//
//  Created by SeanHuang on 4/12/24.
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
    //Cancellable .cancel will eliminate/deinit to null.
    private var discoverTimer : AnyCancellable?
    private var connectTimer : AnyCancellable?
    
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
            self.peripherials = []
            tryScan()
        }
        
    }
    
    private func resetTimer(){
        discoverTimer?.cancel()
        timeRemaining = Int.scanTime
        discoverTimer = Timer.publish(every: 1, on: .main , in: .common).autoconnect().receive(on: DispatchQueue.main).sink{[weak self]_ in
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
        discoverTimer?.cancel()
        scanning = false
        central?.stopScan()
        resetTimer()
    }
    
    public func tryScan(){
        if(central!.state == .poweredOn){
            self.scanning = true
            print("Trying to scan")
            central!.scanForPeripherals(withServices: [CBUUID.serivceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    public func onPeripheralClicked(Peripheral per : CBPeripheral){
        if let central = central{
            central.connect(per);
            self.connectTimer = Timer.publish(every: 1, on: .main, in: .common).receive(on: DispatchQueue.main).sink(receiveValue: {[weak self]_ in
            })
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
