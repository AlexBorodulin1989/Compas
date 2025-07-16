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
    var normalsBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    let name = "direction_arrow"
    
    var indicesAmount = 0
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float4>.stride
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        
        vertexDescriptor.layouts[1].stride = MemoryLayout<float4>.stride
        
        return vertexDescriptor
    }
    
    init(device: MTLDevice, scale: Float = 1) async throws {
        let rotateX = float4x4(rotationX: Float(90).degreesToRadians)
        let rotateZ = float4x4(rotationZ: Float(90).degreesToRadians)
        let rotate = float4x4(rotationZ: Float(180).degreesToRadians) * rotateZ * rotateX
        try await initialize(device: device, scale: scale, preTransformations: rotate)
    }
}
