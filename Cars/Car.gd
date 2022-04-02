extends KinematicBody2D

export(Resource) var game_state
export(Resource) var game_events

var wheel_base = 40
var steering_angle = 10
var engine_power = 800
var friction = -0.9
var drag = -0.001
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.1
var traction_slow = 0.7

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction = 0.0

var _active = false
var _paused = false


func _ready():
	assert(game_state != null, "Please set game state resource")
	assert(game_events != null, "Please set game events resource")
	_update_paused()
	game_state.connect("updated_paused", self, "_update_paused")
	game_events.connect("start_race", self, "_start_race")


func _start_race():
	_active = true


func end_race():
	_active = false


func _update_paused():
	_paused = game_state.paused


func _physics_process(delta):
	if not _paused:
		acceleration = Vector2.ZERO
		get_input()
		apply_friction()
		calculate_steering(delta)
		move(delta)


func move(delta):
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)


func get_input():
	if _active:
		var turn = 0
		if Input.is_action_pressed("left"):
			turn -= 1
		if Input.is_action_pressed("right"):
			turn += 1
		steer_direction = turn * deg2rad(steering_angle)
		if Input.is_action_pressed("accelerate"):
			acceleration = transform.x * engine_power
		if Input.is_action_pressed("brake"):
			acceleration = transform.x * braking


func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


func apply_friction():
	if velocity.length() < 6:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

