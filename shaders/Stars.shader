shader_type canvas_item;

void fragment() {
  COLOR = texture(TEXTURE, UV);
  if (COLOR[0] < 0.8) {
    COLOR = vec4(0.0,0.0,0.0,1.0);
  }
}