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

class ArrowModel: Model {
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    let name = "direction_arrow"
    
    var indicesAmount = 0
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        let stride = MemoryLayout<float4>.stride
        vertexDescriptor.layouts[0].stride = stride
        
        return vertexDescriptor
    }
    
    init(device: MTLDevice, scale: Float = 1) async throws {
        try await initialize(device: device, scale: scale)
    }
    
    func initialize(device: MTLDevice, scale: Float = 1) async throws {
        guard let file = Bundle.main.url(forResource: name, withExtension: "obj")
        else {
            fatalError("Could not find \(name) in main bundle.")
        }
        
        let modelLoader = await ModelLoader(fileUrl: file)
        
        let rotateX = float4x4(rotationX: Float(90).degreesToRadians)
        let rotateZ = float4x4(rotationZ: Float(90).degreesToRadians)
        let rotate = rotateZ * rotateX
        
        var vertices = modelLoader.vertices.map { rotate * float4($0 * scale, 1) }
        var indices = modelLoader.indices
        
        indicesAmount = indices.count
        
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices,
                                                   length: MemoryLayout<float4>.stride * vertices.count)
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
