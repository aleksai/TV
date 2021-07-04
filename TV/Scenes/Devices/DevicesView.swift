//
//  DevicesView.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI

struct DevicesView: View {
    
    @ObservedObject public var viewModel: DevicesViewModel = DevicesViewModelImpl()
    
    var body: some View {
        VStack {
            Text("Devices")
                .font(.title)

            HStack(spacing: 20) {
                if viewModel.devices.isEmpty {
                    VStack(spacing: 10) {
                        Text(viewModel.searching ? "Searching..." : "Nothing is found in your network")
                            .font(.caption)
                    }
                    .frame(height: 210)
                } else {
                    ForEach(viewModel.devices, id: \.id) { device in
                        NavigationLink(destination: FoldersView(viewModel: FoldersViewModelImpl(device: device.device, objectID: nil, name: device.name))) {
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
