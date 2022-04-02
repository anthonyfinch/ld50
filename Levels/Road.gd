tool
extends Path2D


export (Color) var color = Color.blue
export (Color) var center_color = Color.red
export (float) var width = 5.0
export (float) var line_width = 5.0


func _ready():
	var _c = connect("changed", self, "update")


func _draw():
	var points = curve.tessellate()
	draw_polyline(points, color, width, true)
	draw_polyline(points, center_color, line_width, true)
