extends KinematicBody2D


export var has_boots = true
export var has_dash = true
export var has_fireball = true
export var has_lava_imm = true

export var respawn_from_boss = Vector2()

var bossFight = false
var wasBossFight = false

export var keys = 2

# Tweakable constants
export var horizontal_speed = 30
export var boots_horizontal_speed = 65
export var dash_speed = 240
export var dash_duration = 0.2
export var boots_jump_speed = 190
export var jump_speed = 100
export var double_jump_speed = 370
export var roll_speed = 300
export var dive_horizontal_speed = 280
export var dive_vertical_speed = 300
export var roll_duration = 0.7
export var shoot_duration = 0.9
export var bad_roll_modifier = 0.7
export var arm_speed = 10
export var gravity = 4
export var boots_gravity = 8
export var max_y_speed = 220
export var prone_slide_decel = 10
export var jump_cooldown = 0.1
export var dash_cooldown = 0.2

# Movement state
enum MovementState {NORMAL, JUMPING_1, JUMPING_2, DASH}
var movement_state = MovementState.NORMAL
var last_moved_direction = 1
var timer = 0
var shoot_timer = shoot_duration
var jump_cooldown_timer = jump_cooldown
var dash_cooldown_timer = dash_cooldown
var dash_timer = 0.0
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

var init_global

var dead = false
var respawning = false

func kill_player():
	if dead:
		return
	dead = true
	Events.emit_signal("remove_boss_bullets")
	$DeathSound.play()
	$Position2D/Camera2D/CanvasLayer/DeathFade.modulate = Color.transparent
	$Position2D/Camera2D/CanvasLayer/DeathFade.visible = true
	$Position2D/Camera2D/CanvasLayer/DeathFade/AnimationPlayer.play("dead")
	yield(get_tree().create_timer(0.5), "timeout")
	boss.reset_boss()
	position = respawn_from_boss
	respawning = true
	Events.emit_signal("remove_boss_bullets")
	yield(get_tree().create_timer(0.5), "timeout")
	Events.emit_signal("remove_boss_bullets")
	$Position2D/Camera2D/CanvasLayer/DeathFade.visible = false
	dead = false

func play_pickup_key_sound():
	$PickupKeySound.play()
	
func lava_death():
	$DeathSound.play()
	
var speedrun_timer = null

func _process(delta):
	if speedrun_timer != null:
		speedrun_timer += delta
	
func record():
	if speedrun_timer == null:
		speedrun_timer = 0.0
	if recording == null:
		recording = 0.0
		Events.emit_signal("record")
		
func rewind():
	if !rewinding:
		$RewindSound.play()
		rewinding = true
		rewind_delta = 0
		$CollisionShape2D.set_deferred("disabled", true)
		Events.emit_signal("rewind")
	
func compute_rewind(delta):
	
	rewind_delta += delta
	var rewind_speed = rewind_delta * 3.2
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
	was_rewinding = true
	
	rotation = rot
	global_position = pos
	$Sprite.play(playing)
	$Sprite.scale.x = facing
	
	if rewind_state["position"].empty():
		global_position = init_global
		$CollisionShape2D.set_deferred("disabled", false)
		rewinding = false
		$RewindSound.stop()
		print(rewind_delta)
		recording = null
	

		
func colorize(color: Color = Color(1, 1, 1, 1)):
	$Sprite.modulate = color

func _physics_process(delta: float):
	if dead:
		return
	if has_lava_imm:
		self.collision_layer = self.collision_layer & 0b011111111111111111011111;
		self.collision_mask = self.collision_mask & 0b011111111111111111011111;
		
	velocity = move_and_slide(velocity, normal)
	if rewinding:
		compute_rewind(delta)
		return
	
	if bossFight && !wasBossFight:
		wasBossFight = true
		rewinding = false
		# dump our rewind state
		rewind_duration = 5.0
		rewind_state = {
			"position": [],
			"rotation": [],
			"facing": [],
			"playing": []
		}
	if Input.is_action_just_pressed("rewind") && recording && !bossFight:
		rewind()
		
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider == null:
			continue
		if !(collision.collider.has_meta("door")):
			continue
		if keys >= 1:
			if collision.collider.open():
				keys -= 1
		
	if recording != null:
		recording += delta
		if recording >= rewind_duration:
			# Revert to circbuf if we're in the bossfight
			if !bossFight:
				rewind()
				return
			else:
				rewind_state["position"].pop_front()
				rewind_state["rotation"].pop_front()
				rewind_state["facing"].pop_front()
				rewind_state["playing"].pop_front()
		
		rewind_state["position"].append(global_position)
		rewind_state["rotation"].append(rotation)
	
	if Input.is_action_just_pressed("fireball") && has_fireball:
		if shoot_timer < shoot_duration:
			return
		record()
		shoot_timer = 0.0
		var bullet = bullet_scene.instance()
		var norm = (get_global_mouse_position() - position).normalized()
		bullet.velocity =  norm * 300.0
		bullet.global_position = global_position + norm * 20.0
		if boss != null && boss.phase > 1:
			bullet.collision_mask |= 0b10000000000000000000
			bullet.collision_layer |= 0b10000000000000000000
		get_parent().add_child(bullet)
	if movement_state != MovementState.DASH:
		if has_boots:
			velocity.y += boots_gravity * delta * 60
		else:
			velocity.y += gravity * delta * 60
			
	if velocity.y > max_y_speed:
		velocity.y = max_y_speed

	timer += delta
	shoot_timer += delta
	jump_cooldown_timer += delta

	var prev_movement_state = movement_state

	# State machine transitions
	if is_on_floor():
		dash_cooldown_timer += delta
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
				$JumpSound.play()
			else:
				velocity.y -= jump_speed
				$WeakJumpSound.play()
			movement_state = MovementState.JUMPING_1
	
	if Input.is_action_just_pressed("dash") and has_dash and movement_state != MovementState.DASH:
		record()
		if dash_cooldown_timer >= dash_cooldown:
			$DashSound.play()
			dash_timer = 0.0
			velocity.y = 0
			velocity.x = dash_speed * last_moved_direction
			movement_state = MovementState.DASH

	match movement_state:
		MovementState.DASH:
			dash_cooldown_timer = 0.0
			dash_timer += delta
			if dash_timer >= dash_duration:
				movement_state = MovementState.NORMAL
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

var boss
	
func _ready():
	boss = get_tree().get_root().find_node("Boss", true, false)
	init_global = global_position
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

