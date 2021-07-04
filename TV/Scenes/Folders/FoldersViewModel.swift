//
//  FoldersViewModel.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI
import CocoaUPnP

public class FoldersViewModel: NSObject, ObservableObject {
    
    struct FolderItem {
        let id: String
        
        let name: String
        let type: String
        let duration: String?
        
        let resources: [UPPMediaItemResource]
        let metadata: String?
    }
    
    var device: UPPBasicDevice?
    
    @Published var items: [FolderItem] = [
        FolderItem(id: "1", name: "Music", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "2", name: "Photos", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "3", name: "Videos", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "4", name: "Music", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "5", name: "Photos", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "6", name: "Videos", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "7", name: "Music", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "8", name: "Photos", type: "folder", duration: nil, resources: [], metadata: nil),
        FolderItem(id: "9", name: "Videos", type: "folder", duration: nil, resources: [], metadata: nil)
    ]
    
    @Published var title: String = ""
    
    func stopDiscovery() {}
    
}

final class FoldersViewModelImpl: FoldersViewModel {
    
    init(device: UPPBasicDevice?, objectID: String?, name: String?) {
        super.init()
        
        self.device = device
        
        items = []
        title = name ?? ""
        
        (device as? UPPMediaServerDevice)?.contentDirectoryService().browse(withObjectID: objectID, browseFlag: "BrowseDirectChildren", filter: nil, startingIndex: nil, requestedCount: nil, sortCritera: nil, completion: { response, _ in
            if let result = response?["Result"] as? [UPPMediaItem] {
                self.items = result.map { FolderItem(id: $0.objectID, name: $0.itemTitle, type: $0.isContainer ? "folder" : "file", duration: $0.duration(), resources: $0.resources ?? [], metadata: UPPMetadataForItem($0)) }
            }
        })
    }
    
    override func stopDiscovery() {
        UPPDiscovery.sharedInstance().stopBrowsingForServices()
    }
    
}
