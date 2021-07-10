//
//  DevicesViewModel.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI
import CocoaUPnP

public class DevicesViewModel: NSObject, ObservableObject {
    
    struct Device {
        let id: String
        
        let name: String
        let type: String
        let url: URL
        
        let device: UPPBasicDevice?
    }
    
    @Published var devices: [Device] = [
        Device(id: "1", name: "Raspberry Pi", type: "urn:schemas-upnp-org:device:MediaServer:1", url: URL(string: "http://192.168.1.200:9500/rootDesc.xml")!, device: nil),
        Device(id: "2", name: "Plex", type: "urn:schemas-upnp-org:device:MediaServer:1", url: URL(string: "http://192.168.1.300:9500/rootDesc.xml")!, device: nil),
        Device(id: "3", name: "Music", type: "urn:schemas-upnp-org:device:MediaServer:1", url: URL(string: "http://192.168.1.400:9500/rootDesc.xml")!, device: nil)
    ]
    
    @Published var searching = false
    
    var savedDevice: ((UPPBasicDevice, String) -> ())?
    
    func startDiscovery() {}
    
}

final class DevicesViewModelImpl: DevicesViewModel {

    override init() {
        super.init()
        
        devices = []
        searching = true
        
        UPPDiscovery.sharedInstance().addBrowserObserver(self)
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(10), repeats: false, block: { _ in
            if self.devices.isEmpty { self.searching = false }
        })
    }
    
    override func startDiscovery() {
        if let urn = UserDefaults.standard.string(forKey: "device-urn"),
           let url = URL(string: UserDefaults.standard.string(forKey: "device-url") ?? ""),
           let name = UserDefaults.standard.string(forKey: "device-name") {
            let device = UPPBasicDevice(urn: urn, baseURL: url)
            
            print(device.urn)
            
            savedDevice?(device, name)
        } else {
            UPPDiscovery.sharedInstance().startBrowsing(forServices: "ssdp:all")
        }
    }
    
}

extension DevicesViewModelImpl: UPPDiscoveryDelegate {
    
    func discovery(_ discovery: UPPDiscovery, didFind device: UPPBasicDevice) {
        if device.isKind(of: UPPMediaServerDevice.self) {
            devices.append(Device(id: device.udn, name: device.friendlyName, type: device.deviceType, url: device.baseURL, device: device))
        }
    }
    
    func discovery(_ discovery: UPPDiscovery, didRemove device: UPPBasicDevice) {
        devices.removeAll(where: { $0.id == device.udn })
    }

}
