extends Control
class_name Notebook

signal notebook_closed

@export var pages: Array[PackedScene]
var current_page: int = 0

@onready var notebook_base: Panel = $notebook_base

func _ready() -> void:
	get_tree().paused = true # pause game
	
	update_notebook()

func _exit_tree() -> void:
	get_tree().paused = false # unpause game

### page navigation ###
func update_notebook() -> void:
	for child in notebook_base.get_children():
		child.queue_free()
	
	var page = pages[current_page-1].instantiate()
	notebook_base.add_child(page)

func clamp_pages() -> void:
	current_page = clamp(current_page, 1, pages.size())

func next_page() -> void:
	current_page += 1
	clamp_pages()
	update_notebook()
	
	print("going to next page - ", current_page)

func back_page() -> void:
	current_page -= 1
	clamp_pages()
	update_notebook()
	
	print("going to previous page - ", current_page)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		next_page()
	if Input.is_action_just_pressed("ui_left"):
		back_page()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		notebook_closed.emit()
		queue_free()
