// Hacky chromatic aberration from an offset texture
shader_type canvas_item;

uniform sampler2D offset : hint_white;
uniform float strength = 0.333;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float a = texture(offset, UV).r * strength * 0.01;
	color.r = texture(TEXTURE, vec2(UV.x - a, UV.y)).r;
	color.b = texture(TEXTURE, vec2(UV.x + a, UV.y)).b;
	COLOR = color;
}