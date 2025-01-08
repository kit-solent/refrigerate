shader_type canvas_item;

uniform vec2 direction;
uniform float speed;
uniform float density;

// psudo random number generation seeded with a vec2
float random_vec2 (vec2 seed) {
    return fract(sin(dot(seed.xy,vec2(12.9898,78.233)))*43758.5453123);
}

float random_float(float seed) {
    return fract(sin(seed) * 43758.5453123);
}

void fragment() {
	//if (false) {
		//COLOR = vec4(1.0, 0.0, 0.0, 1.0);
	//} else {
		//COLOR = vec4(0.0, 1.0, 0.0, 1.0);
	//};
	COLOR = vec4(random_vec2(FRAGCOORD.xy), random_vec2(FRAGCOORD.xy + vec2(1, 1)), random_vec2(FRAGCOORD.xy + vec2(2, 1)), 1.0);
}