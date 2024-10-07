extends TextureButton

@export var hotbar_centre: TextureRect
@export var pressed_texture: Texture2D
const default_tex = preload("res://assets/textures/input_prompts/xbox_dpad_none.png")

func _on_pressed() -> void:
	hotbar_centre.texture = pressed_texture
	get_tree().create_timer(0.1).timeout
	hotbar_centre.texture = default_tex
