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
    
    @Published var pause = false
    
}

final class PlayerViewModelImpl: PlayerViewModel {
    
    init(device: UPPBasicDevice?, resources: [UPPMediaItemResource], metadata: String?) {
        super.init()
        
        url = URL(string: resources.first?.resourceURLString ?? "")
        
        print(metadata)
    }
    
}
