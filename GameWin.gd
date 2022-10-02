extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("you_win", self, "on_win")
	pass # Replace with function body.

func on_win():
	get_tree().paused = true
	visible = true
	$AnimationPlayer.play("win")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
