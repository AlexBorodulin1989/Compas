//
//  Model.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import Metal

protocol Model {
    var vertexBuffer: MTLBuffer { get }
    var indexBuffer: MTLBuffer { get }
    
    var vertexDescriptor: MTLVertexDescriptor { get }
    
    var indices: [UInt16] { get }
}
