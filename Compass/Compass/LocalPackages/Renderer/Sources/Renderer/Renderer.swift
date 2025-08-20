import MetalKit
import MetalCamera
import GeneralModel

// swiftlint:disable implicitly_unwrapped_optional

@MainActor
public class Renderer: NSObject {
    let models: [GeneralModel]
    let commandQueue: MTLCommandQueue!
    private var depthState: MTLDepthStencilState!
    
    let camera: MetalCamera
    
    var rotation: Float = 0
    
    public init(metalView: MTKView, device: MTLDevice, models: [GeneralModel], camera: MetalCamera) {
        self.models = models
        self.camera = camera
        
        let width = metalView.bounds.size.width > 1 ? metalView.bounds.size.width : 1
        let aspectRatio = metalView.bounds.size.height / width
        
        camera.setAspectRatio(Float(aspectRatio))
        
        guard let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Cannot create command queue")
        }
        self.commandQueue = commandQueue
        metalView.device = device
        
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
            alpha: 0.2)
        metalView.delegate = self
        
        metalView.depthStencilPixelFormat = .depth32Float
        
        metalView.isOpaque = false
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
    public func mtkView(_ view: MTKView,
                        drawableSizeWillChange size: CGSize) {
        let width = size.width > 1 ? size.width : 1
        let aspectRatio = size.height / width
        
        camera.setAspectRatio(Float(aspectRatio))
    }
    
    public func draw(in view: MTKView) {
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor
        else {
            return
        }
        
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.clearDepth = 0
        
        guard let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor)
        else {
            return
        }
        
        renderEncoder.setCullMode(.front)
        renderEncoder.setDepthStencilState(depthState)
        
        models.forEach { $0.draw(renderEncoder: renderEncoder) }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
