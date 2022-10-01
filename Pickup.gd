extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var toggle = "has_boots"
# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "_on_Pickup_body_entered")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Pickup_body_entered(body):
	body[toggle] = true
	self.queue_free()
