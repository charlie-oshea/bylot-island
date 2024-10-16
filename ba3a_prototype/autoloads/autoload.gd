extends Node

signal drone_unlock
signal notebook_unlock

signal hat_changed
signal colour_changed

# player info
var player_name: String
var player_material: ShaderMaterial = preload("res://shaders/world_bend/mats/s_bend_snow.tres")

# colour
var colours := [Color("392532"), Color("0c3332"), Color("112c4f"), Color("24311b"), Color("3e2611"), Color("511219"), Color("291241")]
var colour_id := 0
var current_colour := Color("392532")

# hats
enum Hats{NONE, HOOD, GLASSES}
var hat_list := [Hats.NONE, Hats.HOOD, Hats.GLASSES]
var hat_index := 0
var player_hat: Hats

var player_ref: PlayerWalk

var drone_unlocked: bool = false
var notebook_unlocked: bool = false

func _ready() -> void:
	Dialogic.start("res://dialogue/timelines/preload_timeline.dtl")
	
	player_material.duplicate()

func unlock_drone():
	drone_unlock.emit()
	drone_unlocked = true

func unlock_notebook():
	notebook_unlock.emit()
	notebook_unlocked = true

func next_colour():
	colour_id = (colour_id + 1) % colours.size()
	
	update_material()

func previous_colour():
	colour_id = (colour_id - 1) % colours.size()
	
	update_material()

func update_material():
	current_colour = colours[colour_id]
	
	player_material.set_shader_parameter("shader_parameter/albedo_colour", current_colour)
	
	colour_changed.emit()

func next_hat():
	hat_index = (hat_index + 1) % hat_list.size()
	
	player_hat = hat_list[hat_index]
	
	hat_changed.emit()

func previous_hat():
	hat_index = (hat_index - 1) % hat_list.size()
	
	player_hat = hat_list[hat_index]
	
	hat_changed.emit()
