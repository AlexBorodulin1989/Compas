//
//  DebugCube.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 14.08.2025.
//
import Model
import MetalKit
import MathLibrary

class DebugCube: Model {
    let indicesAmount = 12
    
    var vertexBuffer: MTLBuffer!
    var normalsBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    var cubeVertices: [float3] = [
        [-1, 1, -1],
        [1, 1, -1],
        [1, -1, -1],
        [-1, -1, -1],
        [-1, 1, 1],
        [1, 1, 1],
        [1, -1, 1],
        [-1, -1, 1]
    ]
    
    var indices: [UInt16] = [
        0, 1,
        1, 2,
        2, 3,
        3, 0,
        4, 5,
        5, 6,
        6, 7,
        7, 0,
        0, 4,
        1, 5,
        2, 6,
        3, 7
    ]
    
    func pipelineState(device: MTLDevice,
                       colorPixelFormat: MTLPixelFormat) async throws -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary()
        else {
            fatalError("Cannot create command queue")
        }
        
        let vertexFunction = library.makeFunction(name: "edge_vert")
        let fragmentFunction = library.makeFunction(name: "edge_frag")
        
        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try await device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}

extension DebugCube {
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        
        vertexDescriptor.layouts[1].stride = MemoryLayout<float3>.stride
        
        return vertexDescriptor
    }
}

extension DebugCube {
    func draw(renderEncoder: any MTLRenderCommandEncoder) {
        
    }
}
