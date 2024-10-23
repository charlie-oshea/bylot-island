extends Control

@export var page_info: WildlifePageInfo

@onready var name_label: Label = $notebook_base/name_label
@onready var sciname_label: Label = $notebook_base/sciname_label
@onready var collected_label: Label = $notebook_base/collected_label
@onready var image: TextureRect = $notebook_base/image
@onready var info_label: RichTextLabel = $notebook_base/info_label



func _ready() -> void:
	if page_info:
		name_label.text = page_info.animal_name
		sciname_label.text = page_info.scientific_name
		collected_label.text = "not discovered"
		image.texture = page_info.image
		info_label.text = page_info.description
