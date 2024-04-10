//
//  File.swift
//  
//
//  Created by SeanHuang on 4/4/24.
//

import Foundation
import CoreBluetooth

extension String{
    static var serivceUUID : String = "5c9d2c64-e2b3-4d1c-926f-3a1a6a6f23a3"
    static let charUUID : String = "7f1dde80-f0f0-487e-a70d-ebd2f34f9fa7"
}

extension Int{
    static let adTime : Int = 30
}

extension CBUUID{
    static let serivceUUID : CBUUID = CBUUID(string: .serivceUUID)
    static let charUUID : CBUUID = CBUUID(string: .charUUID)
}

