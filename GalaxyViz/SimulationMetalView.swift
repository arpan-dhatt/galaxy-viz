//
//  SimulationMetalView.swift
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

import SwiftUI
import UIKit
import MetalKit

struct Particle{
    var color: SIMD4<Float>
    var position: SIMD3<Float>
    var velocity: SIMD3<Float>
    var mass: Float
}

struct SimulationConstants {
    var gravitational_constant: Float
    var softening_factor: Float
    var dt: Float
    var angleX: Float
    var angleZ: Float
    var scale: Float
}

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
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            
            let commandbuffer = commandQueue.makeCommandBuffer()
            let computeCommandEncoder = commandbuffer?.makeComputeCommandEncoder()
            
            computeCommandEncoder?.setComputePipelineState(clearPass)
            computeCommandEncoder?.setTexture(drawable.texture, index: 0)

            let w = clearPass.threadExecutionWidth
            let h = clearPass.maxTotalThreadsPerThreadgroup / w
            
            var threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
            var threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
            computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)

            computeCommandEncoder?.setComputePipelineState(drawDotPass)
            computeCommandEncoder?.setBuffer(particleBuffer, offset: 0, index: 0)
            computeCommandEncoder?.setBytes(&particleCount, length: MemoryLayout<Int>.size, index: 1)
            computeCommandEncoder?.setBytes(&simulationConstants, length: MemoryLayout<SimulationConstants>.stride, index: 2)
            threadsPerGrid = MTLSize(width: Int(particleCount), height: 1, depth: 1)
            threadsPerThreadGroup = MTLSize(width: w, height: 1, depth: 1)
            computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)

            computeCommandEncoder?.endEncoding()
            commandbuffer?.present(drawable)
            commandbuffer?.commit()
            
            if ZDown {
                simulationConstants.angleZ += 0.05
            }
            if XDown {
                simulationConstants.angleX += 0.05
            }
            if CDown {
                simulationConstants.scale *= 1.05
            }
            if VDown {
                simulationConstants.scale /= 1.05
            }
            simulationConstants.angleX += 0.005
        }
        
        var parent: SimulationMetalView
        var metalDevice: MTLDevice!
        
        var commandQueue: MTLCommandQueue!
        var clearPass: MTLComputePipelineState!
        var drawDotPass: MTLComputePipelineState!
        
        var particleBuffer: MTLBuffer!
        var simulationConstants = SimulationConstants(gravitational_constant: 6.674, softening_factor: 10, dt: 1/2400, angleX: 0, angleZ: 0, scale: 1)
        
        var particleCount: Int = 10000
        var initial_velocity: Float = 2000000
        var screenSize: Float = 1000
        
        var ZDown: Bool = false
        var XDown: Bool = false
        var CDown: Bool = false
        var VDown: Bool = false
        
        
        init(_ parent: SimulationMetalView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.metalDevice = metalDevice
            }
            
            self.commandQueue = metalDevice.makeCommandQueue()
            
            let library = metalDevice.makeDefaultLibrary()
            let clearFunc = library?.makeFunction(name: "clear_pass_func")
            let drawDotFunc = library?.makeFunction(name: "draw_dots_func")
            
            do{
                clearPass = try metalDevice.makeComputePipelineState(function: clearFunc!)
                drawDotPass = try metalDevice.makeComputePipelineState(function: drawDotFunc!)
            }catch let error as NSError{
                print(error)
            }
            super.init()
            createParticles()
        }
        
        func createParticles(){
            var particles: [Particle] = []
            for i in 0..<particleCount{
                let red: Float = Float(arc4random_uniform(100)) / 100
                let green: Float = Float(arc4random_uniform(100)) / 100
                let blue: Float = Float(arc4random_uniform(100)) / 100
                let distance = Float(arc4random_uniform(UInt32(screenSize)/2))
                
                var position = SIMD3<Float>(Float.random(in: -1...1),Float.random(in: -1...1),Float.random(in: -1...1))
    //            position /= pow(position.x*position.x + position.y*position.y + position.z*position.z, 0.5)
                var velocity = SIMD3<Float>(Float.random(in: -1...1),Float.random(in: -1...1),0)
                velocity /= pow(velocity.x*velocity.x + velocity.y*velocity.y + velocity.z*velocity.z, 0.5)
                velocity *= 20
                
                let angle = Float.random(in: 0...(2*Float.pi))
                position.x = cos(angle) * distance
                position.y = sin(angle) * distance
                position.z *= 100

                velocity.x = cos(angle+Float.pi/2)
                velocity.y = sin(angle+Float.pi/2)
                velocity *= initial_velocity/(5000+distance/2000)
                velocity.z = Float.random(in: -0.1...0.1)
                
                
                let particle = Particle(color: SIMD4<Float>(red, green, blue, 1),
                                        position: position,
                                        velocity: velocity,
                                        mass: 1.98e3)
    //            if i == 0 {
    //                particle.position = SIMD3<Float>(screenSize, 0, 0)
    //                particle.velocity *= 0
    //                particle.mass *= 10000
    //            }
                particles.append(particle)
            }
            particleBuffer = metalDevice.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * Int(particleCount), options: .storageModeManaged)
        }
        
        func createParticlesFibonacci() {
            var particles: [Particle] = []
            let goldenRatio: Float = (1.0+sqrt(5.0))/2.0
            let angleIncrement = Float.pi * goldenRatio
            
            for i in 0..<particleCount {
                let t = Float(i)/Float(particleCount)
                let angle1 = acos(1-2*t)
                let angle2 = angleIncrement * Float(i)
                
                let x = sin(angle1) * cos(angle2)
                let y = sin(angle1) * sin(angle2)
                let z = cos(angle1)
                
                let p = Particle(color: SIMD4<Float>.zero, position: SIMD3<Float>(x: x, y: y, z: z) * screenSize/2, velocity: SIMD3<Float>.zero, mass: 1.98e3)
                particles.append(p)
            }
            particleBuffer = metalDevice.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * Int(particleCount), options: .storageModeManaged)
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
