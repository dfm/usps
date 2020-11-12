shader_type canvas_item;

uniform vec3 color1;
uniform vec3 color2;

uniform float quant;

uniform float a1;
uniform float b1;
uniform float c1;

uniform float a2;
uniform float b2;
uniform float c2;

uniform float a3;
uniform float b3;
uniform float c3;

void fragment() {
    vec2 v = UV - vec2(0.5, 0.5);
    float r = length(v);
    if (r < 0.5) {
        float x = v.x;
        float z = v.y;
        float y = sqrt(1.0 - x * x - z * z);
        float phi = atan(y, x);
        float theta = acos(z);
        float amp = a1 * (0.5 + 0.5 * sin(b1 * theta + c1 * phi));
        amp += a2 * (0.5 + 0.5 * sin(b2 * theta + c2 * phi));
        amp += a3 * (0.5 + 0.5 * sin(b3 * theta + c3 * phi));
        amp /= (a1 + a2 + a3);
        amp = round(quant * amp) / quant;
        COLOR = vec4(mix(color1, color2, amp), 1.0);
    } else {
        COLOR = vec4(0, 0, 0, 0);
    }
}
