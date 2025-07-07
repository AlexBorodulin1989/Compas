//
//  ArrowModelDescriptor.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//
import MetalKit
import MathLibrary

class ArrowModel: Model {
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    let name = "direction_arrow"
    
    var indicesAmount = 0
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        let stride = MemoryLayout<float3>.stride
        vertexDescriptor.layouts[0].stride = stride
        
        return vertexDescriptor
    }
    
    init(device: MTLDevice, scale: Float = 1) async throws {
        try await initialize(device: device, scale: scale)
    }
}
