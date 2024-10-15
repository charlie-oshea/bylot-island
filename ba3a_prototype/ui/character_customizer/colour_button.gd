extends CustomizeButton

func _ready() -> void:
	update_colour()

func right() -> void:
	Autoload.next_colour()
	
	update_colour()

func left() -> void:
	Autoload.previous_colour()
	
	update_colour()

func update_colour():
	self_modulate = Autoload.current_colour
