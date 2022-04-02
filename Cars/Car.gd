extends KinematicBody2D

enum Modes {
	PlayerControlled
	Baddy
	}

export(Resource) var game_state
export(Resource) var game_events
export(Modes) var mode = Modes.PlayerControlled
export(bool) var active = true


var wheel_base = 40
var steering_angle = 10
var engine_power = 3600
var friction = -0.5
var drag = -0.001
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.1
var traction_slow = 0.7

var acceleration = Vector2.ZERO
var last_acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction = 0.0

var _paused = false

var _end_race_cooldown = 6.0


func _ready():
	assert(game_state != null, "Please set game state resource")
	assert(game_events != null, "Please set game events resource")
	_update_paused()
	game_state.connect("updated_paused", self, "_update_paused")
	game_events.connect("start_race", self, "_start_race")
	game_events.connect("car_rollcall", self, "_report_in")


func _report_in(race):
	race.register_car(self)


func _start_race():
	active = true


func end_race():
	last_acceleration = acceleration
	active = false


func _update_paused():
	_paused = game_state.paused


func _physics_process(delta):
	if not _paused:
		acceleration = Vector2.ZERO
		if active:
			match mode:
				Modes.PlayerControlled:
					_player_mode()
				Modes.Baddy:
					_baddy_mode(delta)

		elif last_acceleration.length() > 0 and _end_race_cooldown > 0.0:
			acceleration = last_acceleration
			_end_race_cooldown -= delta

		apply_friction()
		calculate_steering(delta)
		move(delta)



func _baddy_mode(delta):
	var road = game_state.road
	var path = road.curve
	
	var predicted = position + velocity * delta
	var offset = path.get_closest_offset(road.to_local(predicted))

	var target = road.to_global(path.interpolate_baked(offset + 1.0))

	var acc = (target - global_position).normalized()
		
	acceleration = acc * engine_power


func _player_mode():
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


func move(delta):
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)


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

