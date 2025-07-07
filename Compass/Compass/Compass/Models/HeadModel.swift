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
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    private let vertices: [float3]
    let indices: [UInt16]
    
//    var vertices: [float3] = [
//        float3(-0.5, 0.5, 0),
//        float3(0.5, 0.5, 0),
//        float3(-0.5, -0.5, 0),
//        float3(0.5, -0.5, 0)
//    ]
//    
//    var indices: [UInt16] = [
//        0, 3, 2,
//        0, 1, 3
//    ]
    
    let name = "african_head"
    
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
        
        guard let file = Bundle.main.url(forResource: name, withExtension: "obj")
        else {
            fatalError("Could not find \(name) in main bundle.")
        }
        
        let modelLoader = await ModelLoader(fileUrl: file)
        
        vertices = modelLoader.vertices.map { $0 * scale }
        indices = modelLoader.indices
        
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices,
                                                   length: MemoryLayout<float3>.stride * vertices.count)
        else {
            throw RuntimeError("Cannot create vertex buffer in file \(#file)")
        }
        self.vertexBuffer = vertexBuffer
        
        guard let indexBuffer = device.makeBuffer(bytes: &indices,
                                                  length: MemoryLayout<UInt16>.stride * indices.count)
        else {
            throw RuntimeError("Cannot create index buffer buffer in file \(#file)")
        }
        self.indexBuffer = indexBuffer
    }
}
