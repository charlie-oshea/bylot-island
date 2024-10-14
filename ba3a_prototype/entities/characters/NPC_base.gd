extends Node3D
class_name NPC_Base

@export var dialogue_timeline: DialogicTimeline
@export var character_filepath: String
@export var interact_body: InteractBody
@export var ui_marker: Node3D

func _ready() -> void:
	interact_body.interacted.connect(interact)

func interact() -> void:
	var layout := Dialogic.start(dialogue_timeline)
	layout.register_character(character_filepath, $text_marker)

func get_canvas_pos() -> Vector2:
	return get_viewport().get_camera_3d().unproject_position(ui_marker.global_position)
