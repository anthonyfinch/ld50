extends Control

export(Resource) var game_events

onready var _ui_overlay = $UIOverlay

var _paused = false


func _ready():
	assert(game_events != null, "Please set game events resource")
	_ui_overlay.visible = false

	game_events.connect("unpause", self, "_unpause")


func _input(event):
	if event.is_action_released("toggle_pause"):
		_paused = not _paused
		_ui_overlay.visible = _paused


func _unpause():
	_paused = false
	_ui_overlay.visible = _paused
