extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var should_kill_player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "on_body_enter")
	$AudioStreamPlayer2D.play()
	yield(get_tree().create_timer(0.1), "timeout")
	$CollisionShape2D.queue_free()
	yield(get_tree().create_timer(2.0), "timeout")
	queue_free()
	
	
	pass # Replace with function body.

var hasHitBoss = false

func on_body_enter(body):
	if body.has_method("light"):
		body.light()
	elif body.has_method("spawn_bricks"):
		body.spawn_bricks()
	elif body.has_method("phase2damage") && !hasHitBoss && !should_kill_player:
		hasHitBoss = true
		body.phase2damage(self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
