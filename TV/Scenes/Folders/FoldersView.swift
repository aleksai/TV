//
//  FoldersView.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI

struct FoldersView: View {
    
    @ObservedObject public var viewModel: FoldersViewModel
    
    @State var playing = false
    @State var playingItem: FoldersViewModel.FolderItem?
    
    var columns: [GridItem] = Array(repeating: .init(.adaptive(minimum: 330, maximum: 330)), count: 4)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.title)
                    .font(.title)
                
                Spacer()
            }
            
            NavigationLink(destination: PlayerView(item: playingItem, playing: $playing), isActive: $playing) {
                EmptyView()
            }
            .hidden()
            
            HStack(spacing: 20) {
                if viewModel.items.isEmpty {
                    VStack(spacing: 10) {
                        Text("Nothing is found")
                            .font(.caption)
                    }
                    .frame(height: 210)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(viewModel.items, id: \.id) { item in
                                if item.type == "folder" {
                                    NavigationLink(destination: NavigationLazyView(FoldersView(viewModel: FoldersViewModelImpl(device: viewModel.device, objectID: item.id, name: item.name)))) {
                                        VStack(spacing: 10) {
                                            Text(item.name)
                                                .font(.title3)
                                        }
                                        .frame(width: 300, height: 130)
                                        .padding()
                                    }
                                    .buttonStyle(CardButtonStyle())
                                } else {
                                    Button(action: {
                                        playingItem = item
                                        
                                        playing = true
                                    }) {
                                        VStack(spacing: 10) {
                                            Text(item.name)
                                                .font(.body)
                                        }
                                        .frame(width: 300, height: 130)
                                        .padding()
                                    }
                                    .buttonStyle(CardButtonStyle())
                                }
                            }
                        }
                        .padding(50)
                    }
                    .padding(-50)
                }
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.stopDiscovery()
        }
    }
    
}

struct FoldersView_Preview: PreviewProvider {
    static var previews: some View {
        FoldersView(viewModel: FoldersViewModel())
    }
}

struct FoldersView_Preview_Empty: PreviewProvider {
    static var previews: some View {
        let viewModel = FoldersViewModel()
        viewModel.items = []
        
        return FoldersView(viewModel: viewModel)
    }
}
