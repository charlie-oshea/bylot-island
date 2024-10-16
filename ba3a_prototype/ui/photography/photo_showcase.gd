extends Control
class_name PhotoShowcase
signal showcased_closed

# onready vars
@onready var texture_rect: TextureRect = $CenterContainer/texture_rect
@onready var photo_info: Label = $photo_info

func _ready() -> void:
	get_tree().paused = true

func setup(photo: Photo):
	var texture = ImageTexture.create_from_image(photo.image)
	texture_rect.texture = texture
	photo_info.text = str(photo.id," - ", photo.entity)

func close_showcase():
	showcased_closed.emit()
	queue_free()
	
	get_tree().paused = false
