extends StaticBody2D



func open():
	$CollisionPolygon2D.disabled = true
	$Door.texture = preload("res://door_open.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_meta("door", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
