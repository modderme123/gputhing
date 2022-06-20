struct Uniforms {
    pixel: vec2<f32>,
};
@group(0) @binding(0) var samplerFront : sampler;
@group(0) @binding(1) var<uniform> u : Uniforms;

@group(1) @binding(0) var divergence : texture_2d<f32>;

@group(2) @binding(0) var pressure : texture_2d<f32>;

@fragment
fn jacobi(@builtin(position) coords: vec4<f32>) -> @location(0) f32 {
    var uv = coords.xy * u.pixel;
    // left, right, bottom, and top pressure samples
    var L = textureSample(pressure, samplerFront, uv - vec2<f32>(u.pixel.x, 0.0)).x;
    var R = textureSample(pressure, samplerFront, uv + vec2<f32>(u.pixel.x, 0.0)).x;
    var B = textureSample(pressure, samplerFront, uv - vec2<f32>(0.0, u.pixel.y)).x;
    var T = textureSample(pressure, samplerFront, uv + vec2<f32>(0.0, u.pixel.y)).x;

    // divergence sample, from center
    var bC = textureSample(divergence, samplerFront, uv).x;

    // evaluate Jacobi iteration
    return 0.25 * (L + R + B + T - bC);
}
