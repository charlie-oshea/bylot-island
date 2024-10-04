extends CharacterBody3D

const SPEED = 6.0

# cam vars
var in_camera: bool = false

# onready vars
@onready var mesh: MeshInstance3D = $mesh
@onready var camera_ui: Node2D = $CanvasLayer/player_ui/camera
@onready var cam_anim_player: AnimationPlayer = $CanvasLayer/player_ui/camera/cam_anim_player
@onready var camera: Camera3D = $camera_rig/camera


func _ready() -> void:
	RenderingServer.global_shader_parameter_set("enable_world_bend", true)

func _physics_process(delta: float) -> void:
	if can_move():
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED 
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		move_and_slide()
	
	if in_camera:
		get_object_under_mouse()

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
	in_camera = true
	camera_ui.visible = true

func close_camera():
	in_camera = false
	camera_ui.visible = false

func take_picture():
	cam_anim_player.play("flash")
	close_camera()

func get_object_under_mouse():
	var world_space = get_world_3d().direct_space_state
	var mouse = get_viewport().get_mouse_position()
	var start = camera.project_ray_origin(mouse)
	var end = camera.project_position(mouse, 1000.0)
	var result = world_space.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	print(result)
