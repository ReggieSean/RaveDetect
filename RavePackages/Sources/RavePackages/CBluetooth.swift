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
@available(macOS 10.15, *)
public class CBluetoothCentralVM : NSObject, ObservableObject{
    private var central : CBCentralManager?
    @Published public var connectedPeripherials: [CBPeripheral] = []
    @Published public var peripherials : [CBPeripheral] = []
    @Published var  connected =  false
    @Published var scanning = false
    //private var eventQ :[BltState] =  []
    override public init(){
        super.init()
        self.central = CBCentral(delegate: self, queue: .main)//have to setup self first so CBCentralManager is init after
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
    
    public func tryScan(){
        if(central!.state == .poweredOn && !central!.isScanning){
            print("Trying to scan")
            scanning = true
            central!.scanForPeripherals(withServices: [CBUUID.serivceUUID])
            var runCount = 0
            Timer.scheduledTimer(withTimeInterval: 30, repeats: false){[weak self] timer in
                self?.central!.stopScan()//delete all discovered peripherials
                self?.scanning = false
                
            }
        }
    }
    
    
}


//Inherieted to implemnt timers
//CBCentralManager use for CBUUID:(...) service
class CBCentral : CBCentralManager{
    init(delegate : CBCentralManagerDelegate, queue : DispatchQueue){
        super.init(delegate: delegate , queue: queue,options: [:])
    }
}


@available(macOS 10.15, *)
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
                tryScan()
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

//Service Class / Partial ViewModel to handle peripherial's blt events and UI events
@available(macOS 10.15, *)
public class CBluetoothPeripherialVM : NSObject, ObservableObject{
    private var peripheral : CBPeripheralManager?
    @Published public var  connected =  false
    @Published public var  advertising = false
    var  timer : Cancellable?
    @Published public var timeRemaining : Int = 30
  
    public override init() {
        super.init()
        resetTimer()
        self.peripheral = CBPeripheralManager(delegate: self, queue: .main)
    }
    
    public func cancelAdvertising(){
        timer?.cancel()
        advertising = false
        peripheral?.stopAdvertising()
        timeRemaining = 30
        resetTimer()
    }
    
    private func resetTimer(){
        timer = Timer.publish(every:1, on: .main, in: .common).autoconnect().receive(on: DispatchQueue.main).sink{[weak self]_ in
            if(self!.advertising){
                self!.timeRemaining = ((self!.timeRemaining - 1) + 30) % 30
                if(self!.timeRemaining == 0){
                    self!.cancelAdvertising()
                }
                print(self!.timeRemaining)
            }
        }
    }
    
   
    
    public func tryAdvertise(){
        if(peripheral!.state == .poweredOn && !peripheral!.isAdvertising){
            print("Trying to advertise")
            advertising = true
            peripheral?.startAdvertising([CBAdvertisementDataServiceUUIDsKey:CBUUID.serivceUUID])
        }
    }
}

@available(macOS 10.15, *)
extension CBluetoothPeripherialVM : CBPeripheralManagerDelegate{
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state{
                
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
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("\(peripheral.description) started adevertising" )
    }
    
}



