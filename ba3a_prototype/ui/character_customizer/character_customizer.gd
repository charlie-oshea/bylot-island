extends Control

@onready var player_mesh: MeshInstance3D = $root/player_mesh
@onready var hat_mesh: MeshInstance3D = $root/player_mesh/hat_mesh 

const hood_mesh = preload("res://assets/models/characters/player/hats/sm_hood.res")
const glasses_mesh = preload("res://assets/models/characters/player/hats/sm_glasses.res")
var rotate: float = 0.0

func _ready() -> void:
	Autoload.hat_changed.connect(update_hat)
	update_hat()

func update_hat():
	# customization setup
	match Autoload.player_hat:
		Autoload.Hats.NONE:
			hat_mesh.hide()
		Autoload.Hats.HOOD:
			hat_mesh.show()
			hat_mesh.mesh = hood_mesh
		Autoload.Hats.GLASSES:
			hat_mesh.show()
			hat_mesh.mesh = glasses_mesh

func _physics_process(delta: float) -> void:
	var rotate_input = Input.get_action_strength("category_forward") - Input.get_action_strength("category_back")
	if rotate_input:
		rotate = rotate_input * 5.0 * delta
	else:
		rotate = lerp(rotate, 0.0, 5.0 * delta)
	
	player_mesh.rotation.y += rotate
