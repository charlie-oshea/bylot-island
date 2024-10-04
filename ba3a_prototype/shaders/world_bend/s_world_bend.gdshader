shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D albedo_texture: filter_linear_mipmap;
uniform bool triplanar;

uniform float curvature_amount: hint_range(0.0, 1.0, 0.0015) = 0.005;

global uniform bool enable_world_bend;

void vertex() {
	if (enable_world_bend) {
		vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
		vec3 world_camera_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
		float new_y_z = pow((VERTEX - world_camera_pos).z, 2.0) * (-curvature_amount);
		float new_y_x = pow((VERTEX - world_camera_pos).x, 2.0) * (-curvature_amount);
		VERTEX = VERTEX + vec3(0.0, new_y_z + new_y_x, 0.0);
	}
}

void fragment() {
	if (triplanar) {
		vec4 projected_coords = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
		vec3 albedoX = texture(albedo_texture, projected_coords.zy).rgb;
		vec3 albedoY = texture(albedo_texture, projected_coords.xz).rgb;
		vec3 albedoZ = texture(albedo_texture, projected_coords.xy).rgb;
		vec3 world_normal = abs(INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
		vec3 normal_weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);
		
		ALBEDO = albedoX * normal_weights.x + albedoY * normal_weights.y + albedoZ * normal_weights.z;
	} else {
		ALBEDO = texture(albedo_texture, UV).rgb;
	}
}
