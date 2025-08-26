//
//  HeadModel.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import MetalKit
import UploadModel
import MathLibrary
import ModelLoader
import RuntimeError
import MetalCamera

class HeadModel: UploadModel {
    
    let name = "african_head"
    let camera: MetalCamera
    
    var pipelineState: MTLRenderPipelineState!
    private let drawNormals: Bool
    
    private var time: Float = 0
    
    static var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float4>.stride
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        
        vertexDescriptor.layouts[1].stride = MemoryLayout<float4>.stride
        
        return vertexDescriptor
    }
    
    init(device: MTLDevice,
         camera: MetalCamera,
         colorPixelFormat: MTLPixelFormat,
         scale: Float = 1,
         drawNormals: Bool = false) async throws {
        
        self.camera = camera
        self.drawNormals = drawNormals
        
        try await super.init(device: device, modelName: name, scale: scale)
        
        if drawNormals {
            pipelineState = try await normalsPipelineState(device: device, colorPixelFormat: colorPixelFormat)
        } else {
            pipelineState = try await bluePipelineState(device: device, colorPixelFormat: colorPixelFormat)
        }
    }
    
    required init(device: MTLDevice, modelName: String, scale: Float = 1, preTransformations: float4x4 = .identity) async throws {
        fatalError("init(device:modelName:scale:preTransformations:) has not been implemented")
    }
    
    func bluePipelineState(device: MTLDevice,
                           colorPixelFormat: MTLPixelFormat) async throws -> MTLRenderPipelineState {
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
        
        return try await device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func normalsPipelineState(device: MTLDevice,
                              colorPixelFormat: MTLPixelFormat) async throws -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary()
        else {
            fatalError("Cannot create command queue")
        }
        
        let vertexFunction = library.makeFunction(name: "normal_vertex_main")
        let fragmentFunction =
        library.makeFunction(name: "normal_fragment_main")
        
        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try await device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    override func draw(renderEncoder: any MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(pipelineState)
        
        time += 0.001

        // Set the depth stencil state on the render command encoder
        renderEncoder.setDepthStencilState(depthStencilState)
        
        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0,
                                      index: 0)
        
        renderEncoder.setVertexBuffer(normalsBuffer,
                                      offset: 0,
                                      index: 1)
        
        var modelMatrix = transform.modelMatrix
        let normalModelMatrix = transform.normalModelMatrix
        
        if drawNormals {
            var projMatrix = camera.projMatrix
            
            renderEncoder.setVertexBytes(&projMatrix,
                                         length: MemoryLayout<float4x4>.stride,
                                         index: 10)
            
            renderEncoder.setVertexBytes(&modelMatrix,
                                         length: MemoryLayout<float4x4>.stride,
                                         index: 11)
            
            var normMatrix = float3x3(normalFrom4x4: normalModelMatrix)
            
            renderEncoder.setVertexBytes(&normMatrix,
                                         length: MemoryLayout<float4x4>.stride,
                                         index: 12)
            
            renderEncoder.setVertexBuffer(indexBuffer,
                                          offset: 0,
                                          index: 2)
            
            renderEncoder.drawPrimitives(type: .line,
                                         vertexStart: 0,
                                         vertexCount: indicesAmount * 2)
        } else {
            var transformMatrix = camera.projMatrix * modelMatrix
            
            renderEncoder.setVertexBytes(&transformMatrix,
                                         length: MemoryLayout<float4x4>.stride,
                                         index: 10)
            
            var normMatrix = float3x3(normalFrom4x4: normalModelMatrix)
            
            renderEncoder.setVertexBytes(&normMatrix,
                                         length: MemoryLayout<float3x3>.stride,
                                         index: 11)
            
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: indicesAmount,
                                                indexType: .uint16,
                                                indexBuffer: indexBuffer,
                                                indexBufferOffset: 0)
        }
    }
}
