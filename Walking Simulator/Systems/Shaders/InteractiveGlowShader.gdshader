shader_type spatial;
render_mode depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// Base material properties
uniform vec4 base_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D base_texture: source_color;
uniform float roughness_value: hint_range(0.0, 1.0) = 0.3;
uniform float metallic_value: hint_range(0.0, 1.0) = 0.1;

// Glow properties
uniform vec4 glow_color: source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float glow_intensity: hint_range(0.0, 5.0) = 1.0;
uniform float pulse_speed: hint_range(0.1, 10.0) = 2.0;
uniform bool enable_pulse: hint_default = true;

// Interaction properties
uniform float hover_intensity: hint_range(0.0, 3.0) = 1.5;
uniform float selection_intensity: hint_range(0.0, 5.0) = 2.0;
uniform bool is_hovered: hint_default = false;
uniform bool is_selected: hint_default = false;

// Rim lighting
uniform float rim_power: hint_range(0.1, 10.0) = 2.0;
uniform vec4 rim_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec3 world_normal;
varying vec3 world_position;
varying vec3 view_direction;

void vertex() {
    world_normal = NORMAL;
    world_position = VERTEX;
    view_direction = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz - VERTEX;
}

void fragment() {
    // Base texture and color
    vec4 tex_color = texture(base_texture, UV);
    vec3 base_albedo = base_color.rgb * tex_color.rgb;
    
    // Calculate pulse effect
    float pulse = 1.0;
    if (enable_pulse) {
        pulse = sin(TIME * pulse_speed) * 0.3 + 0.7; // Oscillate between 0.4 and 1.0
    }
    
    // Calculate interaction intensity
    float interaction_factor = 1.0;
    if (is_selected) {
        interaction_factor = selection_intensity;
    } else if (is_hovered) {
        interaction_factor = hover_intensity;
    }
    
    // Rim lighting effect
    float rim_factor = 1.0 - abs(dot(normalize(view_direction), normalize(world_normal)));
    rim_factor = pow(rim_factor, rim_power);
    
    // Combine glow effects
    float total_glow = glow_intensity * pulse * interaction_factor;
    vec3 glow_emission = glow_color.rgb * total_glow;
    vec3 rim_emission = rim_color.rgb * rim_factor * total_glow * 0.5;
    
    // Final emission
    vec3 final_emission = glow_emission + rim_emission;
    
    ALBEDO = base_albedo;
    EMISSION = final_emission;
    ROUGHNESS = roughness_value;
    METALLIC = metallic_value;
    ALPHA = base_color.a;
}
