extends Control

const RaceResult = preload("res://Levels/RaceResult.tscn")

export(Resource) var game_events
export(Resource) var game_state

onready var _pause_screen = $UIOverlay/PauseScreen
onready var _start_screen = $UIOverlay/StartScreen
onready var _countdown_label = $UIOverlay/StartScreen/PanelContainer/Box/CountDown
onready var _end_screen = $UIOverlay/EndScreen
onready var _end_screen_results = $UIOverlay/EndScreen/PanelContainer/Box/Results
onready var _race_time_label = $UIOverlay/Panel/RaceTime
onready var _start_sound_1 = $Sounds/Start1
onready var _start_sound_2 = $Sounds/Start2

var _started = false
var _finished = false
var _race_time = 0.0
var _count_down = 3.9

var _racer_count = 0

var _finished_cars = []


func _ready():
	assert(game_events != null, "Please set game events resource")
	assert(game_state != null, "Please set game state resource")

	_start_screen.visible = true
	_end_screen.visible = false
	_update_ui()
	game_events.connect("unpause", self, "_unpause")
	game_events.connect("car_finished", self, "_car_finished")

	yield(get_tree(), "idle_frame")
	game_events.car_rollcall(self)


func register_car(car):
	car.active = false
	_racer_count += 1


func _car_finished(who):
	var rec = {
		"name": who.name,
		"time": _race_time
	}
	_finished_cars.append(rec)
	print(_finished_cars)
	print(_finished_cars.size())
	if _finished_cars.size() >= _racer_count:
		_finished = true
		for res in _finished_cars:
			var line = RaceResult.instance()
			_end_screen_results.add_child(line)
			line.get_node("Name").text = res["name"]
			line.get_node("Time").text =  "%3.2f" % res["time"]
		_end_screen.visible = true


func _process(delta):
	if not _started:
		var old = _count_down
		_count_down -= delta
		var new = _count_down
		if floor(new) < floor(old):
			if floor(new) == 0:
				_start_sound_2.play()
			else:
				_start_sound_1.play()
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
