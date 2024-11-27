//
//  File.swift
//  
//
//  Created by SeanHuang on 4/12/24.
//
import CoreBluetooth
import Foundation
import Combine
import CoreMotion

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
    var connectedPeripheral : CBPeripheral?
    var writableChar : CBCharacteristic?
    @Published public var connected =  false
    @Published public var scanning = false
    @Published var timeRemaining = Int.scanTime
    @Published public var gyroData = ""
    var musicReceiver =  MusicReceiver()
    //Cancellable .cancel will eliminate/deinit to null.
    private var discoverTimer : AnyCancellable?
    private var connectTimer : AnyCancellable?
    
    #if !os(macOS)
    private var motionManager : CMMotionManager?
    #endif

    
    
    //private var eventQ :[BltState] =  []
    
    override public init(){
        super.init()
        
        self.central = CBCentral(delegate: self, queue: .main)//have to setup self first so CBCentralManager is init after
        self.resetTimer()
        print("CBCentral finished init")
        print("CBCentral state \(self.central!.state)")
        central = CBCentralManager(delegate: self, queue: .main)
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
            central!.scanForPeripherals(withServices: [CBUUID.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    public func onPeripheralClicked(Peripheral per : CBPeripheral){
        if central!.state == .poweredOn {
            central!.connect(per);
            print("Attempting to connect to peripheral: \(per)")
            
        }
        
    }
    
}

extension CBluetoothCentralVM{

    
}


//Inherieted to implemnt timers
//CBCentralManager use for CBUUID:(...) service
class CBCentral : CBCentralManager{
    init(delegate : CBCentralManagerDelegate, queue : DispatchQueue){
        super.init(delegate: delegate , queue: queue,options: nil)
    }
}

// data
extension CBluetoothCentralVM{
       func encodeBatch(dataPoints: [(Double, Double, Double)]) -> Data {
        var data = Data()
        
        for (x, y, z) in dataPoints {
            // Convert to Float
            var xFloat = Float(x)
            var yFloat = Float(y)
            var zFloat = Float(z)
            
            // Append to Data
            data.append(UnsafeBufferPointer(start: &xFloat, count: 1))
            data.append(UnsafeBufferPointer(start: &yFloat, count: 1))
            data.append(UnsafeBufferPointer(start: &zFloat, count: 1))
        }
        
        return data
    }
    
    func sendDataInChunks(data: Data, for characteristic: CBCharacteristic) {
        let mtu = peripherials[0].maximumWriteValueLength(for: .withoutResponse)
        var offset = 0

        while offset < data.count {
            let chunkSize = min(mtu, data.count - offset)
            let chunk = data.subdata(in: offset..<(offset + chunkSize))
            //print("sent \(chunk)")
            
            // Send the chunk
            if let peripheral = connectedPeripheral{
                peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
                offset += chunkSize
            }
        }
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
            print("Discovered peripheral: \(peripheral)")
        }
    }
    
    //Good for debug
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(peripheral) \n error: \(error?.localizedDescription ?? "")")
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected and trying to discover services for:\(peripheral)")
        self.connected = true
        peripheral.delegate = self
        connectedPeripheral = peripheral
        connectedPeripheral?.discoverServices(nil)  // Passing nil discovers all services
        #if !os(macOS)
        setupMotionUpdates()
        #endif
        //Timer to disconnect after action
    }
    #if !os(macOS)

    func setupMotionUpdates() {
        motionManager  = CMMotionManager()

        // Check if device motion is available
        if motionManager!.isDeviceMotionAvailable {
            // Set the update interval
            motionManager!.deviceMotionUpdateInterval = 0.1

            // Start device motion updates and define the handler inline
            let backgroundQueue = OperationQueue()
            backgroundQueue.qualityOfService = .utility// Set an appropriate quality of service

            motionManager!.startDeviceMotionUpdates(to: backgroundQueue) { [weak self] data, error in
                guard let self = self else { return }
                
                // Check for errors
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                // Safely unwrap the motion data
                if let data = data {
                    // Handle the device motion data
                    let x = (data.rotationRate.x * 1000).rounded() / 1000
                    let y = (data.rotationRate.y * 1000).rounded() / 1000
                    let z = (data.rotationRate.z * 1000).rounded() / 1000
                    //print("rotation data \(x), \(y) \(z)\n")
                    let batchedData = encodeBatch(dataPoints: [(x,y,z)])
                    if let writableChar = self.writableChar {
                        sendDataInChunks(data: batchedData, for: writableChar)
                    }
                    //update to the RaveMac
                    
                    //update to the main thread
                    DispatchQueue.main.async {
                        self.gyroData = ("x: \(x), y: \(y), z: \(z)")
                    }
                    // Example: Update your UI or perform calculations
                }
            }
        } else {
            print("Device Motion is not available.")
        }
    }
    
#endif

    
}

//after a peripheral is found, we need to find its containted services, and the characteristics of each
//it's not like you can have a function get called on central whenever there is an incoming signal for any of the current connected peripheral
//each peripheral has to be encapsulated and then they will call the delegate fucntion provided by central

extension CBluetoothCentralVM : CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service.uuid)")
                // You can now discover characteristics for this service
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
        }
    }

    //to retreive all the charactersitcs discovered in a peripheral
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        if let characteristics = service.characteristics {
            print(type(of: characteristics))
            print("characteristics:",characteristics)
            
            for characteristic in characteristics {
//                print("Discovered characteristic: \(characteristic.uuid)")
//                // You can now read, write, or subscribe to the characteristic
                if isCharacteristicWritable(characteristic){
                    writableChar = characteristic
                    print("writable characteristic: \(characteristic.uuid)")
                }else{
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func isCharacteristicWritable(_ characteristic: CBCharacteristic) -> Bool {
        // Check if the characteristic supports writing (with or without response)
        let properties = characteristic.properties
        return properties.contains(.write) || properties.contains(.writeWithoutResponse)
    }
    
    //For printing readable discovered characteristic of a connected peripheral
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }

        // Check which characteristic was updated
        if characteristic.uuid == CBUUID(string: "2A29") {  // Manufacturer Name String
            if let value = characteristic.value, let manufacturerName = String(data: value, encoding: .utf8) {
                print("Manufacturer Name: \(manufacturerName)")
            }
        } else if characteristic.uuid == CBUUID(string: "2A24") {  // Model Number String
            if let value = characteristic.value, let modelNumber = String(data: value, encoding: .utf8) {
                print("Model Number: \(modelNumber)")
            }
        }
    }
}
