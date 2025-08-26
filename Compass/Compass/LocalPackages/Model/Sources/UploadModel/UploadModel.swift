//
//  CustomModel.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 13.08.2025.
//

import MetalKit
import GeneralModel
import ModelLoader
import MathLibrary
import Transform

open class UploadModel: GeneralModel {
    public var transform: Transform = .init()
    
    public let indicesAmount: Int
    
    public var depthStencilState: MTLDepthStencilState!
    
    public var vertexBuffer: MTLBuffer!
    public var normalsBuffer: MTLBuffer!
    public var indexBuffer: MTLBuffer!
    
    static private let defaultModelExtension = "obj"
    
    public required init(device: MTLDevice,
                         modelName: String,
                         scale: Float = 1,
                         preTransformations: float4x4 = .identity) async throws {
        
        let modelLoader = await Self.loadModel(device: device,
                                               modelName: modelName,
                                               scale: scale,
                                               preTransformations: preTransformations)
        
        var vertices = modelLoader.vertices.map { preTransformations * float4($0 * scale, 1) }.map { float3(x: $0.x / $0.w, y: $0.y / $0.w, z: $0.z / $0.w) }
        var normals = modelLoader.normals.map { (float3x3(normalFrom4x4: preTransformations) * $0).normalized() }
        var indices = modelLoader.indices
        
        indicesAmount = indices.count
        
        setupDepthStencil(device: device)
        try await setupBuffers(device: device, vertices: &vertices, normals: &normals, indices: &indices)
    }
    
    open func draw(renderEncoder: any MTLRenderCommandEncoder) {}
}

extension UploadModel {
    static func loadModel(device: MTLDevice, modelName: String, scale: Float, preTransformations: float4x4) async -> ModelLoader {
        guard let file = Bundle.main.url(forResource: modelName, withExtension: defaultModelExtension)
        else {
            fatalError("Could not find \(modelName) in main bundle.")
        }
        
        return await ModelLoader(fileUrl: file)
    }
}
