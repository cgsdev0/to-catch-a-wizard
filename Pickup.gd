extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var toggle = "has_boots"
export var title = "New Spell!"
export var subtitle = "FIREBALL"
export var description = "it does what you expect."
export var has_dialog = true
# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "_on_Pickup_body_entered")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Pickup_body_entered(body):
	if typeof(body[toggle]) == TYPE_BOOL:
		body[toggle] = true
	else:
		body[toggle] += 1
		$PickupKeySound.play()
	if has_dialog:
		Events.emit_signal("show_dialog", title, subtitle, description)
	self.queue_free()
