extends Node

@export var levels: Array[IslandLocation]

func _ready() -> void:
	for island in levels:
		if island.level_id > GameProgress.level:
			island.queue_free()
		print(island.level_id)
