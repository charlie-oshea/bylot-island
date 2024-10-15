extends Button
class_name CustomizeButton

@export var center_control: Control

func _ready() -> void:
	pivot_offset = Vector2(size.x/2.0, size.y/2.0)
	

func _process(delta: float) -> void:
	if has_focus():
		if Input.is_action_just_pressed("ui_right"):
			right()
		elif Input.is_action_just_pressed("ui_left"):
			left()

func enter_focus():
	var t = get_tree().create_tween()
	t.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func leave_focus():
	var t = get_tree().create_tween()
	t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _pressed() -> void:
	var t = get_tree().create_tween()
	t.tween_property(self, "scale", Vector2(1.3, 1.3), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await t.finished
	var t2 = get_tree().create_tween()
	t2.tween_property(self, "scale", Vector2(1.2, 1.2), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	

func right() -> void:
	pass

func left() -> void:
	pass
