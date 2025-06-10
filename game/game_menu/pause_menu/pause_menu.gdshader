shader_type canvas_item;
uniform sampler2D existing_screen_texture: hint_screen_texture, filter_linear_mipmap;

uniform float percent : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec3 new_color = texture(existing_screen_texture, SCREEN_UV, 0.0).rgb;
	new_color = abs(vec3(percent) - new_color);
	COLOR.rgb = new_color;
}