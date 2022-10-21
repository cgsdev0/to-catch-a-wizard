extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var rand = RandomNumberGenerator.new()
var bounced = false
var pls_bounce = false
var bounce_direction = Vector2.LEFT
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("fadeout")
	self.connect("body_entered", self, "on_body_enter")
	rand.randomize()
	rotation_degrees = rand.randf_range(0, 360)

func _physics_process(delta):
	if pls_bounce && !bounced:
		bounced = true
		self.apply_impulse(Vector2.ZERO, (bounce_direction + Vector2.UP) * 100)
		
func on_body_enter(body):
	if body.has_method("take_damage"):
		body.take_damage()
		if !pls_bounce:
			pls_bounce = true
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	pass # Replace with function body.
