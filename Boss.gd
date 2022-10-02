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

func fire():
	var bullet = bullet_scene.instance()
	bullet.global_position = global_position
	bullet.velocity = 60 * Vector2.UP
	bullet.player = player
	get_parent().add_child(bullet)
	
func teleport():
	if phase > 1:
		return
	fire()
	var temp = position.x
	position.x = x2
	$AnimatedSprite.scale.x *= -1
	x2 = temp

var dmg_cooldown = 0.5
var dmg_timer = 0.0
var brick_health = 6
var phase = 1

var phase2health = 3
func phase2():
	if phase == 1:
		phase = 2
		$Ow.text = "enough of that!"
		$Ow.visible = true
		$Label.visible = false
	else:
		return
	position.x = floor((position.x + x2) / 2.0)
	position.y -= 50
	
func _physics_process(delta):
	dmg_timer += delta
	
func phase2damage():
	print("hi")
	if dmg_timer < dmg_cooldown || phase < 2:
		return
	dmg_timer = 0.0
	print("why")
	phase2health -= 1
	print(phase2health)
	if phase2health <= 0:
		phase = 3
		visible = false
		for i in 8:
			var expl = explosion_scene.instance()
			expl.global_position = global_position + Vector2(rand.randf_range(-10, 10), rand.randf_range(-10, 10))
			expl.get_node("CPUParticles2D").emitting = true
			Events.emit_signal("shake")
			get_parent().add_child(expl)
			yield(get_tree().create_timer(0.8), "timeout")
		yield(get_tree().create_timer(1.2), "timeout")
		Events.emit_signal("you_win")
		
func take_damage():
	if dmg_timer < dmg_cooldown || phase > 1:
		return
	dmg_timer = 0.0
	brick_health -= 1
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

func reset_boss():
	phase = 1
	brick_health = 6
	global_position = init_global
	x2 = init_x2
	phase2health = 3
	
var init_global
var init_x2
# Called when the node enters the scene tree for the first time.
func _ready():
	init_global = global_position
	init_x2 = x2
	rand.randomize()
	talk()
	player = get_tree().get_root().find_node("Player", true, false)
	print(player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
