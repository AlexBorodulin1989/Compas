//
//  NormalsShader.metal
//  Compass
//
//  Created by Aleksandr Borodulin on 13.07.2025.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 normal_vertex_main(constant float4 &positions [[ buffer(0) ]],
                          constant float4 &normals [[ buffer(1) ]],
                          constant float4x4 &projection [[ buffer(10) ]],
                          constant float3x3 &normProjection [[ buffer(11) ]],
                          uint vertexID [[ vertex_id ]]) {
    auto sunDir = float3(0., 1., 0.);
    auto index = vertexID / 2;
    float4 position = positions[index];
    if (index * 2 != vertexID) {
        float4 normal = normals[index];
        auto norm = normProjection * normalize(normal.xyz);
        position = float4(norm * 0.2 + position.xyz, 1);
    }
    
    return position;
}

fragment float4 normal_fragment_main() {
    return float4(0, 0, 0, 1);
}
