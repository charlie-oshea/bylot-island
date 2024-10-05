extends CharacterBody3D

# movement vars
const MAX_SPEED = 3.0
const ACCEL = 5.0
const DECEL = 3.0

# misc vars
const LEAN_AMOUNT = 0.05  # rads
const TILT_SPEED = 5.0 
var last_velocity := Vector3.ZERO

# onready vars
@onready var mesh: Node3D = $mesh_parent/mesh
@onready var mesh_parent: Node3D = $mesh_parent
@onready var vfx_foam: GPUParticles3D = $mesh_parent/vfx_foam

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("enable_world_bend", true)

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	# keyboard input
	input_dir += Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# controller input
	var joy_vector := Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	
	if joy_vector.length() > Settings.DEADZONE:
		input_dir += joy_vector.normalized() * ((joy_vector.length() - Settings.DEADZONE) / (1 - Settings.DEADZONE))
	
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCEL * delta)
		velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)
		velocity.z = move_toward(velocity.z, 0, DECEL * delta)
	
	var vec_nor = velocity.normalized()
	if vec_nor.length() > 0.0:
		mesh_parent.rotation.y = lerp_angle(mesh_parent.rotation.y, Vector2(-vec_nor.x, vec_nor.z).angle(), 2.0 * delta)
		
		vfx_foam.emitting = true
	else:
		vfx_foam.emitting = false
	
	# calc lean
	var speed = velocity.length()
	var lean = -LEAN_AMOUNT * (speed / MAX_SPEED)
	
	# apply and lean
	mesh.rotation.z = lerp(mesh.rotation.z, lean, TILT_SPEED * delta)
	
	last_velocity = velocity
	
	move_and_slide()
