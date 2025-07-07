//
//  ContentView.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel = .init()
    var body: some View {
        MetalView()
    }
}

#Preview {
    ContentView()
}
