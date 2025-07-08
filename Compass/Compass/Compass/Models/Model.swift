//
//  Model.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import Metal
import ModelLoader
import RuntimeError
import MathLibrary

protocol Model: AnyObject {
    var vertexBuffer: MTLBuffer! { get set }
    var indexBuffer: MTLBuffer! { get set }
    
    var vertexDescriptor: MTLVertexDescriptor { get }
    
    var indicesAmount: Int { get set }
    
    var name: String { get }
}

extension Model {
    
    func initialize(device: MTLDevice, scale: Float = 1) async throws {
        guard let file = Bundle.main.url(forResource: name, withExtension: "obj")
        else {
            fatalError("Could not find \(name) in main bundle.")
        }
        
        let modelLoader = await ModelLoader(fileUrl: file)
        
        var vertices = modelLoader.vertices.map { float4($0 * scale, 1) }
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
