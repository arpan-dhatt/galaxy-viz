//
//  SimulationMetalView.swift
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

import SwiftUI
import UIKit
import MetalKit

struct SimulationMetalView {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeMTKView(_ context: SimulationMetalView.Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        return mtkView
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: SimulationMetalView
        var metalDevice: MTLDevice!
        
        var metalCommandQueue: MTLCommandQueue!
        var clearPass: MTLComputePipelineState!
        var drawDotPass: MTLComputePipelineState!
        
        var particleBuffer: MTLBuffer!
        
        init(_ parent: SimulationMetalView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.metalDevice = metalDevice
            }
            self.metalCommandQueue = metalDevice.makeCommandQueue()!
            
            let library = metalDevice.makeDefaultLibrary()
            let clearFunc = library?.makeFunction(name: "clear_pass_func")
            let drawDotFunc = library?.makeFunction(name: "draw_dot_func")
            do{
                clearPass = try metalDevice.makeComputePipelineState(function: clearFunc!)
                drawDotPass = try metalDevice.makeComputePipelineState(function: drawDotFunc!)
            }catch let error as NSError{
                print(error)
            }
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else {
                return
            }
            
            let commandBuffer = metalCommandQueue.makeCommandBuffer()
            let rpd = view.currentRenderPassDescriptor
            rpd?.colorAttachments[0].clearColor = MTLClearColorMake(0.43, 0.73, 0.35, 1.0)
            rpd?.colorAttachments[0].loadAction = .clear
            rpd?.colorAttachments[0].storeAction = .store
            let re = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd!)
            re?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}

#if os(macOS)
extension SimulationMetalView : NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {

    }
}
#endif

#if os(iOS)
extension SimulationMetalView : UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        return makeMTKView(context)
    }
    
    func updateUIView(_ nsView: MTKView, context: Context) {

    }
}
#endif
