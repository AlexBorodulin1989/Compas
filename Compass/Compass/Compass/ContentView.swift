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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
