//
//  ArrowModelDescriptor.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//
import MetalKit
import MathLibrary

class ArrowModel {
    static let name = "direction_arrow"
    
    static var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        let stride = MemoryLayout<float3>.stride
        vertexDescriptor.layouts[0].stride = stride
        
        return vertexDescriptor
    }
}
