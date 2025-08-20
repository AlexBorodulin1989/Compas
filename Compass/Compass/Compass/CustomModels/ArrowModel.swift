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
import CoreMotion

enum ArrowColor {
    case red
    case blue
}

class ArrowModel: UploadModel {
    let name = "direction_arrow"
    let camera: MetalCamera
    let xOffset: Float
    
    var pipelineState: MTLRenderPipelineState!
    
    private let drawNormals: Bool
    
    private let motionManager = CMMotionManager()
    private let motionManagerQueue = OperationQueue()
    private var lastUpdateMotion = Date.now
    
    private var rotationMatrix = float4x4.identity
    
    static var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        
        vertexDescriptor.layouts[1].stride = MemoryLayout<float3>.stride
        
        return vertexDescriptor
    }
    
    init(device: MTLDevice,
         camera: MetalCamera,
         colorPixelFormat: MTLPixelFormat,
         scale: Float = 1,
         xOffset: Float,
         arrowColor: ArrowColor,
         drawNormals: Bool = false) async throws {
        
        self.camera = camera
        self.xOffset = xOffset
        self.drawNormals = drawNormals
        
        let rotateX = float4x4(rotationX: Float(90).degreesToRadians)
        let rotateZ = float4x4(rotationZ: Float(90).degreesToRadians)
        let rotate = float4x4(rotationZ: Float(180).degreesToRadians) * rotateZ * rotateX
        
        try await super.init(device: device, modelName: name, scale: scale, preTransformations: rotate)
        
        if drawNormals {
            pipelineState = try await normalsPipelineState(device: device, colorPixelFormat: colorPixelFormat)
        } else {
            switch arrowColor {
            case .red:
                pipelineState = try await redPipelineState(device: device, colorPixelFormat: colorPixelFormat)
            case .blue:
                pipelineState = try await bluePipelineState(device: device, colorPixelFormat: colorPixelFormat)
            }
        }
        
        motionManager.startDeviceMotionUpdates(to: motionManagerQueue) { [weak self] data, error in
            guard let self, Date().timeIntervalSince(lastUpdateMotion) > 0.02 else { return }
            
            lastUpdateMotion = .now
            
            if error != nil {
                return
            }
            
            if let trackMotion = data?.attitude {
                motionManager.deviceMotionUpdateInterval = 0.02
                Task { @MainActor [weak self] in
                    let matrix = trackMotion.rotationMatrix
                    self?.rotationMatrix = .init(
                        [Float(matrix.m11), Float(matrix.m21), Float(matrix.m31), 0],
                        [Float(matrix.m12), Float(matrix.m22), Float(matrix.m32), 0],
                        [Float(matrix.m13), Float(matrix.m23), Float(matrix.m33), 0],
                        [0, 0, 0, 1]
                    )
                }
                
                print("pitch = \(trackMotion.pitch), yaw = \(trackMotion.yaw), roll = \(trackMotion.roll)")
            }
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
    
    func redPipelineState(device: MTLDevice,
                          colorPixelFormat: MTLPixelFormat) async throws -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary()
        else {
            fatalError("Cannot create command queue")
        }
        
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction =
        library.makeFunction(name: "fragment_main_red")
        
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
        // Set the depth stencil state on the render command encoder
        renderEncoder.setDepthStencilState(depthStencilState)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0,
                                      index: 0)
        
        renderEncoder.setVertexBuffer(normalsBuffer,
                                      offset: 0,
                                      index: 1)
        
        var model = float4x4(translation: .init(0, 0, 0.5)) * rotationMatrix * float4x4(translation: .init(x: xOffset, y: 0, z: 0)) * float4x4(rotationZ: Float(180).degreesToRadians)
        
        if drawNormals {
            var projMatrix = camera.projMatrix
            
            renderEncoder.setVertexBytes(&projMatrix,
                                         length: MemoryLayout<float4x4>.stride,
                                         index: 10)
            
            renderEncoder.setVertexBytes(&model,
                                         length: MemoryLayout<float4x4>.stride,
                                         index: 11)
            
            var normMatrix = float3x3(normalFrom4x4: model)
            
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
            var transformMatrix = camera.projMatrix * model
            
            renderEncoder.setVertexBytes(&transformMatrix,
                                         length: MemoryLayout<float4x4>.stride,
                                         index: 10)
            
            var normProjMatrix = float3x3(normalFrom4x4: model)
            
            renderEncoder.setVertexBytes(&normProjMatrix,
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
