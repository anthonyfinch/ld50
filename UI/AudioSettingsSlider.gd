extends HSlider


export(Resource) var game_events
export (String) var bus_name = ""
export (AudioStreamSample) var audio_hint


var _bus_id = -1
var _player = null

func _ready():
	assert(game_events != null, "Please set game events resource")

	# setup to play audio hint on change
	_player = AudioStreamPlayer.new()
	_player.bus = bus_name
	_player.stream = audio_hint
	add_child(_player)

	_bus_id = AudioServer.get_bus_index(bus_name)

	# update from current setting
	var current = pow(10, AudioServer.get_bus_volume_db(_bus_id)) / 20
	value = current * max_value

	connect("value_changed", self, "_on_value_changed")


func _on_value_changed(value):
	var ratio = value / max_value
	var volume = max(-80.0, 20 * log(ratio))
	AudioServer.set_bus_volume_db(_bus_id, volume)
	_player.play()
