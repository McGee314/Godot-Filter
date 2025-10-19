shader_type spatial;
render_mode depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// Simple terrain textures
uniform sampler2D grass_texture: source_color;
uniform sampler2D rock_texture: source_color;
uniform sampler2D dirt_texture: source_color;

// Simple blending parameters
uniform float height_scale: hint_range(1.0, 20.0) = 5.0;
uniform float grass_level: hint_range(0.0, 1.0) = 0.3;
uniform float rock_level: hint_range(0.0, 1.0) = 0.7;

// Texture scales
uniform float texture_scale: hint_range(1.0, 10.0) = 4.0;

varying float world_height;

void vertex() {
    world_height = VERTEX.y / height_scale;
}

void fragment() {
    // Normalize height to 0-1 range
    float height = clamp(world_height, 0.0, 1.0);
    
    // Sample textures
    vec2 scaled_uv = UV * texture_scale;
    vec3 grass_color = texture(grass_texture, scaled_uv).rgb;
    vec3 rock_color = texture(rock_texture, scaled_uv).rgb;
    vec3 dirt_color = texture(dirt_texture, scaled_uv).rgb;
    
    // Simple height-based blending
    vec3 final_color = grass_color;
    
    if (height > grass_level) {
        float dirt_blend = smoothstep(grass_level, grass_level + 0.2, height);
        final_color = mix(grass_color, dirt_color, dirt_blend);
    }
    
    if (height > rock_level) {
        float rock_blend = smoothstep(rock_level, rock_level + 0.2, height);
        final_color = mix(final_color, rock_color, rock_blend);
    }
    
    ALBEDO = final_color;
    ROUGHNESS = 0.8;
    METALLIC = 0.0;
}
