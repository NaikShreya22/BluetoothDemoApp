//
//  DeviceInfoViewController.swift
//  BLEDemoApp
//
//  Created by Shreya Naik on 16/08/23.
//

import UIKit
import CoreBluetooth

class DeviceInfoViewController: UIViewController, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    
    @IBOutlet weak var label:UILabel!
    var bluetoothManager = Ble.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let deviceName =  bluetoothManager.connectedPeripheral {
            label.text = deviceName.name
        }
        
        
    }
    
    @IBAction func setDeviceTime(_ sender: UIButton) {
        let timeData = self.getDataFromUser(date: Date())
        self.sendWriteRequestCommand(identifier: [0x01,0x04], service: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000"), CharUUID: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014"), commnadData: timeData.bytes(), type: .withResponse, isNotifiyEnabled: true, peripheral: bluetoothManager.connectedPeripheral)
    }
    @IBAction func getBatteryPercentage(_ sender: UIButton) {
        self.sendWriteRequestCommand(identifier: [0x01,0x05], service: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000"), CharUUID: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014"), commnadData:[0x01,0x05], type: .withResponse, isNotifiyEnabled: true, peripheral: bluetoothManager.connectedPeripheral)
    }
    @IBAction func setUnitSystem(_ sender: UISwitch) {
        if sender.isOn{
            let unitsystem = setUnitSystem(isOn: true)
            self.sendWriteRequestCommand(identifier: [0x02,0x04], service: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000"), CharUUID: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014"), commnadData:unitsystem.bytes(), type: .withResponse, isNotifiyEnabled: true, peripheral: bluetoothManager.connectedPeripheral)
        }else{
            let unitsystem = setUnitSystem(isOn: false)
            self.sendWriteRequestCommand(identifier: [0x02,0x04], service: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000"), CharUUID: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014"), commnadData:unitsystem.bytes(), type: .withResponse, isNotifiyEnabled: true, peripheral: bluetoothManager.connectedPeripheral)
        }
        
    }
    @IBAction func setGoal(_ sender: UISegmentedControl) {
        var goalData = Data()
        var goalIdentifiy = [UInt8]()
        if sender.selectedSegmentIndex == 0{
           goalData = setGoalData(goalType: 0)
            goalIdentifiy = [0x05,0x02]
        }else if sender.selectedSegmentIndex == 1{
           goalData = setGoalData(goalType: 1)
            goalIdentifiy = [0x05,0x01]

        }else if sender.selectedSegmentIndex == 2{
            goalData = setGoalData(goalType: 2)
            goalIdentifiy = [0x05,0x05]

        }
      
        self.sendWriteRequestCommand(identifier: goalIdentifiy, service: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000"), CharUUID: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014"), commnadData: goalData.bytes(), type: .withResponse, isNotifiyEnabled: true, peripheral: bluetoothManager.connectedPeripheral)
    }
    @IBAction func findWatch(_ sender: UIButton) {
        self.sendWriteRequestCommand(identifier: [0x03,0x03], service: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000"), CharUUID: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014"), commnadData:[0x03,0x03], type: .withResponse, isNotifiyEnabled: true, peripheral: bluetoothManager.connectedPeripheral)
    }
    @IBAction func getUnitSystem(_ sender: UIButton) {
        let unitSystem = self.getUnitSystem()
        self.sendWriteRequestCommand(identifier: [0x02,0x03], service: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000"), CharUUID: CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014"), commnadData: unitSystem.bytes(), type: .withResponse, isNotifiyEnabled: true, peripheral: bluetoothManager.connectedPeripheral)
    }
    
    func convertNonsecondsTomilliseconds(seconds: Int) -> Int {
        let milliSconds = seconds / 1000
        return milliSconds
        
    }
    func getDataFromUser(date:Date) -> Data {
        var data : [UInt8] = [0x01,0x04]
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let second = calendar.component(.second, from: date)
        let minute = calendar.component(.minute, from: date)
        let hour = calendar.component(.hour, from: date)
        let milliseconds = convertNonsecondsTomilliseconds(seconds: second)
        
        let yearData = withUnsafeBytes(of: year) { Data($0) }
        let millsce = withUnsafeBytes(of: milliseconds) { Data($0) }
        data.append(UInt8(yearData[1])) //Year(lower order place in front)  -> 2 Bytes
        data.append(UInt8(yearData[0]))
        data.append(UInt8(month))
        data.append(UInt8(day))
        data.append(UInt8(hour))
        data.append(UInt8(minute))
        data.append(UInt8(second))
        data.append(UInt8(millsce[0])) //Year(lower order place in front)  -> 2 Bytes
        data.append(UInt8(millsce[1]))
        data.append(UInt8(0))
        
        var homeTimeZone = TimeZone.current.secondsFromGMT()
        if homeTimeZone > 0 {
            data.append(1)
        } else {
            data.append(0)
        }
        homeTimeZone = abs(homeTimeZone / 3600)
        
        let homeTimeHrAndMin = String(homeTimeZone)
        let hmHrAndMin = homeTimeHrAndMin.components(separatedBy: ".")
        
        let hr = hmHrAndMin.first ?? "0"
        data.append(UInt8(hr) ?? 0)
        
        let min = Int(hmHrAndMin.last ?? "0") ?? 0
        let offMin = Int(((min / 1) * 60)/10)
        data.append(UInt8(offMin))
        
        return Data(data)
    }
    func getUnitSystem() -> Data{
        var data : [UInt8] = [0x02,0x03]
        
        return Data(data)
    }
    func setUnitSystem(isOn:Bool) -> Data {
        var data : [UInt8] = [0x02,0x04]
        if isOn{ // metric, celcius
            data.append(UInt8(0)) // normal unit
            data.append(UInt8(0)) // temp unit
            data.append(UInt8(0)) // weather unit
        }else{ // imperial,farhenit
            data.append(UInt8(1)) // normal unit
            data.append(UInt8(1)) // temp unit
            data.append(UInt8(1)) // weather unit
        }
        return Data(data)
        
    }
    func setGoalData(goalType: Int) -> Data{
        var data = [UInt8]()
        switch goalType{
        case 0:
             data  = [0x05,0x02]
            let sleepData = withUnsafeBytes(of: 420) { Data($0) }
            data.append(UInt8(sleepData[3]))
            data.append(UInt8(sleepData[2]))
            data.append(UInt8(sleepData[1]))
            data.append(UInt8(sleepData[0]))
        case 1:
            data = [0x05,0x01]
            let stepData = withUnsafeBytes(of: 1000) { Data($0) }
            data.append(UInt8(stepData[3]))
            data.append(UInt8(stepData[2]))
            data.append(UInt8(stepData[1]))
            data.append(UInt8(stepData[0]))
        case 2:
           data  = [0x05,0x05]
            let caloriedata = withUnsafeBytes(of: 300) { Data($0) }
            data.append(UInt8(caloriedata[3]))
            data.append(UInt8(caloriedata[2]))
            data.append(UInt8(caloriedata[1]))
            data.append(UInt8(caloriedata[0]))
           
        default:
            print("not selected goal")
        }
        
        return Data(data)
    }
    func sendWriteRequestCommand(identifier:[UInt8], service: CBUUID, CharUUID: CBUUID, commnadData: [UInt8],type: CBCharacteristicWriteType,isNotifiyEnabled:Bool,peripheral:CBPeripheral){
        
        guard let serviceList = bluetoothManager.serviceData[peripheral.identifier.uuidString] else {
            print("Services Not Founds endWriteRequest")
            return
        }
        for serviceObjc in serviceList {
            if serviceObjc.service.uuid == service {
                if let characteristics = serviceObjc.characteristics{
                    for character in characteristics {
                        if character.uuid == CharUUID {
                            let data = Data(bytes: commnadData, count: commnadData.count)
                            bluetoothManager.connectedPeripheral.writeValue(data, for: character, type: .withResponse)
                            print("send write request: \(commnadData.bytesToHex()) ,serviceUUID ===== \(serviceObjc)")
                            debugPrint("send write request time ======= ",Date().timeIntervalSince1970)
                            return
                        }
                    }
                }
            }
        }
        
    }
    
}
extension Array where Element == UInt8 {
    func bytesToHex(spacing: String = "") -> String {
        
        var hexString: String = ""
        
        var count = self.count
        
        for byte in self {
            
            hexString.append(String(format:"%02X", byte))
            
            count = count - 1
            
            if count > 0 {
                
                hexString.append(spacing)
                
            }
            
        }
        
        return hexString
        
    }
}
extension Data {
    func bytes() -> [UInt8] {
        return self.map({ $0 })
    }
}
