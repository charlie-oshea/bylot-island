extends Node3D
class_name IslandLocation

@export var _name: String
@export var scene_path: String
@export var level_id: int

var overlap := false

@onready var island_label: Label3D = $island_label

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and overlap:
		get_tree().change_scene_to_file(scene_path)

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("boat"):
		overlap = true
		island_label.text = str(_name, "\nPress A to Dock")

func _on_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("boat"):
		overlap = false
		island_label.text = ""
