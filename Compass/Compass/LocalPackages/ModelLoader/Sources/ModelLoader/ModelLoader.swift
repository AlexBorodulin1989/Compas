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
    public var normals: [float3] { _normals }
    public var indices: [UInt16] { _indices }
    
    // Private properties
    private var _vertices: [float3] = .init()
    private var _normals: [float3] = .init()
    private var _indices: [UInt16] = .init()
    private var maxAbsVertexPosValue: Float = 0
    
    public init(fileUrl: URL) async {
        do {
            let contents = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            
            let lines = contents.split(separator: "\n")
            
            var rawNormals = [float3]()
            var rawNormalIndices = [UInt16]()
            
            lines.forEach { line in
                let separateValues = line.split(separator: " ")
                if separateValues.first == "v" && separateValues.count == 4 {
                    if let x = Float(separateValues[1]),
                       let y = Float(separateValues[2]),
                       let z = Float(separateValues[3]) {
                        let vertex = float3(x, y, -z)
                        _vertices.append(vertex)
                        
                        maxAbsVertexPosValue = max(max(max(abs(x), abs(y)), abs(z)), maxAbsVertexPosValue)
                    }
                } else if separateValues.first == "f" {
                    for i in 1...3 {
                        let values = separateValues[i].split(separator: "/", omittingEmptySubsequences: false)
                        if let indexVal = values.first, let vertexIndex = UInt16(indexVal), values.count == 3 {
                            _indices.append(vertexIndex - 1)
                            
                            if let normalIndex = UInt16(values[2]) {
                                rawNormalIndices.append(normalIndex - 1)
                            }
                        }
                    }
                } else if separateValues.first == "vn" && separateValues.count == 4 {
                    if let x = Float(separateValues[1]),
                       let y = Float(separateValues[2]),
                       let z = Float(separateValues[3]) {
                        let normal = float3(x, y, -z)
                        rawNormals.append(normal.normalized())
                    }
                }
            }
            
            normalizeVertexPos()
            
            orderNormals(rawNormals: rawNormals, rawNormalIndices: rawNormalIndices)
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
    
    private func orderNormals(rawNormals: [float3], rawNormalIndices: [UInt16]) {
        let indicesCount = _indices.count
        _normals = [float3](repeating: .init(), count: indicesCount)
        for i in 0..<indicesCount {
            _normals[Int(_indices[i])] = rawNormals[Int(rawNormalIndices[i])]
        }
    }
}
