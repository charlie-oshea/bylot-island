extends Control

var pages: Array[PackedScene]
var current_page: int = 1

@onready var notebook_base: Panel = $notebook_base

### page navigation ###
func update_notebook() -> void:
	for child in notebook_base.get_children():
		child.queue_free()
	
	var page = pages[current_page].instantiate()
	notebook_base.add_child(page)

func clamp_pages() -> void:
	current_page = clamp(current_page, 1, pages.size())

func next_page() -> void:
	current_page += 1
	clamp_pages()
	update_notebook()

func back_page() -> void:
	current_page -= 1
	clamp_pages()
	update_notebook()
