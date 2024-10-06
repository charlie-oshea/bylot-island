extends CharacterBody3D

const SPEED = 6.0

# cam vars
var in_camera: bool = false
var cam_zoom_speed := 50.0
var photos_taken := 0

# onready vars
@onready var mesh: MeshInstance3D = $mesh
@onready var camera_rig: Node3D = $camera_rig
@onready var walk_camera: Camera3D = $camera_rig/camera
@onready var photo_camera: Camera3D = $photo_camera_rig/photo_camera
@onready var photo_camera_rig: Node3D = $photo_camera_rig
@onready var photo_viewport_camera: Camera3D = $camera_viewport/photo_viewport_camera
@onready var photo_cam_control: Node3D = $photo_camera_rig/photo_camera/photo_cam_control
@onready var camera_viewport: SubViewport = $camera_viewport
@onready var ui_parent: Control = $CanvasLayer/ui_parent
@onready var ui_anims: AnimationPlayer = $CanvasLayer/ui_top/ui_anims


# preloads
const PHOTO_SHOWCASE = preload("res://ui/photography/photo_showcase.tscn")

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
	
	var direction := (camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_camera_rotation(delta: float) -> void:
	# 3rd person camera rotate
	var joy_rotate := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	
	if abs(joy_rotate) > Settings.DEADZONE:
		camera_rig.rotation.y -= joy_rotate * Settings.CAM_ROTATE_SENS * delta

func handle_photo_camera_rotation(delta: float) -> void:
	var joy_vector := Vector2.ZERO
	joy_vector.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	joy_vector.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	if joy_vector.length() > Settings.DEADZONE:
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
	return true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter_camera"):
		if in_camera:
			close_camera()
		else:
			open_camera()
	if event.is_action_pressed("take_picture") and in_camera:
		take_picture()

### camera functions ###
func open_camera():
	photo_camera.current = true
	in_camera = true
	
	# show cam
	photo_cam_control.visible = true
	
	# hide mesh
	mesh.visible = false


func close_camera():
	walk_camera.current = true
	in_camera = false
	
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
	
	close_camera()
	
	PhotoManager.album.append(photo)
