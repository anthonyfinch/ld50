extends Control

export(Resource) var game_events
export(Resource) var game_state

onready var _ui_overlay = $UIOverlay

var _paused = false


func _ready():
	assert(game_events != null, "Please set game events resource")
	assert(game_state != null, "Please set game state resource")

	_update_ui()
	game_events.connect("unpause", self, "_unpause")


func _update_ui():
	_ui_overlay.visible = game_state.paused


func _input(event):
	if event.is_action_released("toggle_pause"):
		game_state.paused = not game_state.paused
		_update_ui()


func _unpause():
	game_state.paused = false
	_update_ui()
