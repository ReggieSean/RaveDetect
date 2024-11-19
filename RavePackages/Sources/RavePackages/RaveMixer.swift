//
//  File.swift
//  
//
//  Created by SeanHuang on 11/11/24.
//

import Foundation

@available(watchOS, unavailable)//at the time being watchOS does not support Peripherial mode as CBPeripheralManager
class RaveMixer: ObservableObject{
    var bluetoothConnector : CBluetoothPeripherialVM
    var ipcManager : IPCManager
    
    public init(bluetoothConnector: CBluetoothPeripherialVM, ipcManager: IPCManager) {
        self.bluetoothConnector = bluetoothConnector
        self.ipcManager = ipcManager
    }
    
}
