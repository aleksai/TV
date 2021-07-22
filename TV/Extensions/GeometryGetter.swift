//
//  GeometryGetter.swift
//  TV
//
//  Created by Alek Sai on 14/07/2021.
//

import SwiftUI

struct GeometryGetter: View {
    
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { (g) -> Path in
            DispatchQueue.main.async {
                self.rect = g.frame(in: .global)
            }
            return Path()
        }
    }
    
}
