extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "on_body_enter")

func on_body_enter(body):
	body.bossFight = true
	Events.emit_signal("boss_entry")
	body.respawning = false

