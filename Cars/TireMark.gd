extends Node2D
class_name TireMark


export (float) var period: float = 0.1
export (int) var max_points: int = 50

var _points: Array = []
var _count: float = 0.0

func _ready() -> void:
	pass


func _draw() -> void:
	var to_draw = []
	# var to_draw = [position]
	for pnt in _points:
		to_draw.push_front(to_local(pnt))

	draw_polyline(to_draw, Color(0, 0, 0, 0.4), 15.0)



func _physics_process(delta: float) -> void:
	_count += delta

	if _count >= period:
		_count = 0.0
		_points.push_back(global_position)
		while _points.size() > max_points:
			_points.pop_front()

	update()
