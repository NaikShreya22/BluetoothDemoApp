//
//  ViewController.swift
//  BLEDemoApp
//
//  Created by Shreya Naik on 11/08/23.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var switchBtn:UISwitch!
    
    var ble = Ble.shared
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ble.delegate = self
        switchBtn.isOn = true
        myTableView.delegate = self
        myTableView.dataSource = self
        
      
   }
//    override func viewWillAppear(_ animated: Bool) {
//        guard let connectPer =  UserDefaults.standard.data(forKey: "connected.Perpherials") else { return }
//        do {
//              let decoder = JSONDecoder()
//            let loadedPeripheral = try decoder.decode(Peripheral.self, from: connectPer)
//
//              // Now you can use the loadedPeripheral object
//              print("Loaded Peripheral Name: \(loadedPeripheral.name)")
//              print("Loaded Peripheral Identifier: \(loadedPeripheral.identifier)")
//          } catch {
//              print("Error decoding peripheral information: \(error)")
//          }
//    }
    @IBAction func switchButton(_ sender: UISwitch){
        if (sender.isOn == true){
                print("on")
            ble.scanForDevices()
            myTableView.reloadData()
            }
            else{
                ble.manager.stopScan()
                print("off")
                
            }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ble.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "BleTableViewCell", for: indexPath) as! BleTableViewCell
        let peripheral = ble.peripherals[indexPath.row]
        cell.deviceNameLabel?.text = peripheral.name
        
        guard let centralManager = ble.manager, centralManager.state == .poweredOn else{
            return cell
        }
        for newPeriperal in  ble.peripherals {
            if newPeriperal.state == .disconnected{
                cell.connectBtn.setTitle("Connect", for: .normal)
            }else{
                cell.connectBtn.setTitle("Disconnect", for: .normal)
            }
        }
        
        cell.connectBtn.addTarget(self, action: #selector(deviceConnection), for: .touchUpInside)
        cell.connectBtn.tag = indexPath.row
        return cell
    }
    
    @objc func deviceConnection(_ sender: UIButton){
        print(sender.tag)
        let selectedPeripheral = ble.peripherals[sender.tag]
        ble.connect(to: selectedPeripheral)
        myTableView.reloadData()
        
    }
    
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeripheral = ble.peripherals[indexPath.row]
        if connectionSuccess(selectedPeripheral){
            let vc = storyboard?.instantiateViewController(withIdentifier: "DeviceInfoViewController") as! DeviceInfoViewController
            ble.connectedPeripheral = selectedPeripheral
             self.navigationController?.pushViewController(vc, animated: true)
        }else{
            print("not Connected")
        }
        myTableView.deselectRow(at: indexPath, animated: true)
        

    }
}


extension ViewController:BLEDelegate{
    func connectionSuccess(_ peripheral: CBPeripheral) -> Bool {
        guard let centralManager = ble.manager, centralManager.state == .poweredOn else{
            return false
        }
        if deviceStatusCheck(peripheral){
            return true
        }else{
            return false
        }
    }
    func deviceStatusCheck(_ peripheral: CBPeripheral) -> Bool{
        switch peripheral.state{
            
        case .disconnected:
            print("Disconnected")
        case .connecting:
            print("connecting")
        case .connected:
          return true
        case .disconnecting:
            print("disconnecting")
        @unknown default:
            print("error")
        }
        return false
    }
    
    func didDiscoverPeripheral(_ peripheral: [CBPeripheral]) {
        if ble.isScanning{
            myTableView.reloadData()
        }
    }
    func isPheripheralConnected(_ peripheral: CBPeripheral) -> Bool {
        guard let centralManager = ble.manager, centralManager.state == .poweredOn else{
            return false
        }
        for connectedPeripherals in centralManager.retrieveConnectedPeripherals(withServices: []){
            if connectedPeripherals.identifier == peripheral.identifier{
                return true
            }
        }
        return false
    }
    
    
}
