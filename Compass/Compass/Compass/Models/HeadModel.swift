//
//  HeadModel.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import MetalKit
import MathLibrary
import ModelLoader
import RuntimeError

class HeadModel: Model {
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    let name = "african_head"
    
    var indicesAmount: Int = 0
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
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
