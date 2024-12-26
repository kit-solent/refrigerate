shader_type canvas_item;

uniform vec2 direction;
uniform float speed;
uniform float density;

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
} // TODO

void fragment() {
	if (random(UV) < 0.05) {
		COLOR = vec4(1.0, 0.0, 0.0, 1.0);
	} else {
		COLOR = vec4(0.0, 1.0, 0.0, 1.0);
	};
}