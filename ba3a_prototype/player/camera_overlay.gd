extends Sprite2D


func _process(delta: float) -> void:
	global_position = lerp(global_position, get_global_mouse_position(), 3.0 * delta)
