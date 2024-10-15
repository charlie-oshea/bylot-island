extends Node

signal drone_unlock
signal notebook_unlock

signal hat_changed

# player info
var player_name: String
var player_material: ShaderMaterial

# colour
var colours := [Color("392532"), Color("80234D"), Color("4A1C39"), Color("432F50"), Color("0F4562"), Color("1BBB9B")]
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

func unlock_drone():
	drone_unlock.emit()
	drone_unlocked = true

func unlock_notebook():
	notebook_unlock.emit()
	notebook_unlocked = true

func next_hat():
	hat_index = (hat_index + 1) % hat_list.size()
	
	player_hat = hat_list[hat_index]
	
	hat_changed.emit()

func previous_hat():
	hat_index = (hat_index - 1) % hat_list.size()
	
	player_hat = hat_list[hat_index]
	
	hat_changed.emit()
