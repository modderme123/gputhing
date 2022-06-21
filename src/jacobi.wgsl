struct Uniforms {
    resolution: vec2<i32>,
};
@group(0) @binding(0) var<uniform> u : Uniforms;

@group(1) @binding(0) var divergence : texture_2d<f32>;

@group(2) @binding(0) var pressure : texture_2d<f32>;

fn textureLoadFalloof(a: texture_2d<f32>, coord: vec2<i32>, coordo: vec2<i32>) -> vec2<f32> {
    var exists = existe(coord);
    var q = textureLoad(a, coord, 0).x;
    var q2 = textureLoad(a, coordo, 0).x;
    return vec2<f32>(q * exists + (1.0 - exists )*q2, exists + (1.0 - exists ));
}

@fragment
fn jacobi(@builtin(position) coords: vec4<f32>) -> @location(0) f32 {
    var coord = vec2<i32>(coords.xy);
    // left, right, bottom, and top pressure samples
    var L = textureLoadFalloof(pressure, coord - vec2<i32>(1, 0),coord + vec2<i32>(1, 0));
    var R = textureLoadFalloof(pressure, coord + vec2<i32>(1, 0),coord - vec2<i32>(1, 0));
    var B = textureLoadFalloof(pressure, coord + vec2<i32>(0, 1),coord - vec2<i32>(0, 1));
    var T = textureLoadFalloof(pressure, coord - vec2<i32>(0, 1),coord + vec2<i32>(0, 1));

    var bC = textureLoad(divergence, coord, 0).x;
    var C = textureLoad(pressure, coord, 0).x;

    // evaluate Jacobi iteration
    var sum = L + R + B + T;
    var dd = 4.0 - sum.y;
    // sum.x += C * dd;
    // sum.y += dd;
    if (sum.y < 1.0) {
        return 0.0;
    }
    return (sum.x - bC/2.0) / sum.y;
}
