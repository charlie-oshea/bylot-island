extends Node

signal drone_unlock
signal notebook_unlock

var player_ref: PlayerWalk

var drone_unlocked: bool = false
var notebook_unlocked: bool = false

func _ready() -> void:
	Dialogic.start("res://dialogue/timelines/preload_timeline.dtl")

func unlock_drone():
	drone_unlock.emit()
	drone_unlocked = true

func unlock_notebook():
	notebook_unlock.emit()
	notebook_unlocked = true
