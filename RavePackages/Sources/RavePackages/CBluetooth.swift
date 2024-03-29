//
//  File.swift
//  
//
//  Created by SeanHuang on 3/26/24.
//

import CoreBluetooth
import Foundation

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
class CBluetoothCentral : NSObject, ObservableObject{
    private var central : CBCentralManager?
    @Published var connectedPeripherials: [CBPeripheral] = []
    @Published var  connected =  false
    //private var eventQ :[BltState] =  []
    override init(){
        super.init()
        self.central = CBCentralManager(delegate: self, queue: .main)
    }
}



extension CBluetoothCentral : CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            //Try to discover and set timer to stop trying
        } else{
           connectedPeripherials = []
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected:\(peripheral.identifier)")
        //Timer to disconnect after action
        
    }
    
}

//Service Class / Partial ViewModel to handle peripherial's blt events and UI events
class CBluetoothPeripherial : NSObject, ObservableObject{
    
}



