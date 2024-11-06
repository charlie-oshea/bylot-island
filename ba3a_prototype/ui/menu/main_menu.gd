extends Control


func _on_play_pressed() -> void:
	SceneTransition.change_scene("res://ui/character_customizer/character_customizer.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
