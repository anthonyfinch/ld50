extends Camera2D

export var zoom_factor = 600


func _physics_process(_delta: float) -> void:
	var parent = get_parent()
	if "velocity" in parent:
		var zoom_mod = 1 + (parent.velocity.length() / zoom_factor)
		zoom = Vector2(zoom_mod, zoom_mod)
