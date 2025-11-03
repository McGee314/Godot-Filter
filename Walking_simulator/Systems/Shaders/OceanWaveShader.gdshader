shader_type spatial;
render_mode depth_draw_opaque, diffuse_burley, specular_schlick_ggx, cull_back;

// Wave parameters
uniform float wave_speed: hint_range(0.1, 3.0) = 1.0;
uniform float wave_height: hint_range(0.0, 2.0) = 0.3;
uniform float wave_frequency: hint_range(0.1, 5.0) = 1.0;

// Color parameters
uniform vec4 shallow_color: source_color = vec4(0.4, 0.8, 1.0, 0.8);
uniform vec4 deep_color: source_color = vec4(0.0, 0.2, 0.6, 1.0);
uniform vec4 foam_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Foam parameters
uniform float foam_threshold: hint_range(0.0, 1.0) = 0.6;
uniform float foam_intensity: hint_range(0.0, 2.0) = 1.0;

// Surface properties
uniform float roughness_value: hint_range(0.0, 1.0) = 0.1;
uniform float metallic_value: hint_range(0.0, 1.0) = 0.0;

// Depth texture for shore foam (optional)
uniform sampler2D depth_texture : hint_depth_texture;

varying float wave_height_var;
varying vec3 world_position;

void vertex() {
    world_position = VERTEX;
    
    // Create multiple wave layers
    vec2 wave_uv = VERTEX.xz * 0.1 * wave_frequency;
    float time_factor = TIME * wave_speed;
    
    // Primary wave
    float wave1 = sin(wave_uv.x * 2.0 + time_factor) * wave_height;
    // Secondary wave (different frequency and phase)
    float wave2 = cos(wave_uv.y * 1.5 + time_factor * 0.8) * wave_height * 0.7;
    // Tertiary wave for complexity
    float wave3 = sin((wave_uv.x + wave_uv.y) * 0.8 + time_factor * 1.3) * wave_height * 0.4;
    
    float total_wave = wave1 + wave2 + wave3;
    VERTEX.y += total_wave;
    
    // Store wave height for foam calculation
    wave_height_var = total_wave;
    
    // Calculate normal for wave surface
    float offset = 0.1;
    float wave_x = sin((wave_uv.x + offset) * 2.0 + time_factor) * wave_height;
    float wave_z = sin(wave_uv.y * 2.0 + time_factor) * wave_height;
    
    vec3 wave_normal = normalize(vec3(wave_x - total_wave, 1.0, wave_z - total_wave));
    NORMAL = wave_normal;
}

void fragment() {
    // Simple depth-based color mixing (simplified for compatibility)
    float depth_factor = clamp(world_position.y * 0.1, 0.0, 1.0);
    
    // Mix colors based on depth
    vec3 water_color = mix(deep_color.rgb, shallow_color.rgb, depth_factor);
    
    // Calculate foam based on wave height
    float foam_factor = smoothstep(foam_threshold - 0.1, foam_threshold + 0.1, abs(wave_height_var));
    
    // Apply foam
    vec3 final_color = mix(water_color, foam_color.rgb, foam_factor * foam_intensity);
    
    ALBEDO = final_color;
    ROUGHNESS = roughness_value;
    METALLIC = metallic_value;
    ALPHA = shallow_color.a;
}
