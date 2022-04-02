extends Control

export(Resource) var game_events
export(Resource) var game_state

onready var _pause_screen = $UIOverlay/PauseScreen
onready var _start_screen = $UIOverlay/StartScreen
onready var _countdown_label = $UIOverlay/StartScreen/Box/CountDown
onready var _race_time_label = $UIOverlay/RaceTime

var _started = false
var _finished = false
var _race_time = 0.0
var _count_down = 3.9


func _ready():
	assert(game_events != null, "Please set game events resource")
	assert(game_state != null, "Please set game state resource")

	_start_screen.visible = true
	_update_ui()
	game_events.connect("unpause", self, "_unpause")


func _process(delta):
	if not _started:
		_count_down -= delta
		_countdown_label.text = str(floor(_count_down))

		if _count_down <= 0.0:
			game_events.start_race()
			_start_screen.visible = false
			_started = true

	elif not _finished and not game_state.paused:
		_race_time += delta
		_race_time_label.text = "%3.2f" % _race_time


func _update_ui():
	_pause_screen.visible = game_state.paused


func _input(event):
	if event.is_action_released("toggle_pause"):
		game_state.paused = not game_state.paused
		_update_ui()


func _unpause():
	game_state.paused = false
	_update_ui()
