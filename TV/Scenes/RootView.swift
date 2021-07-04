//
//  RootView.swift
//  TV
//
//  Created by Alek Sai on 03/07/2021.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
            DevicesView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
