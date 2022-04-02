extends Resource
class_name GameEvents

signal change_scene(name)
signal unpause
signal start_race
signal car_finished(who)


func change_scene(name):
	self.emit_signal("change_scene", name)


func unpause():
	self.emit_signal("unpause")


func start_race():
	self.emit_signal("start_race")


func car_finished(who):
	self.emit_signal("car_finished", who)
