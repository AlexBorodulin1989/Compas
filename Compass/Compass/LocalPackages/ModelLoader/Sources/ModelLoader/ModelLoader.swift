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
    
    public init(fileUrl: URL) async {
        do {
            let contents = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            
            let lines = contents.split(separator: "\n")
            
            var rawNormals = [float3]()
            var rawNormalIndices = [UInt16]()
            
            var maxAbsVertexPosValue: Double = 0
            
            var maxX = -Double.greatestFiniteMagnitude
            var minX = Double.greatestFiniteMagnitude
            var maxY = -Double.greatestFiniteMagnitude
            var minY = Double.greatestFiniteMagnitude
            var maxZ = -Double.greatestFiniteMagnitude
            var minZ = Double.greatestFiniteMagnitude
            
            lines.forEach { line in
                let separateValues = line.split(separator: " ")
                
                if separateValues.first == "v" && separateValues.count == 4 {
                    if let x = Double(separateValues[1]),
                       let y = Double(separateValues[2]),
                       let z = Double(separateValues[3]) {
                        
                        if x > maxX {
                            maxX = x
                        }
                        
                        if x < minX {
                            minX = x
                        }
                        
                        if y > maxY {
                            maxY = y
                        }
                        
                        if y < minY {
                            minY = y
                        }
                        
                        if z > maxZ {
                            maxZ = z
                        }
                        
                        if z < minZ {
                            minZ = z
                        }
                    }
                }
            }
            
            let xOffset = -(minX + maxX) * 0.5
            let yOffset = -(minY + maxY) * 0.5
            let zOffset = -(minZ + maxZ) * 0.5
            
            lines.forEach { line in
                let separateValues = line.split(separator: " ")
                
                if separateValues.first == "v" && separateValues.count == 4 {
                    if let x = Double(separateValues[1]),
                       let y = Double(separateValues[2]),
                       let z = Double(separateValues[3]) {
                        maxAbsVertexPosValue = max(max(max(abs(x + xOffset), abs(y + yOffset)), abs(z + zOffset)), maxAbsVertexPosValue)
                    }
                }
            }
            
            maxX = -Double.greatestFiniteMagnitude
            minX = Double.greatestFiniteMagnitude
            maxY = -Double.greatestFiniteMagnitude
            minY = Double.greatestFiniteMagnitude
            maxZ = -Double.greatestFiniteMagnitude
            minZ = Double.greatestFiniteMagnitude
            
            lines.forEach { line in
                let separateValues = line.split(separator: " ")
                if separateValues.first == "v" && separateValues.count == 4 {
                    if let x = Double(separateValues[1]),
                       let y = Double(separateValues[2]),
                       let z = Double(separateValues[3]) {
                        let vertex = double3(x + xOffset, y + yOffset, -(z + zOffset)) / maxAbsVertexPosValue
                        _vertices.append(.init(x: Float(vertex.x), y: Float(vertex.y), z: Float(vertex.z)))
                        
                        if vertex.x > maxX {
                            maxX = vertex.x
                        }
                        
                        if vertex.x < minX {
                            minX = vertex.x
                        }
                        
                        if vertex.y > maxY {
                            maxY = vertex.y
                        }
                        
                        if vertex.y < minY {
                            minY = vertex.y
                        }
                        
                        if vertex.z > maxZ {
                            maxZ = vertex.z
                        }
                        
                        if vertex.z < minZ {
                            minZ = vertex.z
                        }
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
                    if let x = Double(separateValues[1]),
                       let y = Double(separateValues[2]),
                       let z = Double(separateValues[3]) {
                        let normal = double3(x, y, -z).normalized()
                        rawNormals.append(float3(x: Float(normal.x), y: Float(normal.y), z: Float(normal.z)))
                    }
                }
            }
            
            print("maxX = \(maxX)")
            print("minX = \(minX)")
            print("maxY = \(maxY)")
            print("minY = \(minY)")
            print("maxZ = \(maxZ)")
            print("minZ = \(minZ)")
            
            orderNormals(rawNormals: rawNormals, rawNormalIndices: rawNormalIndices)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

// Private functions
extension ModelLoader {
    
    private func orderNormals(rawNormals: [float3], rawNormalIndices: [UInt16]) {
        let indicesCount = _indices.count
        _normals = [float3](repeating: .init(), count: indicesCount)
        for i in 0..<indicesCount {
            _normals[Int(_indices[i])] = rawNormals[Int(rawNormalIndices[i])]
        }
    }
}
