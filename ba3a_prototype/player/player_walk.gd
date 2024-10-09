extends CharacterBody3D

const SPEED = 6.0

# cam vars
var in_camera: bool = false
var cam_zoom_speed := 50.0
var photos_taken := 0

# notebook vars
var in_notebook: bool = false
var notebook: Notebook

# misc vars
var last_input_dir := Vector2.ZERO
var last_move_direction := Vector3.ZERO
var stored_camera_rig_rotation: Vector3

# onready vars
@onready var mesh: MeshInstance3D = $mesh
@onready var camera_rig: Node3D = $camera_rig
@onready var walk_camera: Camera3D = $camera_rig/SpringArm3D/camera
@onready var photo_camera: Camera3D = $photo_camera_rig/photo_camera
@onready var photo_camera_rig: Node3D = $photo_camera_rig
@onready var photo_viewport_camera: Camera3D = $camera_viewport/photo_viewport_camera
@onready var photo_cam_control: Node3D = $photo_camera_rig/photo_camera/photo_cam_control
@onready var camera_viewport: SubViewport = $camera_viewport
@onready var ui_parent: Control = $CanvasLayer/ui_parent
@onready var ui_anims: AnimationPlayer = $CanvasLayer/ui_top/ui_anims


# preloads
const PHOTO_SHOWCASE = preload("res://ui/photography/photo_showcase.tscn")
const NOTEBOOK = preload("res://ui/notebook/notebook.tscn")

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("enable_world_bend", true)

func _physics_process(delta: float) -> void:
	if can_move():
		handle_movement(delta)
		handle_camera_rotation(delta)
		move_and_slide()
	
	if in_camera:
		handle_photo_camera_rotation(delta)
		handle_photo_camera_zoom(delta)
	
	handle_camera_rot_matching()

func handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	# keyboard
	input_dir += Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# controller
	var joy_vector := Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	
	if joy_vector.length() > Settings.DEADZONE:
		input_dir += joy_vector.normalized() * ((joy_vector.length() - Settings.DEADZONE) / (1 - Settings.DEADZONE))
	
	if input_dir.length() > 1:
		input_dir = input_dir.normalized()
		last_input_dir = input_dir

	
	var direction := (camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED
		last_move_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_camera_rotation(delta: float) -> void:
	var joy_vector := Vector2.ZERO
	joy_vector.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	joy_vector.y = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	if joy_vector.length() > Settings.DEADZONE and can_move():
		# manual camera rotation 
		# left/right
		camera_rig.rotation.y -= joy_vector.x * Settings.CAM_ROTATE_SENS * delta
		
		## up/down
		camera_rig.rotation.x -= deg_to_rad(-joy_vector.y) * Settings.CAM_ROTATE_SENS
		camera_rig.rotation.x = clamp(camera_rig.rotation.x, deg_to_rad(-60), deg_to_rad(0))
		
	#elif last_move_direction.length() > 0.1 and velocity.length() > 0 and last_input_dir.y < 0:
		## automatic camera following
		#var target_angle = atan2(-last_move_direction.x, -last_move_direction.z)
		#camera_rig.rotation.y = lerp_angle(camera_rig.rotation.y, target_angle, 0.3 * delta)

func handle_photo_camera_rotation(delta: float) -> void:
	var joy_vector := Vector2.ZERO
	joy_vector.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	joy_vector.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	if joy_vector.length() > Settings.DEADZONE and in_camera:
		# left/right
		photo_camera_rig.rotate_y(deg_to_rad(-joy_vector.x) * Settings.CAM_ROTATE_SENS)
		
		# up/down
		photo_camera.rotate_x(deg_to_rad(-joy_vector.y) * Settings.CAM_ROTATE_SENS)
		photo_camera.rotation.x = clamp(photo_camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func handle_photo_camera_zoom(delta: float) -> void:
	var cam_zoom := (Input.get_action_strength("camera_zoom_out") - Input.get_action_strength("camera_zoom_in")) * delta
	photo_viewport_camera.fov += cam_zoom * cam_zoom_speed
	
	# clamp fov
	photo_viewport_camera.fov = clamp(photo_viewport_camera.fov, 20.0, 75.0)

func handle_camera_rot_matching():
	if in_camera:
		# make base camera face same direction
		camera_rig.rotation.y = photo_camera_rig.rotation.y
	else:
		# make photo camera face same direction as base camera
		photo_camera_rig.rotation.y = camera_rig.rotation.y

func can_move() -> bool:
	if in_camera:
		return false
	if in_notebook:
		return false
	return true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter_camera") and can_move():
		if in_camera:
			camera_transition(false)
		else:
			camera_transition(true)
	if event.is_action_pressed("take_picture") and in_camera:
		take_picture()
	if event.is_action_pressed("enter_notebook"):
		if in_notebook:
			close_notebook()
		else:
			var n = NOTEBOOK.instantiate() as Notebook # open notebook
			n.notebook_closed.connect(close_notebook)
			ui_parent.add_child(n)
			notebook = n
	if event.is_action_pressed("ui_cancel"):
		if in_camera:
			camera_transition(false)
		elif in_notebook:
			close_notebook()

func close_notebook():
	if notebook: # close notebook
		notebook.queue_free()
		notebook = null

### camera functions ###

func camera_transition(to_photo: bool):
	if to_photo:
		in_camera = true
		
		stored_camera_rig_rotation = camera_rig.rotation
		
		var previous_pos = walk_camera.global_position
		var previous_rot = walk_camera.rotation
		
		var t1 = get_tree().create_tween()
		t1.tween_property(walk_camera, "global_position", photo_camera.global_position, 0.2).set_ease(Tween.EASE_IN_OUT)
		var t2 = get_tree().create_tween()
		t2.tween_property(walk_camera, "rotation", photo_camera.rotation, 0.2).set_ease(Tween.EASE_IN_OUT)
		await t2.finished
		
		# set current cam
		photo_camera.current = true
		
		# show cam
		photo_cam_control.visible = true
		
		# hide mesh
		mesh.visible = false
		
		# reset walk cam
		walk_camera.global_position = previous_pos
		walk_camera.rotation = previous_rot
		
	else:
		in_camera = false
		
		var previous_pos = photo_camera.global_position
		var previous_rot = photo_camera.rotation
		
		var t1 = get_tree().create_tween()
		t1.tween_property(photo_camera, "global_position", walk_camera.position, 0.2).set_ease(Tween.EASE_IN_OUT)
		var t2 = get_tree().create_tween()
		t2.tween_property(photo_camera, "global_rotation", walk_camera.rotation, 0.2).set_ease(Tween.EASE_IN_OUT)
		await t2.finished
		
		walk_camera.current = true
		
		camera_rig.rotation = stored_camera_rig_rotation
		
		# reset photo cam
		photo_camera.global_position = previous_pos
		photo_camera.rotation = previous_rot
		
		# hide cam
		photo_cam_control.visible = false
		
		# show mesh
		mesh.visible = true
		
		# reset camera zoom
		photo_viewport_camera.fov = 65.0

func take_picture():
	ui_anims.play("flash")
	var image = camera_viewport.get_texture().get_image()
	
	var photo := Photo.new()
	photo.id = photos_taken
	for entity_name in PhotoManager.onscreen_entities:
		photo.contains.append(entity_name)
	photo.image = image
	
	var ps = PHOTO_SHOWCASE.instantiate() as PhotoShowcase
	ui_parent.add_child(ps)
	ps.setup(photo)
	
	camera_transition(false)
	
	PhotoManager.album.append(photo)
