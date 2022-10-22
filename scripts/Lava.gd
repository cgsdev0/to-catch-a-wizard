extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "on_body_enter")
	self.connect("body_exited", self, "on_body_exit")
	pass # Replace with function body.

func on_body_enter(body):
	$SizzleSound.global_position = body.global_position
	$SizzleSound.play()
	if body.has_method("lava_enter"):
		body.lava_enter()

func on_body_exit(body):
	if body.has_method("lava_exit"):
		body.lava_exit()
