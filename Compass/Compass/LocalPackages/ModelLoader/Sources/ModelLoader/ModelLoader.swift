//
//  ModelLoader.swift
//  ModelLoader
//
//  Created by Aleksandr Borodulin on 20.06.2025.
//

import Foundation
import MathLibrary

public class ModelLoader {
    // Public properties
    public var vertices: [float3] { _vertices }
    public var indices: [UInt16] { _indices }
    
    // Private properties
    private var _vertices: [float3] = .init()
    private var _indices: [UInt16] = .init()
    private var maxAbsVertexPosValue: Float = 0
    
    public init(fileUrl: URL) async {
        do {
            let contents = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            
            let lines = contents.split(separator: "\n")
            
            lines.forEach { line in
                let separateValues = line.split(separator: " ")
                if separateValues.first == "v" && separateValues.count == 4 {
                    if let x = Float(separateValues[1]),
                       let y = Float(separateValues[2]),
                       let z = Float(separateValues[3]) {
                        let vertex = float3(z, x, y)
                        _vertices.append(vertex)
                        
                        maxAbsVertexPosValue = max(max(max(abs(x), abs(y)), abs(z)), maxAbsVertexPosValue)
                    }
                } else if separateValues.first == "f" {
                    for i in 1...3 {
                        let values = separateValues[i].split(separator: "/")
                        if let indexVal = values.first, let index = UInt16(indexVal) {
                            _indices.append(index - 1)
                        }
                    }
                }
            }
            
            normalizeVertexPos()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

// Private functions
extension ModelLoader {
    private func normalizeVertexPos() {
        let invMaxAbsVertexPosValue = 1 / maxAbsVertexPosValue
        
        _vertices = _vertices.map { $0 * invMaxAbsVertexPosValue }
    }
}
