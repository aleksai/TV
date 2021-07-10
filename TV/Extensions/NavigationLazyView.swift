//
//  NavigationLazyView.swift
//  TV
//
//  Created by Alek Sai on 10/07/2021.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
    
}
