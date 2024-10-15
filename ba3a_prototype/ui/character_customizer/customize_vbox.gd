extends VBoxContainer

@onready var focus_button_control: Control = $"../../focus_button_control"

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.focus_entered.connect(move_to_active.bind(child))
	
	$name_button.grab_focus()

func move_to_active(button: Button):
	var vertical_offset = focus_button_control.global_position.y - button.global_position.y
	
	var t = get_tree().create_tween()
	t.tween_property(self, "position:y", position.y + vertical_offset, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
