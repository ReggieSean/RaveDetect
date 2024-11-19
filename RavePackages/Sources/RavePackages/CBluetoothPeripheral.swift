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
        print("\(peripheral.description) started adevertising")
        if let err = error {
            print("Peripheral advertising error: ",err.localizedDescription)
        }
    }
    private func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central \(central) connected and subscribed to characteristic \(characteristic.uuid)")
        // Handle the central's connection, e.g., prepare data to send
    }
    
   
//     CBPeripheralManagerDelegate method to handle central connections

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
            for request in requests {
                print(request.characteristic)
                if request.characteristic == CBUUID.ultra2{
                    // Handle the incoming data
                    if let data = request.value {
                        print("Received data from central: \(data)")
                        // Process the data as needed
                        // Respond to the write request
                        peripheral.respond(to: request, withResult: .success)
                    } else {
                        // Respond with an error if the data is not valid
                        peripheral.respond(to: request, withResult: .invalidAttributeValueLength)
                    }
                }
            }
        }

}

//Service Class / Partial ViewModel to handle peripherial's blt events and UI events
@available(iOS 17,macOS 14, *)
@available(watchOS, unavailable)//at the time being watchOS does not support Peripherial mode
public class CBluetoothPeripherialVM : NSObject, ObservableObject{
    private var peripheral : CBPeripheralManager!
    @Published public var textOnScreen = "This is a joke"
    @Published public var  connected =  false
    @Published public var  advertising = false
    
    var  timer : Cancellable?
    @Published public var timeRemaining : Int = Int.adTime
  
    public override init() {
        super.init()
        self.peripheral = CBPeripheralManager(delegate: self, queue: .main)
        resetTimer()
    }
    
    private func cancelAdvertising(){
        timer?.cancel()
        advertising = false
        peripheral.stopAdvertising()
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
        if(peripheral.state == .poweredOn){
            self.advertising = true
            
            let advertisingData: [String: Any] = [
                CBAdvertisementDataServiceUUIDsKey: [CBUUID.serivceUUID],
                CBAdvertisementDataLocalNameKey: "Rave Peripheral"
            ]
            peripheral.startAdvertising(advertisingData)
            //print(peripheral?.value(forKey: .serivceUUID) ?? "null")
        }
    }
}




