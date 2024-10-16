extends Node

var album : Array[Photo]

var onscreen_entities: Array[Notifier]

@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

func find_closest_entity() -> String:
	var player_pos = Autoload.player_ref.global_position
	var shortest_distance := 999999
	var shortest_name: String
	for entity in onscreen_entities:
		var dist = entity.global_position.distance_to(player_pos)
		if dist < shortest_distance:
			shortest_distance = dist
			shortest_name = entity.entity_name
	
	return shortest_name

func book_collect():
	animation_player.play("collect_book")

func drone_collect():
	animation_player.play("collect_drone")
