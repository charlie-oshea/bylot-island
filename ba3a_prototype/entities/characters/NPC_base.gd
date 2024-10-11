extends Node3D
class_name NPC_Base

@export var dialogue_timeline: DialogicTimeline
@export var interact_body: InteractBody

func _ready() -> void:
	interact_body.interacted.connect(interact)

func interact() -> void:
	var layout := Dialogic.start(dialogue_timeline)
	layout.register_character("res://dialogue/characters/villager_1.dch", $text_marker)
	layout.register_character("res://dialogue/characters/player.dch", Autoload.player_ref.text_marker)
