extends StaticBody2D

export var torches: Array = []

var actual_torches = []
func open():
	$CollisionPolygon2D.disabled = true
	$TorchDoor.texture = preload("res://door_open.png")
	
func close():
	$CollisionPolygon2D.disabled = false
	$TorchDoor.texture = preload("res://torch_door.png")

func _ready():
	for torch in torches:
		actual_torches.append(get_node(torch))
		
func _physics_process(delta):
	for torch in actual_torches:
		if !torch.lit:
			close()
			return
	open()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
