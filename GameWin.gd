extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player

var speedrun_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("you_win", self, "on_win")
	player = find_parent("Player")

func floaty_modulus(a, b):
	while a > b:
		a -= b
	return a
		
func on_win():
	speedrun_time = player.speedrun_timer
	var minutes = floor(speedrun_time / 60.0)
	var seconds = floor(floaty_modulus(speedrun_time, 60.0) * 1000) / 1000.0
	var pretty = ""
	if floor(seconds) < 10:
		pretty = "0"
	$TimerLabel.text = "Your time was "+String(minutes)+":"+pretty+String(seconds)
	get_tree().paused = true
	visible = true
	$AnimationPlayer.play("win")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
