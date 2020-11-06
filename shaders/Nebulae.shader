// ref: https://wwwtyro.net/2016/10/22/2D-space-scene-procgen.html

shader_type canvas_item;

uniform sampler2D noise_source;
uniform int neb_steps;
uniform float neb_factor;
uniform float neb_scale;
uniform float neb_density;
uniform float neb_falloff;
uniform vec3 neb_color;
uniform vec2 neb_offset;

float normalnoise(vec2 p) {
  return texture(noise_source, p).r * 0.5 + 0.5;
}

float noise(vec2 p) {
  p += neb_offset;

  float scale = pow(2.0, float(neb_steps));
  float displace = 0.0;

  for (int i = 0; i < neb_steps; i++) {
    displace = normalnoise(p * scale + displace);
    scale *= 0.5;
  }

  return normalnoise(p + displace);
}

void fragment() {
  float n = noise(UV * neb_scale);
  n = pow(n + neb_density, neb_falloff);
  COLOR = vec4(neb_color, neb_factor * n);
}

// void fragment() {
//   COLOR = texture(TEXTURE, UV);
//   if (COLOR[0] < 0.8) {
//     COLOR = vec4(0.0,0.0,0.0,1.0);
//   }
// }
