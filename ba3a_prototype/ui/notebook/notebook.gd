extends Control
class_name Notebook

signal notebook_closed

var pages: Array[NotebookPage]
var current_page: int = 0

@export var categories: Array[Enums.NotebookCategories]

@onready var notebook_base: Panel = $notebook_base
@onready var contents_button: Button = $HBoxContainer/contents_button
@onready var wildlife_button: Button = $HBoxContainer/wildlife_button
@onready var fauna_button: Button = $HBoxContainer/fauna_button
@onready var album_button: Button = $HBoxContainer/album_button
@onready var resource_preloader: ResourcePreloader = $PagesPreloader
@onready var page_label: Label = $page_label


func _ready() -> void:
	for res_name in resource_preloader.get_resource_list():
		var resource = resource_preloader.get_resource(res_name)
		if resource is NotebookPage:
			pages.append(resource)
	
	get_tree().paused = true # pause game
	
	update_notebook()
	
	await get_tree().create_timer(0.1).timeout # gross
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _exit_tree() -> void:
	get_tree().paused = false # unpause game

### page navigation ###
func update_notebook() -> void:
	for child in notebook_base.get_children():
		child.queue_free()
	
	clamp_pages()
	
	var page_resource = pages[current_page-1]
	var page = page_resource.scene.instantiate()
	notebook_base.add_child(page)
	
	update_category_buttons()

func update_category_buttons():
	match pages[current_page-1].category: # UGLY
		Enums.NotebookCategories.CONTENTS:
			contents_button.disabled = false
			wildlife_button.disabled = true
			fauna_button.disabled = true
			album_button.disabled = true
		Enums.NotebookCategories.WILDLIFE:
			contents_button.disabled = true
			wildlife_button.disabled = false
			fauna_button.disabled = true
			album_button.disabled = true
		Enums.NotebookCategories.FAUNA:
			contents_button.disabled = true
			wildlife_button.disabled = true
			fauna_button.disabled = false
			album_button.disabled = true
		Enums.NotebookCategories.PHOTO_ALBUM:
			contents_button.disabled = true
			wildlife_button.disabled = true
			fauna_button.disabled = true
			album_button.disabled = false

func clamp_pages() -> void:
	current_page = clamp(current_page, 1, pages.size())

func next_page() -> void:
	current_page += 1
	clamp_pages()
	update_notebook()
	
	#print("going to next page - ", current_page)

func back_page() -> void:
	current_page -= 1
	clamp_pages()
	update_notebook()
	
	#print("going to previous page - ", current_page)

func next_category() -> void:
	var next_cat := pages[current_page-1].category + 1
	
	print(next_cat)
	
	next_cat = clamp(next_cat, 0, 3)
	
	# find first page in category
	for page in pages:
		if page.category == next_cat:
			current_page = pages.find(page) + 1
			update_notebook()
			break

func back_category() -> void:
	var prev_cat := pages[current_page-1].category - 1
	
	prev_cat = clamp(prev_cat, 0, 3)
	
	# find first page in category
	for page in pages:
		if page.category == prev_cat:
			current_page = pages.find(page) + 1
			update_notebook()
			break


func _process(delta: float) -> void:
	# page label
	page_label.text = str(current_page, "/", pages.size())
	
	if Input.is_action_just_pressed("page_forward"):
		next_page()
	if Input.is_action_just_pressed("page_back"):
		back_page()
	if Input.is_action_just_pressed("category_forward"):
		next_category()
	if Input.is_action_just_pressed("category_back"):
		back_category()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		notebook_closed.emit()
		queue_free()
