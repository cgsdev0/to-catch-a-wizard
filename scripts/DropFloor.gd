extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var fallen = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	$KinematicBody2D.gravity_scale = 1.0
