extends KinematicBody2D


var has_boots = false

# Tweakable constants
export var horizontal_speed = 25
export var boots_horizontal_speed = 65
export var boots_jump_speed = 140
export var jump_speed = 80
export var double_jump_speed = 370
export var roll_speed = 300
export var dive_horizontal_speed = 280
export var dive_vertical_speed = 300
export var roll_duration = 0.7
export var shoot_duration = 0.3
export var bad_roll_modifier = 0.7
export var arm_speed = 10
export var gravity = 2
export var boots_gravity = 12
export var prone_slide_decel = 10
export var jump_cooldown = 0.1

# Movement state
enum MovementState {NORMAL, JUMPING_1, JUMPING_2}
var movement_state = MovementState.NORMAL
var last_moved_direction = 1
var timer = 0
var jump_cooldown_timer = jump_cooldown
var max_x = position.x
var roll_modifier = 1

const bullet_scene = preload("res://scenes/bullet.tscn")

const normal = Vector2(0, -1)

var rewinding = false
var was_rewinding = false
var recording = null
var rewind_duration = 10.0
var rewind_state = {
	"position": [],
	"rotation": [],
	"facing": [],
	"playing": []
}
var velocity = Vector2()

var rewind_speed = 1
var rewind_delta = 0

		
func record():
	if recording == null:
		recording = 0.0
		
func rewind():
	was_rewinding = false
	rewinding = true
	rewind_delta = 0
	rewind_speed = 1
	$CollisionShape2D.set_deferred("disabled", true)
	
func compute_rewind(delta):
	
	rewind_delta += delta
	rewind_speed = rewind_delta * 3.0
	var pos = rewind_state["position"].pop_back()
	var rot = rewind_state["rotation"].pop_back()
	var facing = rewind_state["facing"].pop_back()
	var playing = rewind_state["playing"].pop_back()
	if !rewind_state["position"].empty() && rewind_speed > 1:
		pos = rewind_state["position"].pop_back()
		rot = rewind_state["rotation"].pop_back()
		facing = rewind_state["facing"].pop_back()
		playing = rewind_state["playing"].pop_back()
		if !rewind_state["position"].empty() && rewind_speed > 2:
			pos = rewind_state["position"].pop_back()
			rot = rewind_state["rotation"].pop_back()
			facing = rewind_state["facing"].pop_back()
			playing = rewind_state["playing"].pop_back()
			if !rewind_state["position"].empty() && rewind_speed > 3:
				pos = rewind_state["position"].pop_back()
				rot = rewind_state["rotation"].pop_back()
				facing = rewind_state["facing"].pop_back()
				playing = rewind_state["playing"].pop_back()
	while !was_rewinding && pos == global_position:
		pos = rewind_state["position"].pop_back()
		rot = rewind_state["rotation"].pop_back()
		facing = rewind_state["facing"].pop_back()
		playing = rewind_state["playing"].pop_back()
	was_rewinding = true
	
	rotation = rot
	global_position = pos
	$Sprite.play(playing)
	$Sprite.scale.x = facing
	
	if rewind_state["position"].empty():
		$CollisionShape2D.set_deferred("disabled", false)
		rewinding = false
		print(rewind_delta)
		recording = null
	

func colorize(color: Color = Color(1, 1, 1, 1)):
	$Sprite.modulate = color

func _physics_process(delta: float):
	velocity = move_and_slide(velocity, normal)
	if rewinding:
		compute_rewind(delta)
		return
	
	if recording != null:
		recording += delta
		if recording >= rewind_duration:
			rewind()
			return
		
		rewind_state["position"].append(global_position)
		rewind_state["rotation"].append(rotation)
		
	if has_boots:
		velocity.y += boots_gravity * delta * 60
	else:
		velocity.y += gravity * delta * 60

	timer += delta
	jump_cooldown_timer += delta

	var prev_movement_state = movement_state

	# State machine transitions
	if is_on_floor():
		match movement_state:
			MovementState.JUMPING_1, MovementState.JUMPING_2:
				jump_cooldown_timer = 0
				movement_state = MovementState.NORMAL

	else:
		# Fall detection
		match movement_state:
			MovementState.NORMAL:
				movement_state = MovementState.JUMPING_1

	#if Input.is_action_just_pressed("ui_up") and movement_state == MovementState.JUMPING_1:
	#	record()
	#	velocity.y = -double_jump_speed
	#	movement_state = MovementState.JUMPING_2
		
	if Input.is_action_pressed("ui_up") and movement_state == MovementState.NORMAL:
		record()
		if jump_cooldown_timer >= jump_cooldown:
			if has_boots:
				velocity.y -= boots_jump_speed
			else:
				velocity.y -= jump_speed
			movement_state = MovementState.JUMPING_1

	match movement_state:
		MovementState.NORMAL, MovementState.JUMPING_1, MovementState.JUMPING_2:
			velocity.x = 0
			if Input.is_action_pressed("ui_right"):
				if has_boots:
					velocity.x += boots_horizontal_speed
				else:
					velocity.x += horizontal_speed
			if Input.is_action_pressed("ui_left"):
				if has_boots:
					velocity.x -= boots_horizontal_speed
				else:
					velocity.x -= horizontal_speed
			if velocity.x != 0:
				record()
				last_moved_direction = sign(velocity.x)

	# Handle animations
	match movement_state:
		MovementState.NORMAL:
			if velocity.x != 0:
				if has_boots:
				#$Sprite.play("walking", last_moved_direction < 0)
					$Sprite.play("run")
				else:
					$Sprite.play("walking")
			else:
				$Sprite.play("idle")
#        MovementState.SHOOTING:
#            $Sprite.play("shoot")
		MovementState.JUMPING_1:
			$Sprite.play("jump")
		MovementState.JUMPING_2:
			$Sprite.play("jump") # TODO: double jump anim
		_:
			$Sprite.stop()

	$Sprite.scale.x = last_moved_direction # move this
	
	rewind_state["facing"].append(last_moved_direction)
	rewind_state["playing"].append($Sprite.animation)



	# track progress
	if position.x > max_x:
		max_x = position.x

	# invisible back wall
	#if position.x < max_x - get_viewport_rect().size.x / 2:
	#    position.x = max_x - get_viewport_rect().size.x / 2

# would be great to do this less poorly
func normalizeAngle(angle: float):
	while angle < 0:
		angle += 2 * PI
	while angle > 2 * PI:
		angle -= 2 * PI
	return angle

func absMin(a: float, b: float):
	if abs(a) < abs(b):
		return a
	return b

