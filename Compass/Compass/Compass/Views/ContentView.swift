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
import Constants
import Transform

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
            
            var transform = Transform()
            transform.position.z = 3 * Constants.unitValue
            transform.scale = .init(repeating: Constants.unitValue)
            
            let cube = try? await DebugCube(device: GPUDevice.instance.mtlDevice,
                                            camera: camera,
                                            colorPixelFormat: mtkView.colorPixelFormat)
            cube?.transform = transform
            
//            let headModel = try? await HeadModel(device: GPUDevice.instance.mtlDevice,
//                                                 camera: camera,
//                                                 colorPixelFormat: mtkView.colorPixelFormat,
//                                                 scale: 1.0)
//            headModel?.transform = transform
//            
//            let headNormalModel = try? await HeadModel(device: GPUDevice.instance.mtlDevice,
//                                                       camera: camera,
//                                                       colorPixelFormat: mtkView.colorPixelFormat,
//                                                       scale: 1.0,
//                                                       drawNormals: true)
//            headNormalModel?.transform = transform
//            
//            if let headModel, let headNormalModel, let cube {
//                renderer = Renderer(metalView: mtkView,
//                                    device: GPUDevice.instance.mtlDevice,
//                                    models: [cube, headModel],
//                                    camera: camera)
//            }
            
            let blueArrowModel = try? await ArrowModel(device: GPUDevice.instance.mtlDevice,
                                                       camera: camera,
                                                       colorPixelFormat: mtkView.colorPixelFormat,
                                                       arrowColor: .blue)
            blueArrowModel?.transform = transform
            
            let blueArrowNormalsModel = try? await ArrowModel(device: GPUDevice.instance.mtlDevice,
                                                              camera: camera,
                                                              colorPixelFormat: mtkView.colorPixelFormat,
                                                              arrowColor: .blue,
                                                              drawNormals: true)
            blueArrowNormalsModel?.transform = transform
            
            let redArrowModel = try? await ArrowModel(device: GPUDevice.instance.mtlDevice,
                                                      camera: camera,
                                                      colorPixelFormat: mtkView.colorPixelFormat,
                                                      arrowColor: .red)
            redArrowModel?.transform = transform
            
            if let blueArrowModel, let blueArrowNormalsModel, let redArrowModel, let cube {
                renderer = Renderer(metalView: mtkView,
                                    device: GPUDevice.instance.mtlDevice,
                                    models: [blueArrowModel, cube],
                                    camera: camera)
            }
        }
    }
}

#Preview {
    ContentView()
}
