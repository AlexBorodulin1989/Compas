//
//  EdgeShader.metal
//  Compass
//
//  Created by Aleksandr Borodulin on 15.08.2025.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float3 pos [[attribute(0)]];
};

struct FragmentInput {
    float4 pos [[position]];
};

vertex FragmentInput edge_vert(VertexInput vert [[stage_in]],
                                 constant float4x4 &projMatrix [[ buffer(10) ]]) {
    auto pos = projMatrix * float4(vert.pos, 1);
    
    auto fragInpit = FragmentInput {
        .pos = pos
    };
    
    return fragInpit;
}

fragment float4 edge_frag(FragmentInput in [[stage_in]]) {
    return float4(0, 1, 0, 1);
}
