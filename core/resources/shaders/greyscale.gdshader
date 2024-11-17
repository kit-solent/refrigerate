shader_type canvas_item;

void fragment() {
    // Sample the texture at the current UV
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate grayscale using a weighted average
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Set the color to grayscale while keeping alpha
    COLOR = vec4(vec3(gray), tex_color.a);
}
