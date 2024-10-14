extends Control

@onready var player_mesh: MeshInstance3D = $root/player_mesh

var rotate: float = 0.0



func _physics_process(delta: float) -> void:
	var rotate_input = Input.get_action_strength("category_forward") - Input.get_action_strength("category_back")
	if rotate_input:
		rotate = rotate_input * 5.0 * delta
	else:
		rotate = lerp(rotate, 0.0, 5.0 * delta)
	
	player_mesh.rotation.y += rotate
