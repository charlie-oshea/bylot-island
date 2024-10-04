extends CharacterBody3D


const SPEED = 3.0

# onready vars
@onready var mesh: MeshInstance3D = $mesh
@onready var vfx_foam: GPUParticles3D = $mesh/vfx_foam

func _ready() -> void:
	RenderingServer.global_shader_parameter_set("enable_world_bend", true)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
	
	var vec_nor = velocity.normalized()
	if vec_nor.length() > 0.0:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, Vector2(-vec_nor.x, vec_nor.z).angle(), 2.0 * delta)
		
		vfx_foam.emitting = true
	else:
		vfx_foam.emitting = false
	
	move_and_slide()
