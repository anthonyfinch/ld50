extends KinematicBody2D

enum Modes {
	PlayerControlled
	Baddy
	}

export(Resource) var game_state
export(Resource) var game_events
export (float) var max_baddy_velocity = 1800
export (float) var baddy_losing_speed = 1300
export (float) var baddy_winning_speed = 1000
export (float) var max_collision_movement = 250

export(Modes) var mode = Modes.PlayerControlled
export(bool) var active = true
export var engine_power = 2600


var wheel_base = 40
var steering_angle = 10
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
var collision_movement = Vector2.ZERO

onready var _engine_sound = $EngineSound

var _rand_pos_range = 10.0
var _rand_offset = Vector2.ZERO
var _paused = false
var _end_race_cooldown = 6.0


func _ready():
	randomize()
	assert(game_state != null, "Please set game state resource")
	assert(game_events != null, "Please set game events resource")
	_update_paused()
	_update_engine_noise()
	game_state.connect("updated_paused", self, "_update_paused")
	game_events.connect("start_race", self, "_start_race")
	game_events.connect("car_rollcall", self, "_report_in")

	_rand_offset = Vector2(
		rand_range(-1 * _rand_pos_range, _rand_pos_range),
		rand_range(-1 * _rand_pos_range, _rand_pos_range)
	)
	print(_rand_offset)


func _report_in(race):
	race.register_car(self)


func _start_race():
	active = true
	_update_engine_noise()


func end_race():
	last_acceleration = acceleration
	active = false
	_update_engine_noise()


func _update_paused():
	_paused = game_state.paused
	_update_engine_noise()


func _physics_process(delta):
	if not _paused:
		_collision_movement()
		acceleration = Vector2.ZERO
		match mode:
			Modes.PlayerControlled:
				_player_mode(delta)
			Modes.Baddy:
				_baddy_mode(delta)
				
		_set_engine_noise()

		_process_collisions()


func set_collision_movement(val):
	collision_movement = val
	match mode:
		Modes.PlayerControlled:
			collision_movement = collision_movement.clamped(max_collision_movement)
		Modes.Baddy:
			collision_movement = collision_movement.clamped(max_baddy_velocity)


func smash(vel: Vector2):
	set_collision_movement(collision_movement + vel)

func _collision_movement():
	if collision_movement.length() > 0.1:
		# if mode != Modes.PlayerControlled:
		# 	print(collision_movement)

		var _c = move_and_slide(collision_movement)
		collision_movement *= 0.9


func _process_collisions():
	for i in get_slide_count():
		var coll: KinematicCollision2D = get_slide_collision(i)
		set_collision_movement(collision_movement + -1 * coll.remainder)

		var rem = coll.remainder
		if mode == Modes.PlayerControlled:
			rem *= 500.0

		if coll.collider.has_method("smash"):
			coll.collider.smash(rem)
		# if coll.collider.has_method("move_and_slide"):
		# 	coll.collider.move_and_slide(coll.remainder)



	collision_movement = collision_movement.clamped(max_collision_movement)
	# velocity += (collision_movement * 10.0)


func _update_engine_noise():
	if _engine_sound != null:
		if not _paused and active:
			_engine_sound.play()
		else:
			_engine_sound.stop()


func _set_engine_noise():
	if _engine_sound != null:
		_engine_sound.pitch_scale = min(2.5, 1 + velocity.length() / 400)


func _baddy_mode(_delta):
	velocity = Vector2.ZERO
	var road = game_state.road
	if road != null:
		var path = road.curve
	
		# var predicted = position + velocity * delta
		var offset = path.get_closest_offset(road.to_local(global_position))

		# print("I'm %s and you are %s" % [offset, game_state.last_player_offset])

		# var target = road.to_global(path.interpolate_baked(offset + 10))


		var desired_vel = baddy_losing_speed
		if offset >= game_state.last_player_offset:
			desired_vel = baddy_winning_speed

		desired_vel += _rand_offset.x * 100.0

		var target = road.to_global(path.interpolate_baked(offset + 250 + (500 * (1 - (min(desired_vel, max_baddy_velocity) / max_baddy_velocity)))))


		var desired = (target - global_position).normalized() * desired_vel
		velocity += desired
		velocity = velocity.clamped(max_baddy_velocity)

		# if abs(desired.angle()) > 2.0:
		# 	rotation = desired.angle() - (PI/2)
		rotation = desired.angle()

	velocity = move_and_slide(velocity + collision_movement)


func _player_mode(delta):
	var road = game_state.road
	if road != null:
		var path = road.curve
		var offset = path.get_closest_offset(road.to_local(global_position))
		game_state.last_player_offset = offset
	if active:
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

	elif last_acceleration.length() > 0 and _end_race_cooldown > 0.0:
		acceleration = last_acceleration
		_end_race_cooldown -= delta

	apply_friction()
	calculate_steering(delta)
	move(delta)


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

