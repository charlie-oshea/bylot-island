@tool
extends AnimationPlayer

func _ready() -> void:
	play("idle")

func _on_animation_finished(anim_name: StringName) -> void:
	play("idle")
