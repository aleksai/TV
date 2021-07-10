//
//  DevicesView.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI
import CocoaUPnP

struct DevicesView: View {
    
    @ObservedObject public var viewModel: DevicesViewModel = DevicesViewModelImpl()
    
    @State var device: UPPBasicDevice!
    @State var name: String!
    @State var active = false
    
    var body: some View {
        VStack {
            Text("Devices")
                .font(.title)
            
            NavigationLink(destination: NavigationLazyView(FoldersView(viewModel: FoldersViewModelImpl(device: device, objectID: nil, name: name))), isActive: $active) {
                EmptyView()
            }
            .hidden()

            HStack(spacing: 20) {
                if viewModel.devices.isEmpty {
                    VStack(spacing: 10) {
                        Text(viewModel.searching ? "Searching..." : "Nothing is found in your network")
                            .font(.caption)
                    }
                    .frame(height: 210)
                } else {
                    ForEach(viewModel.devices, id: \.id) { device in
                        NavigationLink(destination: NavigationLazyView(FoldersView(viewModel: FoldersViewModelImpl(device: device.device, objectID: nil, name: device.name)))) {
                            VStack(spacing: 10) {
                                Text(device.name)
                                    .font(.title3)
                                Text(device.url.host ?? "")
                                    .font(.caption)
                            }
                            .frame(width: 300, height: 130)
                            .padding()
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                }
            }
        }
        .onAppear {
            viewModel.savedDevice = { _device, _name in
                device = _device
                name = _name
                active = true
            }
            
            viewModel.startDiscovery()
        }
    }
    
}

struct DevicesView_Preview: PreviewProvider {
    static var previews: some View {
        DevicesView(viewModel: DevicesViewModel())
    }
}

struct DevicesView_Preview_Empty: PreviewProvider {
    static var previews: some View {
        let viewModel = DevicesViewModel()
        viewModel.devices = []
        
        return DevicesView(viewModel: viewModel)
    }
}
