//
//  BLE.swift
//  BLEDemoApp
//
//  Created by Shreya Naik on 16/08/23.
//

import Foundation
import CoreBluetooth

protocol BLEDelegate: AnyObject{
    func didDiscoverPeripheral(_ peripheral: [CBPeripheral])
    func isPheripheralConnected(_ peripheral: CBPeripheral) -> Bool
    func connectionSuccess(_ peripheral: CBPeripheral)-> Bool
}

class Ble: NSObject{
    static let shared = Ble()
    var manager:CBCentralManager!
    var peripherals:[CBPeripheral] = []
    var connectedPeripheral:CBPeripheral!
    weak var delegate:BLEDelegate?
    var timer:Timer?
    var isScanning = false
    var serviceData = [String:[ServiceInfo]]()
    
    public override init() {
        super.init()
        self.manager = CBCentralManager.init(delegate: self, queue: nil)
        manager.delegate = self
    }
}

extension Ble{
    func scanForDevices() {
        manager.scanForPeripherals(withServices: nil, options: nil)
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(stopScanning), userInfo: nil, repeats: false)
        isScanning = true
        
    }
    func connect(to peripheral: CBPeripheral) {
        manager.connect(peripheral, options: nil)
    }
    @objc func stopScanning(){
        manager.stopScan()
        timer?.invalidate()
        isScanning = false
    }
}


extension Ble:CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("powered off")
        case .poweredOn:
            scanForDevices()
            print("powered on")
        @unknown default:
            print("Error!!!!")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else {
            return
            
        }
        if !peripherals.contains(peripheral) && isScanning{
            if peripheral.name!.contains("TITAN_90160_F5C9") {
                    peripherals.append(peripheral)
                    print("didDiscoverPerifpheral = \(peripheral.name!)")
                    delegate?.didDiscoverPeripheral(peripherals)
                }
            }
            
    }
    
}
extension Ble:CBPeripheralDelegate{
    
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let selectedDevice = peripheral
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        print(selectedDevice)
        delegate?.connectionSuccess(selectedDevice)
        peripheral.discoverServices(nil)
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        var serviceList = [ServiceInfo]()
        if let services = peripheral.services {
            //discover characteristics of services
            for service in services {
                serviceList.append(ServiceInfo(service, characters: nil))
                peripheral.discoverCharacteristics(nil, for: service)
            }
            serviceData[peripheral.identifier.uuidString] = serviceList
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else{
            return
        }
        guard let serviceList = serviceData[peripheral.identifier.uuidString] else{
            print("Error found",error!)
            return
        }
        for serviceObj in serviceList{
            if serviceObj.service == service{
                serviceObj.characteristics = service.characteristics
            }
        }
        for char in service.characteristics  ?? [CBCharacteristic]() {
                peripheral.setNotifyValue(true, for: char)

        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let bytesReceived = characteristic.value else {
            return
        }
        
        let responseString = bytesToHex(bytes: bytesReceived.array(), spacing: ", ")
        print("response time ----------- time-------> ======= ",Date().timeIntervalSince1970)
        print("-------> response: \(responseString)")
        //FOR ALEXA
        
    }
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
}
    

public func bytesToHex(bytes: [UInt8], spacing: String) -> String {
    var hexString: String = ""
    var count = bytes.count
    for byte in bytes
    {
        hexString.append(String(format:"%02X", byte))
        count = count - 1
        if count > 0
        {
            hexString.append(spacing)
        }
    }
    return hexString
}
extension Data {
    public func array() -> [UInt8] {
        return [UInt8](self)
    }
}
