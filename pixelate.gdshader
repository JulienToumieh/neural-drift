shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform int pixel_size : hint_range(1, 64) = 8; // Adjust pixel size for more/less pixelation
uniform vec2 screen_size = vec2(1280.0, 720.0); // Set your screen resolution here

void fragment() {
    // Calculate pixel block coordinates, rounding down to the nearest block
    vec2 pixel_coords = floor(FRAGCOORD.xy / float(pixel_size)) * float(pixel_size);
    
    // Ensure pixel coordinates are within screen bounds, no wrapping needed
    pixel_coords = min(pixel_coords, screen_size - float(pixel_size));
    
    // Convert to UV coordinates (making sure they stay in the [0, 1] range)
    vec2 uv = pixel_coords / screen_size;
    
    // Sample the screen texture at the pixel block coordinate
    COLOR = texture(SCREEN_TEXTURE, uv);
}
