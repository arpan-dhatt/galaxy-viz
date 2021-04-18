//
//  Shaders.metal
//  GalaxyViz
//
//  Created by Arpan Dhatt on 4/17/21.
//

#include <metal_stdlib>
using namespace metal;

struct Particle{
    float4 color;
    float3 position;
    float3 velocity;
    float mass;
};

struct SimulationConstants {
    float gravitational_constant;
    float softening_factor;
    float dt;
    float angleX;
    float angleZ;
    float scale;
};

kernel void clear_pass_func(texture2d<half, access::write> tex [[ texture(0) ]],
                            uint2 id [[ thread_position_in_grid ]]){
    tex.write(half4(0), id);
}

struct AccOut {
    float3 acc;
    float accMag;
};

AccOut acceleration(device Particle *particles, uint id, int particleCount, SimulationConstants simConsts) {
    Particle particle1 = particles[id];
    float3 total_acc = float3(0);
    float totalMag = 0;
    for (uint i = 0; i < uint(particleCount); i++) {
        Particle particle2 = particles[i];
        float3 acc = particle2.position - particle1.position;
        acc /= 2;
        float magSquared = acc.x*acc.x + acc.y*acc.y + acc.z*acc.z;
        float inv_r3 = pow(magSquared + simConsts.softening_factor*simConsts.softening_factor, 1.5);
        acc /= inv_r3;
        acc *= particle2.mass+0.001;
        totalMag += sqrt(magSquared);
        total_acc += acc;
    }
    return {total_acc*simConsts.gravitational_constant, totalMag};
}

float3 rotateZ(float3 point, float angle) {
    float x = point.x;
    float y = point.y;
    float z = point.z;
    return {x*cos(angle) - y*sin(angle), x*sin(angle) + y*cos(angle), z};
}

float3 rotateX(float3 point, float angle) {
    float x = point.x;
    float y = point.y;
    float z = point.z;
    return {x, y*cos(angle) - z*sin(angle), y*sin(angle) + z*cos(angle)};
}

half4 calculateColor(float accMag) {
    half r = half(min(float(1), float(accMag/5000000)));
    half g = half(min(float(1), float(accMag/5000000)));
    half b = half(min(float(1), float(accMag/5000000)));
    return half4(r, g, b, 1);
}

void drawCircle(texture2d<half, access::read_write> tex, half4 color) {
    
}

kernel void draw_dots_func(device Particle *particles [[ buffer(0) ]],
                           constant int &particleCount [[ buffer(1) ]],
                           constant SimulationConstants &simulationConstants [[ buffer(2) ]],
                           texture2d<half, access::read_write> tex [[ texture(0) ]],
                           uint id [[ thread_position_in_grid ]]){
    
    Particle particle;
    particle = particles[id];
    
    float3 position = particle.position;
    float3 velocity = particle.velocity;
    AccOut accOut = acceleration(particles, id, particleCount, simulationConstants);
    float3 acc = accOut.acc;
    float totalMag = accOut.accMag;
    velocity += acc*simulationConstants.dt;
    position += velocity*simulationConstants.dt;
    
//    if(position.x < 0 || position.x > width) velocity.x *= -1;
//    if(position.y < 0 || position.y > height) velocity.y *= -1;
    
    particle.position = position;
    particle.velocity = velocity;
    
    particles[id] = particle;
    float3 outPos = rotateZ(position, simulationConstants.angleZ);
    outPos = rotateX(outPos, simulationConstants.angleX);
    outPos *= simulationConstants.scale;
    uint2 texturePosition = uint2(outPos.x+tex.get_width()/2, outPos.y+tex.get_height()/2);
    half4 col = calculateColor(totalMag);
    tex.write(tex.read(texturePosition)+col, texturePosition);
//    tex.write(tex.read(texturePosition + uint2(1,0))+col, texturePosition + uint2(1,0));
//    tex.write(tex.read(texturePosition + uint2(0,1))+col, texturePosition + uint2(0,1));
//    tex.write(tex.read(texturePosition - uint2(1,0))+col, texturePosition - uint2(1,0));
//    tex.write(tex.read(texturePosition - uint2(0,1))+col, texturePosition - uint2(0,1));
}


