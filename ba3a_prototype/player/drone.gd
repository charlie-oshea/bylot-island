extends CharacterBody3D

var enabled: bool = false
var speed := 500.0
var cam_zoom_speed := 50.0

@onready var camera_rig: Node3D = $drone_camera_rig
@onready var camera: Camera3D = $drone_camera_rig/drone_camera
@onready var player: PlayerWalk = $".."
@onready var drone_noise: TextureRect = $"../CanvasLayer/ui_top/drone_noise"

func _ready() -> void:
	visible = false

func _physics_process(delta: float) -> void:
	if enabled:
		handle_camera_zoom(delta)
		
		var joy_vector_r := Vector2.ZERO
		joy_vector_r.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		joy_vector_r.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		
		var joy_vector_l := Vector2.ZERO
		joy_vector_l.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		joy_vector_l.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		
		var input_velocity := Vector3.ZERO
		
		if joy_vector_r.length() > Settings.DEADZONE:
			# left/right
			rotation.y -= joy_vector_r.x * Settings.CAM_ROTATE_SENS * delta
			
			# up/down
			camera_rig.rotation.x -= deg_to_rad(joy_vector_r.y) * Settings.CAM_ROTATE_SENS
			camera_rig.rotation.x = clamp(camera_rig.rotation.x, deg_to_rad(-40), deg_to_rad(40))
		
		if joy_vector_l.length() > Settings.DEADZONE:
			# up/down
			var forward_dir := -transform.basis.z.normalized()
			
			input_velocity += forward_dir * -joy_vector_l.y * speed * delta
			
			# left/right
			var side_dir := transform.basis.x.normalized()
			
			input_velocity += side_dir * joy_vector_l.x * speed * delta
		
		if Input.is_action_pressed("drone_up") or Input.is_action_pressed("drone_down"):
			var y_input = Input.get_action_strength("drone_up") - Input.get_action_strength("drone_down")
			input_velocity.y += y_input * speed * delta
		
		velocity.x = move_toward(velocity.x, input_velocity.x, 3.0 * delta)
		velocity.y = move_toward(velocity.y, input_velocity.y, 3.0 * delta)
		velocity.z = move_toward(velocity.z, input_velocity.z, 3.0 * delta)
		
		
		move_and_slide()
		
		clamp_position()

func clamp_position():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > 15.0:
		var t = get_tree().create_tween()
		t.tween_property(drone_noise, "modulate", Color(1,1,1,1), 1.0)
	else:
		var t = get_tree().create_tween()
		t.tween_property(drone_noise, "modulate", Color(1,1,1,0), 1.0)
	global_position.y = clamp(global_position.y, 0.0, 30.0)

func enable():
	enabled = true
	
	camera.current = true

func disable():
	enabled = false
	
	rotation = Vector3(0.0, 180.0, 0.0)
	
	camera.fov = 65.0

func handle_camera_zoom(delta: float) -> void:
	var cam_zoom := (Input.get_action_strength("camera_zoom_out") - Input.get_action_strength("camera_zoom_in")) * delta
	camera.fov += cam_zoom * cam_zoom_speed
	
	# clamp fov
	camera.fov = clamp(camera.fov, 20.0, 75.0)
