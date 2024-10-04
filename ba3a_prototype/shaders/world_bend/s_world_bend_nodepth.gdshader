shader_type spatial;
render_mode world_vertex_coords, unshaded, cull_disabled, depth_test_disabled;

group_uniforms fragment;
uniform sampler2D albedo_texture: filter_linear_mipmap, source_color ,hint_default_white;
uniform bool use_texture = true;
uniform vec3 albedo_colour: source_color = vec3(1.0);
uniform bool triplanar;

group_uniforms vertex;
uniform float curvature_amount: hint_range(0.0, 1.0, 0.0015) = 0.005;
global uniform float world_bend_curvature;

group_uniforms distance_fade;
uniform bool distance_fade = false;
uniform float distance_fade_min : hint_range(0.0, 4096.0, 0.01) = 0.0;
uniform float distance_fade_max : hint_range(0.0, 4096.0, 0.01) = 10.0;

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
	// *** UNUSED TRIPLANAR ***
	//if (triplanar) {
		//vec4 projected_coords = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
		//vec3 albedoX = texture(albedo_texture, projected_coords.zy).rgb;
		//vec3 albedoY = texture(albedo_texture, projected_coords.xz).rgb;
		//vec3 albedoZ = texture(albedo_texture, projected_coords.xy).rgb;
		//vec3 world_normal = abs(INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
		//vec3 normal_weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);
		//
		//ALBEDO = albedoX * normal_weights.x + albedoY * normal_weights.y + albedoZ * normal_weights.z;
	//} else {
	if (use_texture) {
		ALBEDO = texture(albedo_texture, UV).rgb;
	} else {
		ALBEDO = albedo_colour;
	}
	
	ROUGHNESS = 1.0;
	SPECULAR = 1.0;
	METALLIC = 0.0;
	
	if (distance_fade) {
		// Distance Fade: Object Dither
		float fade_distance = length((VIEW_MATRIX * MODEL_MATRIX[3]));
		
		// Use interleaved gradient noise, which is fast but still looks good.
		const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		float fade = clamp(smoothstep(distance_fade_min, distance_fade_max, fade_distance), 0.0, 1.0);
		// Use a hard cap to prevent a few stray pixels from remaining when past the fade-out distance.
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
		
		//// Distance Fade: Pixel Dither
		//float fade_distance = length(VERTEX);
//
		//// Use interleaved gradient noise, which is fast but still looks good.
		//const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		//float fade = clamp(smoothstep(distance_fade_min, distance_fade_max, fade_distance), 0.0, 1.0);
		//// Use a hard cap to prevent a few stray pixels from remaining when past the fade-out distance.
		//if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			//discard;
		//}
	}
}
