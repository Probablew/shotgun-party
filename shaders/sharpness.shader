// Sharpness filter by ic3bug
// From Godot Shotgun Party https://github.com/ic3bug/godot-shotgun-party
// Licensed under the MIT License
shader_type canvas_item;

uniform float strength = 0.666;

void fragment() {
	vec4 color = vec4(0.0);
	vec2 ps = SCREEN_PIXEL_SIZE;
	color -= texture(TEXTURE, UV + vec2(-ps.x * strength, 0.0));
	color -= texture(TEXTURE, UV + vec2(0.0, -ps.y * strength));
	color -= texture(TEXTURE, UV + vec2(0.0, ps.y * strength));
	color -= texture(TEXTURE, UV + vec2(ps.x * strength, 0.0));
	color += texture(TEXTURE, UV) * 5.0;
	COLOR = color;
}