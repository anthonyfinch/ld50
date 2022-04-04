extends Resource
class_name GameState

signal updated_paused

var paused = false setget set_paused,get_paused
var road
var last_player_offset
var next_level = "BaseLevel"


func set_paused(val):
	paused = val
	emit_signal("updated_paused")


func get_paused():
	return paused
