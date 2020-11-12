shader_type canvas_item;

uniform vec3 core_color;
uniform vec3 halo_color;

uniform float core_radius;
uniform float falloff_scale;

void fragment() {
    vec2 v = UV - vec2(0.5, 0.5);
    float r = length(v);
    if (r < core_radius) {
        COLOR = vec4(core_color, 1.0);
    } else {
        float fraction = 1.0 - exp(-(r - core_radius) / falloff_scale);
        vec3 result = mix(core_color, halo_color, fraction);
        COLOR = mix(vec4(result, 1.0), vec4(0, 0, 0, 0), fraction);
    }
}

