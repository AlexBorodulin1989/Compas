//
//  DebugCube.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 14.08.2025.
//
import Model
import MetalKit
import MathLibrary
import MetalCamera
import Constants

class DebugCube: Model {
    
    let camera: MetalCamera
    
    var pipelineState: MTLRenderPipelineState!
    
    let indicesAmount = 24
    
    var depthStencilState: MTLDepthStencilState!
    
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
    
    var cubeIndices: [UInt16] = [
        0, 1,
        1, 2,
        2, 3,
        3, 0,
        4, 5,
        5, 6,
        6, 7,
        7, 4,
        0, 4,
        1, 5,
        2, 6,
        3, 7
    ]
    
    init(device: MTLDevice,
         camera: MetalCamera,
         colorPixelFormat: MTLPixelFormat) async throws {
        self.camera = camera
        pipelineState = try await pipelineState(device: device, colorPixelFormat: colorPixelFormat)
        
        var cubeNormals: [float3] = []
        
        setupDepthStencil(device: device)
        try await setupBuffers(device: device, vertices: &cubeVertices, normals: &cubeNormals, indices: &cubeIndices)
    }
}

extension DebugCube {
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
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
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
        
        return vertexDescriptor
    }
}

extension DebugCube {
    func draw(renderEncoder: any MTLRenderCommandEncoder) {
        renderEncoder.setDepthStencilState(depthStencilState)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0,
                                      index: 0)
        
        let model = float4x4(translation: .init(x: 0, y: 0, z: 3 * Constants.unitValue)) * float4x4(scaling: Constants.unitValue)
        var transformMatrix = camera.projMatrix * model
        
        renderEncoder.setVertexBytes(&transformMatrix,
                                     length: MemoryLayout<float4x4>.stride,
                                     index: 10)
        
        renderEncoder.drawIndexedPrimitives(type: .line,
                                            indexCount: indicesAmount,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
    }
}
