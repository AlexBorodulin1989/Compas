import simd
import CoreFoundation
import MathLibrary

public final class MetalCamera: @unchecked Sendable {
    private let far: Float = 1
    private let near: Float = 0.1
    private var _projMatrix: float4x4 = .identity
    
    public var projMatrix: float4x4 { _projMatrix }
    
    public init(aspectRatio: Float = 1) {
        setAspectRatio(aspectRatio)
    }
    
    public func setAspectRatio(_ aspectRatio: Float) {
        let halfFovyCtg: Float = 1.327
        
        let interval = far - near
        let a = far / interval
        let b = -far * near / interval
        
        if aspectRatio > 1 { // width > height
            _projMatrix = float4x4([
                float4(halfFovyCtg, 0,                       0, 0),
                float4(0,           halfFovyCtg/aspectRatio, 0, 0),
                float4(0,           0,                       a, 1),
                float4(0,           0,                       b, 0)
            ])
        } else {
            _projMatrix = float4x4([
                float4(halfFovyCtg * aspectRatio, 0,           0, 0),
                float4(0,                         halfFovyCtg, 0, 0),
                float4(0,                         0,           a, 1),
                float4(0,                         0,           b, 0)
            ])
        }
    }
}
