extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var should_kill_player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "on_body_enter")
	
	
	pass # Replace with function body.

func on_body_enter(body):
	if body.has_method("light"):
		body.light()
	elif body.has_method("spawn_bricks"):
		body.spawn_bricks()
	elif body.has_method("phase2damage"):
		body.phase2damage()
	elif body.has_method("kill_player") && should_kill_player:
		body.kill_player()
	$CollisionShape2D.set_deferred("disabled", true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
