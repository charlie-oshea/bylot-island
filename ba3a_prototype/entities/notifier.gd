extends VisibleOnScreenNotifier3D
class_name Notifier

@export var entity_name: String
var on_screen: bool = false

func _ready() -> void:
	screen_entered.connect(_on_screen_entered)
	screen_exited.connect(_on_screen_exited)
	tree_exited.connect(_on_tree_exited)
	
	# set visiblity layer
	set_layer_mask_value(1, false)
	set_layer_mask_value(3, true)

func _on_screen_entered() -> void:
	PhotoManager.onscreen_entities.append(entity_name)
	
	on_screen = true

func _on_screen_exited() -> void:
	PhotoManager.onscreen_entities.erase(entity_name)
	
	on_screen = false

func _on_tree_exited() -> void:
	if on_screen:
		PhotoManager.onscreen_entities.erase(entity_name)
