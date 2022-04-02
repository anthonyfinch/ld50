extends Button

export(Resource) var game_events
export var scene_name = "Title"

func _ready() -> void:
	assert(game_events != null, "Please set game events resource")
	var _c = connect("pressed", self, "_goto_scene")


func _goto_scene() -> void:
	game_events.change_scene(scene_name)

