//
//  ContentView.swift
//  Compass
//
//  Created by Aleksandr Borodulin on 07.07.2025.
//

import SwiftUI
import MijickCamera
import MetalCamera
import MetalKit
import Renderer
import MetalView
import GPUDevice

struct ContentView: View {
    @State private var mtkView = MTKView()
    @State private var renderer: Renderer?
    
    private let camera = MetalCamera()
    
    var body: some View {
        ZStack {
            MCamera()
                .startSession()
            MetalView(mtkView: $mtkView, renderer: $renderer)
        }
        .task {
            let cube = try? await DebugCube(device: GPUDevice.instance.mtlDevice,
                                            camera: camera,
                                            colorPixelFormat: mtkView.colorPixelFormat)
            
            let headModel = try? await HeadModel(device: GPUDevice.instance.mtlDevice,
                                                 camera: camera,
                                                 colorPixelFormat: mtkView.colorPixelFormat,
                                                 scale: 1.0)
            
            let headNormalModel = try? await HeadModel(device: GPUDevice.instance.mtlDevice,
                                                       camera: camera,
                                                       colorPixelFormat: mtkView.colorPixelFormat,
                                                       scale: 1.0,
                                                       drawNormals: true)
            
            if let headModel, let headNormalModel, let cube {
                renderer = Renderer(metalView: mtkView,
                                    device: GPUDevice.instance.mtlDevice,
                                    models: [cube, headModel, headNormalModel],
                                    camera: camera)
            }
            
//            let blueArrowModel = try? await ArrowModel(device: GPUDevice.instance.mtlDevice,
//                                                       camera: camera,
//                                                       colorPixelFormat: mtkView.colorPixelFormat,
//                                                       arrowColor: .blue)
//            
//            let blueArrowNormalsModel = try? await ArrowModel(device: GPUDevice.instance.mtlDevice,
//                                                              camera: camera,
//                                                              colorPixelFormat: mtkView.colorPixelFormat,
//                                                              arrowColor: .blue,
//                                                              drawNormals: true)
//            
//            let redArrowModel = try? await ArrowModel(device: GPUDevice.instance.mtlDevice,
//                                                      camera: camera,
//                                                      colorPixelFormat: mtkView.colorPixelFormat,
//                                                      arrowColor: .red)
//            
//            if let blueArrowModel, let blueArrowNormalsModel, let redArrowModel, let cube {
//                renderer = Renderer(metalView: mtkView,
//                                    device: GPUDevice.instance.mtlDevice,
//                                    models: [blueArrowModel, cube],
//                                    camera: camera)
//            }
        }
    }
}

#Preview {
    ContentView()
}
