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
import MetalCamera

class HeadModel: Model {
    var vertexBuffer: MTLBuffer!
    var normalsBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    let name = "african_head"
    let camera: MetalCamera
    
    var indicesAmount: Int = 0
    
    var pipelineState: MTLRenderPipelineState
    
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
    
    static var vertexDescriptor: MTLVertexDescriptor {
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
    
    init(device: MTLDevice,
         camera: MetalCamera,
         colorPixelFormat: MTLPixelFormat,
         scale: Float = 1) async throws {
        
        self.camera = camera
        
        guard let library = device.makeDefaultLibrary()
        else {
            fatalError("Cannot create command queue")
        }
        
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction =
        library.makeFunction(name: "fragment_main_blue")
        
        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineDescriptor.vertexDescriptor = Self.vertexDescriptor
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            pipelineState = try await device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        try await initialize(device: device, scale: scale, preTransformations: float4x4(rotationY: .pi))
    }
    
    func draw(renderEncoder: any MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var projMatrix = camera.projMatrix * float4x4(translation: .init(x: 0, y: 0, z: 1.1))
        
        renderEncoder.setVertexBytes(&projMatrix,
                                     length: MemoryLayout<float4x4>.stride,
                                     index: 10)
        
        var normProjMatrix = float3x3(normalFrom4x4: projMatrix)
        
        renderEncoder.setVertexBytes(&normProjMatrix,
                                     length: MemoryLayout<float3x3>.stride,
                                     index: 11)
        
        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0,
                                      index: 0)
        
        renderEncoder.setVertexBuffer(normalsBuffer,
                                      offset: 0,
                                      index: 1)
        
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indicesAmount,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
    }
}
