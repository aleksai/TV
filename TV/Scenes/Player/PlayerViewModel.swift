//
//  PlayerViewModel.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI
import CocoaUPnP

public class PlayerViewModel: NSObject, ObservableObject {
    
    @Published var url: URL?
    @Published var name: String?
    
    @Published var pause = false
    
}

final class PlayerViewModelImpl: PlayerViewModel {
    
    init(item: FoldersViewModel.FolderItem?) {
        super.init()
        
        url = URL(string: item?.resources.first?.resourceURLString ?? "")
        name = item?.name
        
//        print(item?.metadata)
    }
    
}
