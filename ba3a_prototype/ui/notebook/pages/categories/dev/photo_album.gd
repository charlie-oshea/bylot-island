extends Control

@onready var photo_grid: GridContainer = $photo_grid

func _ready() -> void:
	for photo in PhotoManager.album:
		var rect = TextureRect.new()
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		rect.custom_minimum_size = Vector2(200,120)
		rect.texture = ImageTexture.create_from_image(photo.image)
		photo_grid.add_child(rect)
