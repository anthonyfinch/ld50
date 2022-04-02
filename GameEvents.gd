extends Resource
class_name GameEvents

signal change_scene(name)
signal unpause


func change_scene(name):
	self.emit_signal("change_scene", name)


func unpause():
	self.emit_signal("unpause")
