//
//  Model.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import Metal
import RuntimeError
import MathLibrary
import simd

public protocol Model: AnyObject {
    var vertexBuffer: MTLBuffer! { get set }
    var indexBuffer: MTLBuffer! { get set }
    var normalsBuffer: MTLBuffer! { get set }
    
    var indicesAmount: Int { get }
    
    func draw(renderEncoder: MTLRenderCommandEncoder)
}

public extension Model {
    func setupBuffers(device: MTLDevice,
                      vertices: inout [float3],
                      normals: inout [float3],
                      indices: inout [UInt16]) async throws {
        
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices,
                                                   length: MemoryLayout<float3>.stride * vertices.count)
        else {
            throw RuntimeError("Cannot create vertex buffer in file \(#file)")
        }
        self.vertexBuffer = vertexBuffer
        
        if !normals.isEmpty {
            guard let normalsBuffer = device.makeBuffer(bytes: &normals,
                                                       length: MemoryLayout<float3>.stride * normals.count)
            else {
                throw RuntimeError("Cannot create vertex buffer in file \(#file)")
            }
            self.normalsBuffer = normalsBuffer
        }
        
        guard let indexBuffer = device.makeBuffer(bytes: &indices,
                                                  length: MemoryLayout<UInt16>.stride * indices.count)
        else {
            throw RuntimeError("Cannot create index buffer buffer in file \(#file)")
        }
        self.indexBuffer = indexBuffer
    }
}
