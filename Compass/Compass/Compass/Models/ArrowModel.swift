//
//  ArrowModelDescriptor.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//
import MetalKit
import MathLibrary
import ModelLoader
import RuntimeError

class ArrowModel {
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    private let vertices: [float3]
    private let indices: [UInt16]
    
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
    
    init(device: MTLDevice, scale: Float = 1) async throws {
        
        guard let file = Bundle.main.url(forResource: ArrowModel.name, withExtension: "obj")
        else {
            fatalError("Could not find \(ArrowModel.name) in main bundle.")
        }
        
        let modelLoader = await ModelLoader(fileUrl: file)
        
        vertices = modelLoader.vertices.map { $0 * scale }
        indices = modelLoader.indices
        
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices,
                                                   length: MemoryLayout<Float>.stride * vertices.count)
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
