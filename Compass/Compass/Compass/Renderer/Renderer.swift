/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MetalKit
import Camera
import CoreMotion

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
    let model: Model
    let commandQueue: MTLCommandQueue!
    let library: MTLLibrary
    var pipelineState: MTLRenderPipelineState
    private var depthState: MTLDepthStencilState!
    
    private let far: Double = 2
    private let near: Double = 1
    
    var camera: Camera
    
    var rotation: Float = 0
    
    let motionManager = CMMotionManager()
    let motionManagerQueue = OperationQueue()
    var lastUpdateMotion = Date.now
    
    var rotationMatrix = float4x4.identity
    
    init(metalView: MTKView, device: MTLDevice, model: Model) {
        self.model = model
        
        let width = metalView.bounds.size.width > 1 ? metalView.bounds.size.width : 1
        let aspectRatio = metalView.bounds.size.height / width
        
        camera = .init(aspectRatio: Float(aspectRatio))
        
        guard let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Cannot create command queue")
        }
        self.commandQueue = commandQueue
        metalView.device = device
        
        guard let library = device.makeDefaultLibrary()
        else {
            fatalError("Cannot create command queue")
        }
        self.library = library
        
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction =
        library.makeFunction(name: "fragment_main")
        
        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = model.vertexDescriptor
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            pipelineState =
            try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        guard
            let depthState = createDepthState(device: device)
        else {
            fatalError("Fatal error: cannot create depth state")
        }
        self.depthState = depthState
        
        metalView.clearColor = MTLClearColor(
            red: 1.0,
            green: 1.0,
            blue: 0.8,
            alpha: 1.0)
        metalView.delegate = self
        
        metalView.depthStencilPixelFormat = .depth32Float
        
        
        motionManager.startDeviceMotionUpdates(to: motionManagerQueue) { [weak self] data, error in
            guard let self, Date().timeIntervalSince(lastUpdateMotion) > 0.02 else { return }
            
            lastUpdateMotion = .now
            
            if let error {
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
            }
        }
    }
}

extension Renderer {
    func createDepthState(device: MTLDevice) -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: descriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        let width = size.width > 1 ? size.width : 1
        let aspectRatio = size.height / width
        
        camera = .init(aspectRatio: Float(aspectRatio))
    }
    
    func draw(in view: MTKView) {
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }
        
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // do drawing here
        rotation += 0.01
        var projMatrix = camera.projMatrix * float4x4(translation: .init(0, 0, 0.5)) * rotationMatrix
        
        renderEncoder.setVertexBytes(&projMatrix,
                                     length: MemoryLayout<float4x4>.stride,
                                     index: 10)
        
        var normProjMatrix = float3x3(normalFrom4x4: projMatrix)
        
        renderEncoder.setVertexBytes(&normProjMatrix,
                                     length: MemoryLayout<float3x3>.stride,
                                     index: 11)
        
        renderEncoder.setVertexBuffer(model.vertexBuffer,
                                      offset: 0,
                                      index: 0)
        
        renderEncoder.setVertexBuffer(model.normalsBuffer,
                                      offset: 0,
                                      index: 1)
        
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: model.indicesAmount,
                                            indexType: .uint16,
                                            indexBuffer: model.indexBuffer,
                                            indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
