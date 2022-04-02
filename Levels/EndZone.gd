extends Area2D

export(Resource) var game_events

func _ready():
	assert(game_events != null, "Please set game events resource")
	var _c = connect("body_entered", self, "_car_enter")


func _car_enter(body):
	if body.has_method("end_race"):
		body.end_race()
		game_events.car_finished(body)
