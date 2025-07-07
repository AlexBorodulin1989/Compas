//
//  ContentViewModel.swift
//  ModelLoader
//
//  Created by Aleksandr Borodulin on 19.06.2025.
//

import Foundation
import MathLibrary
import ModelLoader

class ContentViewModel: ObservableObject {
    
    init() {
        Task {
            let filename = "direction_arrow"
            
            guard let file = Bundle.main.url(forResource: filename, withExtension: "obj")
            else {
                fatalError("Could not find \(filename) in main bundle.")
            }
            
            let modelLoader = await ModelLoader(fileUrl: file)
            
            print("Vertices:")
            print(modelLoader.vertices)
            
            print("Indices:")
            print(modelLoader.indices)
        }
    }
}
