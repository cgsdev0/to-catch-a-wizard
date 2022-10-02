extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "on_body_enter")
	
	
	pass # Replace with function body.

func on_body_enter(body):
	body.light()
	$CollisionShape2D.set_deferred("disabled", true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
