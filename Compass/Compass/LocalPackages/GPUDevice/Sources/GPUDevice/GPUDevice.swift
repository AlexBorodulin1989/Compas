//
//  GPUDevice.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import Metal

@MainActor
public class GPUDevice {
    public static let instance: GPUDevice = .init()
    
    public let mtlDevice: MTLDevice
    
    private init() {
        guard
            let device = MTLCreateSystemDefaultDevice()
        else {
            fatalError("GPU device not available")
        }
        
        mtlDevice = device
    }
}
