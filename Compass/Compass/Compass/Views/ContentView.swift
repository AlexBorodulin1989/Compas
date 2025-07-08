//
//  ContentView.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import SwiftUI
import MijickCamera

struct ContentView: View {
    var body: some View {
        ZStack {
            MCamera()
                .startSession()
            MetalView()
            
        }
        
    }
}

#Preview {
    ContentView()
}
