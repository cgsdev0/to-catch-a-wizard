extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var x2 = 0

const bullet_scene = preload("res://scenes/boss_bullet.tscn")
const explosion_scene = preload("res://scenes/boss_explosion.tscn")
var player

var lines = [
	"you're trapped here... forever!",
	"your fireballs are no match for me",
	"so close to escaping... yet so far",
	"time to die, wizard",
	"clock is ticking",
	"time is up!",
	"... ever seen groundhog day?",
	"it's death o' clock"
]
onready var rand = RandomNumberGenerator.new()

var cooldown_p1 = 2.8
var cooldown_timer1 = 0

func fire(rage = false):
	if cooldown_timer1 < cooldown_p1 && !rage:
		return
	cooldown_timer1 = 0.0;
	if rage:
		yield(get_tree().create_timer(0.2), "timeout")
#	$ShootSound.pitch_scale = 0.7
#	$ShootSound.play()
#	yield(get_tree().create_timer(0.2), "timeout")
	var bullet = bullet_scene.instance()
	bullet.global_position = global_position
	bullet.velocity = 60 * Vector2.UP
	bullet.player = player
	bullet.position.y -= 16
	get_parent().add_child(bullet)
	
var teleporting = false
func teleport():
	if teleporting:
		return
	if phase > 1:
		return
	teleporting = true
	fire(true) #angry
	$InvisPlayer.play("teleport")
	yield(get_tree().create_timer(0.15), "timeout")
	var temp = position.x
	position.x = x2
	$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	$TeleportSound.play()
	x2 = temp
	yield(get_tree().create_timer(0.15), "timeout")
	teleporting = false

var dmg_cooldown = 0.5

var dmg_timer = 0.0
var brick_health = 0
var phase = 0
var phase2health = 0

func reset_boss():
	phase = 1
	brick_health = 1
	global_position = init_global
	x2 = init_x2
	phase2health = 3 # 15
	cooldown_timer1 = 0.0
	$Ow.text = "oww"
	$Ow.visible = false
	$Label.visible = true
	$AnimatedSprite.flip_h = false

func _process(delta):
	if !$CanvasLayer/AnimationPlayer.is_playing():
		$CanvasLayer/HealthBar.value = phase2health
	$CanvasLayer/HealthBar.visible = (phase >= 2)
	
func phase2():
	if phase == 1:
		phase = 2
		dmg_timer = -4.0
		cooldown_timer = 0.0
		$CanvasLayer/AnimationPlayer.play("fill")
		$Ow.text = "enough of that!"
		$Ow.visible = true
		$Label.visible = false
		$TeleportSound.play()
		$InvisPlayer.play("teleport")
		yield(get_tree().create_timer(0.15), "timeout")
	else:
		return
	
	position.x = floor((position.x + x2) / 2.0) - 2
	position.y -= 50
	
func _physics_process(delta):
	if !player.bossFight || player.respawning:
		return
	dmg_timer += delta
	cooldown_timer += delta
	cooldown_timer1 += delta
	if phase == 1:
		fire()
	if phase == 2:
		phase2attack()


var cooldown_p2 = 4.5
var cooldown_timer = cooldown_p2

func phase2attack(rage = false):
	if cooldown_timer < cooldown_p2 && !rage:
		return
	if rage:
		yield(get_tree().create_timer(0.45), "timeout")
#	$ShootSound.pitch_scale = 1.2
#	$ShootSound.play()
#	yield(get_tree().create_timer(0.2), "timeout")
	cooldown_timer = 0.0
	var bullet = bullet_scene.instance()
	bullet.global_position = global_position
	bullet.velocity = 60 * Vector2.LEFT
	bullet.tracking_rate = rand.randf_range(0.5, 1.8)
	bullet.position.y -= 16
	bullet.player = player
	get_parent().add_child(bullet)
	bullet = bullet_scene.instance()
	bullet.global_position = global_position
	bullet.velocity = 75 * Vector2.DOWN
	bullet.tracking_rate = -1
	bullet.position.y -= 16
	bullet.player = player
	get_parent().add_child(bullet)
	bullet = bullet_scene.instance()
	bullet.global_position = global_position
	bullet.velocity = 60 * Vector2.RIGHT
	bullet.tracking_rate = rand.randf_range(0.5, 1.8)
	bullet.position.y -= 16
	bullet.player = player
	get_parent().add_child(bullet)
	
func phase2damage(attacker):
	print(attacker)
	if dmg_timer < dmg_cooldown || phase < 2 || phase2health < 0:
		return
	$HurtAnimation.play("hurt2")
	$BrickHitSound.play()
	dmg_timer = 0.0
	phase2health -= 1
	phase2attack()
	if phase2health < 0:
		phase = 3
		$Ow.text = "ARRRGGHHGH!!!"
		$CanvasLayer/AnimationPlayer.play("fadeout")
		Events.emit_signal("boss_dead")
		Events.emit_signal("remove_boss_bullets")
		for i in 8:
			var expl = explosion_scene.instance()
			expl.global_position = global_position + Vector2(rand.randf_range(-10, 10), rand.randf_range(-10, 10))
			expl.global_position.y -= 8
			expl.get_node("CPUParticles2D").emitting = true
			Events.emit_signal("shake")
			get_parent().add_child(expl)
			yield(get_tree().create_timer(0.65), "timeout")
		yield(get_tree().create_timer(1.2), "timeout")
		Events.emit_signal("you_win")
		
func take_damage():
	if dmg_timer < dmg_cooldown || phase > 1:
		return
	dmg_timer = 0.0
	brick_health -= 1
	$HurtAnimation.play("hurt")
	$BrickHitSound.play()
	yield(get_tree().create_timer(0.4), "timeout")
	if brick_health <= 0:
		phase2()
		return

	teleport()
	$Ow.visible = true
	$Label.visible = false
	yield(get_tree().create_timer(1.5), "timeout")
	$Ow.visible = false
	$Label.visible = true
	
func talk():
	var i = rand.randi_range(0, lines.size() - 1)
	for c in lines[i]:
		$Label.text += c
		yield(get_tree().create_timer(0.13), "timeout")
	yield(get_tree().create_timer(3.0), "timeout")
	$Label.text = ""
	yield(get_tree().create_timer(1.5), "timeout")
	talk()


	
var init_global
var init_x2
# Called when the node enters the scene tree for the first time.
func _ready():
	init_global = global_position
	init_x2 = x2
	rand.randomize()
	talk()
	player = get_tree().get_root().find_node("Player", true, false)
	reset_boss()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
