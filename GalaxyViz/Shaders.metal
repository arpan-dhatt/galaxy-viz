//
//  Shaders.metal
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void black_placeholder_func(texture2d<half, access::read_write> tex [[ texture(0) ]],
                                   uint id [[ thread_position_in_grid ]]) {
    
}
