extends Node

var album : Array[Photo]

var onscreen_entities: Array[String]

@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

func book_collect():
	animation_player.play("collect_book")
