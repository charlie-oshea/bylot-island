extends CharacterBody3D

const SPEED = 6.0

# cam vars
var in_drone: bool = false
var cam_zoom_speed := 50.0
var photos_taken := 0

# notebook vars
var in_notebook: bool = false
var notebook: Notebook

# misc vars
var last_input_dir := Vector2.ZERO
var last_move_direction := Vector3.ZERO

# onready vars
@onready var mesh: MeshInstance3D = $mesh
@onready var camera_rig: Node3D = $camera_rig
@onready var walk_camera: Camera3D = $camera_rig/SpringArm3D/camera

@onready var ui_parent: Control = $CanvasLayer/ui_parent
@onready var ui_anims: AnimationPlayer = $CanvasLayer/ui_top/ui_anims

@onready var drone: CharacterBody3D = $drone


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
	
	if in_drone:
		pass

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

func can_move() -> bool:
	if in_drone:
		return false
	if in_notebook:
		return false
	return true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter_camera"):
		if in_drone:
			drone_transition(false)
		else:
			drone_transition(true)
	if event.is_action_pressed("take_picture") and in_drone:
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
		if in_drone:
			drone_transition(false)
		elif in_notebook:
			close_notebook()

func close_notebook():
	if notebook: # close notebook
		notebook.queue_free()
		notebook = null

### camera functions ###

func drone_transition(to_photo: bool):
	if to_photo:
		in_drone = true
		
		# set current cam
		drone.enable()
	else:
		in_drone = false
		
		drone.disable()
		walk_camera.current = true

func take_picture():
	ui_anims.play("flash")
	var image = get_viewport().get_texture().get_image()
	
	var photo := Photo.new()
	photo.id = photos_taken
	for entity_name in PhotoManager.onscreen_entities:
		photo.contains.append(entity_name)
	photo.image = image
	
	var ps = PHOTO_SHOWCASE.instantiate() as PhotoShowcase
	ui_parent.add_child(ps)
	ps.setup(photo)
	
	drone_transition(false)
	
	PhotoManager.album.append(photo)
