extends Resource
class_name GameState

signal updated_paused

var paused = false setget set_paused,get_paused


func set_paused(val):
	paused = val
	emit_signal("updated_paused")


func get_paused():
	return paused
