//
//  NormalsShader.metal
//  Compass
//
//  Created by Aleksandr Borodulin on 13.07.2025.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 normal_vertex_main(constant float3 *positions [[ buffer(0) ]],
                                 constant float3 *normals [[ buffer(1) ]],
                                 constant ushort *indices [[ buffer(2) ]],
                                 constant float4x4 &projection [[ buffer(10) ]],
                                 constant float4x4 &model [[ buffer(11) ]],
                                 constant float3x3 &normMatrix [[ buffer(12) ]],
                                 uint vertexID [[ vertex_id ]]) {
    auto index = vertexID / 2;
    auto vertexIndex = indices[index];
    float4 position = model * float4(positions[vertexIndex], 1);
    if (index * 2 != vertexID) {
        float3 normal = normals[vertexIndex];
        auto norm = normMatrix * normalize(normal);
        position = float4(norm * 0.02 + position.xyz, 1);
    }
    
    return projection * position;
}

fragment float4 normal_fragment_main() {
    return float4(1, 1, 0, 1);
}
