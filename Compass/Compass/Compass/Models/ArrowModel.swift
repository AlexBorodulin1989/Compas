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
import MetalCamera

class ArrowModel: Model {
    var vertexBuffer: MTLBuffer!
    var normalsBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    let name = "direction_arrow"
    let camera: MetalCamera
    
    var indicesAmount = 0
    
    var pipelineState: MTLRenderPipelineState
    
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
        let rotateX = float4x4(rotationX: Float(90).degreesToRadians)
        let rotateZ = float4x4(rotationZ: Float(90).degreesToRadians)
        let rotate = float4x4(rotationZ: Float(180).degreesToRadians) * rotateZ * rotateX
        
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
        
        try await initialize(device: device, scale: scale, preTransformations: rotate)
    }
    
    func draw(renderEncoder: any MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var projMatrix = camera.projMatrix * float4x4(translation: .init(0, 0, 0.5)) * float4x4(rotationZ: Float(180).degreesToRadians)
        
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
