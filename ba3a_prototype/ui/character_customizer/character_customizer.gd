extends Control

@onready var player_mesh: MeshInstance3D = $root/player_mesh
@onready var hat_mesh: MeshInstance3D = $root/player_mesh/hat_mesh 

const hood_mesh = preload("res://assets/models/characters/player/hats/sm_hood.res")
const glasses_mesh = preload("res://assets/models/characters/player/hats/sm_glasses.res")
const player_mat = preload("res://shaders/world_bend/mats/s_bend_player.tres")
var rotate: float = 0.0

func _ready() -> void:
	player_mesh.set_surface_override_material(1, player_mat)
	
	Autoload.hat_changed.connect(update_hat)
	Autoload.colour_changed.connect(update_colour)
	update_hat()
	update_colour()

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

func update_colour():
	player_mat.set_shader_parameter("albedo_colour", Autoload.current_colour)

func _physics_process(delta: float) -> void:
	var rotate_input = Input.get_action_strength("category_forward") - Input.get_action_strength("category_back")
	if rotate_input:
		rotate = rotate_input * 5.0 * delta
	else:
		rotate = lerp(rotate, 0.0, 5.0 * delta)
	
	player_mesh.rotation.y += rotate


func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/ocean_level/ocean_level.tscn")
