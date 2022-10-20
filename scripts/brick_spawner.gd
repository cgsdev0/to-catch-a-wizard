extends StaticBody2D


onready var rand = RandomNumberGenerator.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var brick_scene = preload("res://scenes/brick.tscn")
func spawn_bricks():
	for i in rand.randi_range(1, 3):
		var brick = brick_scene.instance()
		brick.global_position = global_position
		brick.global_position.y += 14
		get_parent().add_child(brick)
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	rand.randomize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
