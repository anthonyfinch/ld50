extends Path2D


export (Color) var color = Color.blue
export (float) var width = 5.0


func _draw():
	var points = curve.tessellate()
	draw_polyline(points, color, width, true)
