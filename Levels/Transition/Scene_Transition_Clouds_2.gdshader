shader_type canvas_item;

uniform float scrolling_speed;
uniform float opacity;

void fragment() {
	vec2 moving_uv = vec2(UV.x + TIME * scrolling_speed, UV.y);
	vec4 in_tex = texture(TEXTURE, moving_uv);
	in_tex.q *= opacity;
	COLOR = in_tex;
}
