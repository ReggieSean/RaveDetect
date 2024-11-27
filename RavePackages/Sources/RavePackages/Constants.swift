//
//  File.swift
//  
//
//  Created by SeanHuang on 4/4/24.
//

import Foundation
import CoreBluetooth

extension String{
    static var serviceUUID : String = "5c9d2c64-e2b3-4d1c-926f-3a1a6a6f23a3"
    static let charUUID : String = "7f1dde80-f0f0-487e-a70d-ebd2f34f9fa7"
    static let ultra2Char : String = "AF0BADB1-5B99-43CD-917A-A77BC549E3CC"
}

extension Int{
    static let adTime : Int = 30
    static let scanTime : Int = 60
}

extension CBUUID{
    static let serviceUUID : CBUUID = CBUUID(string: .serviceUUID)
    static let charUUID : CBUUID = CBUUID(string: .charUUID)
    static let ultra2 :CBUUID = CBUUID(string: .ultra2Char)
}


