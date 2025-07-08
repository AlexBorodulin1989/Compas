import simd
import CoreFoundation
import MathLibrary

public class Camera {
    private let far: Float = 1
    private let near: Float = 0.1
    
    public let projMatrix: float4x4
    
    public init(aspectRatio: Float = 1) {
        let halfFovyCtg: Float = 1.327
        
        let interval = far - near
        let a = far / interval
        let b = -far * near / interval
        
        if aspectRatio > 1 { // width > height
            projMatrix = float4x4([
                float4(halfFovyCtg, 0,                       0, 0),
                float4(0,           halfFovyCtg/aspectRatio, 0, 0),
                float4(0,           0,                       a, 1),
                float4(0,           0,                       b, 0)
            ])
        } else {
            projMatrix = float4x4([
                float4(halfFovyCtg * aspectRatio, 0,           0, 0),
                float4(0,                         halfFovyCtg, 0, 0),
                float4(0,                         0,           a, 1),
                float4(0,                         0,           b, 0)
            ])
        }
    }
}
