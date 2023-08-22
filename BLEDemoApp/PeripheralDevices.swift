//
//  PeripheralDevices.swift
//  BLEDemoApp
//
//  Created by Shreya Naik on 18/08/23.
//

import Foundation
import CoreBluetooth

//class Peripheral: Codable {
//    let name: String?
//    let identifier:UUID?
//  //  let connected:CBPeripheralState?
//
//    private enum CodingKeys: String, CodingKey {
//        case name
//        case identifier
//        case connected
//    }
//
//    init(name: String?, identifier: UUID?) {
//        self.name = name
//        self.identifier = identifier
//       // self.connected = connected
//    }
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(identifier, forKey: .identifier)
//   
//      
//    }
//
//
//    required init(from decoder:Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        name = try values.decode(String.self, forKey: .name)
//        identifier = try values.decode(UUID.self, forKey: .identifier)
//        //connected = try values.rawValue.decode(CBPeripheralState.self, forKey: .connected)
//
//    }
//}


public class DeviceInfo{
    public var serviceId: String = "00002760-08C2-11E1-9073-0E8AC72E2000"
    public var charId3: String = "00002760-08C2-11E1-9073-0E8AC72E2014"
}

public class ServiceInfo:NSObject {
    public var service: CBService
    public var characteristics: [CBCharacteristic]?
    init(_ service:CBService, characters:[CBCharacteristic]?) {
        self.service = service
        self.characteristics = characters
    }
}
