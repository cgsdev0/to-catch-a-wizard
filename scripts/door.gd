extends StaticBody2D


var eaten_key = false

func open():
	if eaten_key:
		return false
	eaten_key = true
	$AudioStreamPlayer2D.play()
	$CollisionPolygon2D.disabled = true
	$Door.texture = preload("res://sprites/props/door_open.png")
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_meta("door", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
