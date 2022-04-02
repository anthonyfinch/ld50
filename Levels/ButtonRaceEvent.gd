extends Button


export(Resource) var game_events
export var race_event = "unpause"

func _ready() -> void:
	assert(game_events != null, "Please set game events resource")
	var _c = connect("pressed", self, "_trigger_event")


func _trigger_event() -> void:
	if game_events.has_method(race_event):
		game_events.call(race_event)
