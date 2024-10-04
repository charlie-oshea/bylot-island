shader_type spatial;
render_mode world_vertex_coords, unshaded, cull_disabled;

group_uniforms fragment;
uniform vec3 water_colour: source_color = vec3(1.0);
uniform vec3 foam_colour: source_color = vec3(1.0);
uniform sampler2D water_noise: filter_linear_mipmap;
uniform vec2 noise_uv_scale = vec2(1.0);
uniform vec2 noise_uv_speed = vec2(0.0);
uniform sampler2D water_noise_2: filter_linear_mipmap;

group_uniforms vertex;
global uniform float world_bend_curvature;
global uniform bool enable_world_bend;

void vertex() {
	if (enable_world_bend) {
		vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
		vec3 world_camera_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
		float new_y_z = pow((VERTEX - world_camera_pos).z, 2.0) * (-world_bend_curvature);
		float new_y_x = pow((VERTEX - world_camera_pos).x, 2.0) * (-world_bend_curvature);
		VERTEX = VERTEX + vec3(0.0, new_y_z + new_y_x, 0.0);
	}
}

void fragment() {
	float noise_1 = texture(water_noise, mod(UV * noise_uv_scale + TIME * noise_uv_speed, 1.0)).r;
	float noise_2 = texture(water_noise_2, mod(UV * noise_uv_scale * vec2(0.7, 0.8) + TIME * -noise_uv_speed, 1.0)).r;
	float noise = noise_1 * noise_2;
	
	ALBEDO = mix(water_colour, foam_colour, noise);
	
	ROUGHNESS = 1.0;
	SPECULAR = 1.0;
	METALLIC = 0.0;
}
