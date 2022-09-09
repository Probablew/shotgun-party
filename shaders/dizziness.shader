// Dizziness shader by ic3bug
// From Godot Shotgun Party https://github.com/ic3bug/godot-shotgun-party
// Licensed under the MIT License
shader_type canvas_item;

uniform float dizziness = 0.0;

void fragment() {
	float b = UV.x * sin(TIME * 10.0) + UV.y * cos(TIME * 10.0);
	b *= 0.01 * dizziness;
	COLOR = texture(TEXTURE, vec2(UV.x + b, UV.y));
}