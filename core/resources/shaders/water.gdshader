shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 tint:source_color = vec4(1.0);
uniform float time:hint_range(0.0, 100.0) = 0.0;
uniform float wave_amp:hint_range(0.0, 20.0) = 5.0;
uniform float wave_freq:hint_range(0.1, 10.0) = 1.0;
uniform float wave_speed:hint_range(0.1, 10.0) = 2.0;

void fragment() {
	// apply the wave distortion
	vec2 uv = UV;
	uv.y += sin(uv.x * wave_freq + time * wave_speed) * wave_amp / 100.0;
	
	vec4 color_after_distortion = texture(TEXTURE, uv);
	
	// apply the tint
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	// mix the blue tint with the color behind it (the pre-existing screen color)
	color = mix(color,tint, 0.5);
	// mix in vec4(0.5) which is a grey color to strengthen the color.
	color = mix(vec4(0.5), color, 1.4);
	
	COLOR = color;
}
