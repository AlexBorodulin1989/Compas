//
//  NormalsShader.metal
//  Compass
//
//  Created by Aleksandr Borodulin on 13.07.2025.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 normal_vertex_main(constant float4 *positions [[ buffer(0) ]],
                                 constant float4 *normals [[ buffer(1) ]],
                                 constant ushort *indices [[ buffer(2) ]],
                                 constant float4x4 &projection [[ buffer(10) ]],
                                 constant float3x3 &normProjection [[ buffer(11) ]],
                                 uint vertexID [[ vertex_id ]]) {
    auto index = vertexID / 2;
    auto vertexIndex = indices[index];
    float4 position = projection * positions[vertexIndex];
    if (index * 2 != vertexID) {
        float4 normal = normals[vertexIndex];
        auto norm = normProjection * normalize(normal.xyz);
        position = float4(norm * 0.1 + position.xyz, 1);
    }
    
    return position;
}

fragment float4 normal_fragment_main() {
    return float4(1, 1, 0, 1);
}
