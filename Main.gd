extends Control

const TitleScene = preload("res://Title.tscn")

export(Resource) var game_events

onready var _scene_holder = $SceneHolder

var _current_scene = null
var _loader = null
var _wait_frames = 0
var _time_max = 100



func _ready() -> void:
	assert(game_events != null, "Please set game events resource")
	_load_scene(TitleScene)

	game_events.connect("change_scene", self, "_goto_scene")


func _load_scene(scene: Resource) -> void:
	_current_scene = scene.instance()
	if _current_scene.has_method("reload"):
		print("I got reload")
		_current_scene.reload()
	else:
		print("what no reload")
	_scene_holder.add_child(_current_scene)


func _goto_scene(name: String) -> void:
	_loader = ResourceLoader.load_interactive(name + ".tscn")
	assert(_loader != null)

	set_process(true)

	_current_scene.queue_free()

	_wait_frames = 3


func _process(_delta: float) -> void:
	if _loader == null:
		set_process(false)
		return

	if _wait_frames > 0:
		_wait_frames -= 1
		return

	var t = OS.get_ticks_msec()

	while OS.get_ticks_msec() < t + _time_max:
		var err = _loader.poll()
		print(err)

		if err == ERR_FILE_EOF:
			var resource = _loader.get_resource()
			_loader = null
			_load_scene(resource)
			break

		elif err != OK:
			assert(false, "Error loading scene: " + err)
