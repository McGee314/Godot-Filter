shader_type spatial;
render_mode depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// === PSX TEXTURE LAYERS ===
// Beach/coastal textures (low elevation)
uniform sampler2D sand_texture: source_color, hint_default_white;
uniform sampler2D sand_normal: hint_normal;

// Grass textures (medium-low elevation)
uniform sampler2D grass_texture: source_color, hint_default_white;
uniform sampler2D grass_normal: hint_normal;

// Dirt/soil textures (medium elevation)
uniform sampler2D dirt_texture: source_color, hint_default_white;
uniform sampler2D dirt_normal: hint_normal;

// Rock textures (high elevation)
uniform sampler2D rock_texture: source_color, hint_default_white;
uniform sampler2D rock_normal: hint_normal;

// Snow textures (highest elevation)
uniform sampler2D snow_texture: source_color, hint_default_white;
uniform sampler2D snow_normal: hint_normal;

// === BLENDING PARAMETERS ===
uniform float height_scale: hint_range(0.1, 50.0) = 10.0;
uniform float sand_level: hint_range(0.0, 1.0) = 0.1;
uniform float grass_level: hint_range(0.0, 1.0) = 0.3;
uniform float dirt_level: hint_range(0.0, 1.0) = 0.5;
uniform float rock_level: hint_range(0.0, 1.0) = 0.7;
uniform float snow_level: hint_range(0.0, 1.0) = 0.9;

// === TEXTURE SCALES ===
uniform float sand_scale: hint_range(0.1, 20.0) = 8.0;
uniform float grass_scale: hint_range(0.1, 20.0) = 12.0;
uniform float dirt_scale: hint_range(0.1, 20.0) = 6.0;
uniform float rock_scale: hint_range(0.1, 20.0) = 4.0;
uniform float snow_scale: hint_range(0.1, 20.0) = 3.0;

// === SLOPE PARAMETERS ===
uniform float slope_threshold: hint_range(0.0, 1.0) = 0.6;
uniform float slope_blend: hint_range(0.0, 1.0) = 0.3;

// === PSX STYLE PARAMETERS ===
uniform float color_quantization: hint_range(1.0, 64.0) = 16.0;
uniform float dither_strength: hint_range(0.0, 1.0) = 0.3;
uniform bool enable_psx_style: hint_default = true;

varying float world_height;
varying vec3 world_normal;
varying vec3 world_position;

void vertex() {
    world_height = VERTEX.y / height_scale;
    world_normal = NORMAL;
    world_position = VERTEX;
}

void fragment() {
    // Calculate normalized height (0-1)
    float height = clamp(world_height, 0.0, 1.0);
    
    // Calculate slope factor (how steep the surface is)
    float slope = 1.0 - abs(dot(world_normal, vec3(0.0, 1.0, 0.0)));
    
    // Sample textures at different scales for variety
    vec2 sand_uv = UV * sand_scale;
    vec2 grass_uv = UV * grass_scale;
    vec2 dirt_uv = UV * dirt_scale;
    vec2 rock_uv = UV * rock_scale;
    vec2 snow_uv = UV * snow_scale;
    
    // Sample color textures
    vec3 sand_color = texture(sand_texture, sand_uv).rgb;
    vec3 grass_color = texture(grass_texture, grass_uv).rgb;
    vec3 dirt_color = texture(dirt_texture, dirt_uv).rgb;
    vec3 rock_color = texture(rock_texture, rock_uv).rgb;
    vec3 snow_color = texture(snow_texture, snow_uv).rgb;
    
    // Sample normal maps
    vec3 sand_norm = texture(sand_normal, sand_uv).rgb * 2.0 - 1.0;
    vec3 grass_norm = texture(grass_normal, grass_uv).rgb * 2.0 - 1.0;
    vec3 dirt_norm = texture(dirt_normal, dirt_uv).rgb * 2.0 - 1.0;
    vec3 rock_norm = texture(rock_normal, rock_uv).rgb * 2.0 - 1.0;
    vec3 snow_norm = texture(snow_normal, snow_uv).rgb * 2.0 - 1.0;
    
    // Height-based blending weights
    float sand_weight = smoothstep(sand_level + 0.1, sand_level - 0.1, height);
    float grass_weight = smoothstep(grass_level - 0.1, grass_level + 0.1, height) * 
                        smoothstep(grass_level + 0.2, grass_level, height);
    float dirt_weight = smoothstep(dirt_level - 0.1, dirt_level + 0.1, height) * 
                       smoothstep(dirt_level + 0.2, dirt_level, height);
    float rock_weight = smoothstep(rock_level - 0.1, rock_level + 0.1, height) * 
                       smoothstep(rock_level + 0.2, rock_level, height);
    float snow_weight = smoothstep(snow_level - 0.1, snow_level + 0.1, height);
    
    // Slope-based rock blending (steep slopes = more rock)
    float slope_rock = smoothstep(slope_threshold - slope_blend, slope_threshold + slope_blend, slope);
    rock_weight = max(rock_weight, slope_rock);
    
    // Normalize weights so they add up to 1.0
    float total_weight = sand_weight + grass_weight + dirt_weight + rock_weight + snow_weight;
    if (total_weight > 0.0) {
        sand_weight /= total_weight;
        grass_weight /= total_weight;
        dirt_weight /= total_weight;
        rock_weight /= total_weight;
        snow_weight /= total_weight;
    }
    
    // Blend colors based on weights
    vec3 final_color = sand_color * sand_weight + 
                      grass_color * grass_weight + 
                      dirt_color * dirt_weight +
                      rock_color * rock_weight + 
                      snow_color * snow_weight;
    
    // Blend normals based on weights
    vec3 final_normal = sand_norm * sand_weight + 
                       grass_norm * grass_weight + 
                       dirt_norm * dirt_weight +
                       rock_norm * rock_weight + 
                       snow_norm * snow_weight;
    
    // PSX-style color quantization (optional retro effect)
    if (enable_psx_style) {
        final_color = floor(final_color * color_quantization) / color_quantization;
        
        // Simple dithering effect
        float dither = fract(sin(dot(UV * 100.0, vec2(12.9898, 78.233))) * 43758.5453);
        final_color += (dither - 0.5) * dither_strength / color_quantization;
    }
    
    ALBEDO = final_color;
    NORMAL_MAP = final_normal;
    ROUGHNESS = 0.8;
    METALLIC = 0.0;
}
