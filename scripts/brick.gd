extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var rand = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("fadeout")
	self.connect("body_entered", self, "on_body_enter")
	rand.randomize()
	rotation_degrees = rand.randf_range(0, 360)

func on_body_enter(body):
	if body.has_method("take_damage"):
		body.take_damage()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	pass # Replace with function body.
