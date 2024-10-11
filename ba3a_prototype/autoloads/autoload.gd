extends Node

var player_ref: PlayerWalk

func _ready() -> void:
	Dialogic.start("res://dialogue/timelines/preload_timeline.dtl")
