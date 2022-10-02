extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player
var shader
export var rewindColor = Color()
export var defColor = Color()
export var lowTimeColor = Color()
export var bossColor = Color()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = find_parent("Player")
	shader = $"../RewindEffect"

func _physics_process(delta):
	$ColorRect/HBoxContainer/KeysLabel.text = String(player.keys)
	
	var timeSpent = player.recording
	if timeSpent == null:
		timeSpent = 0.0
	
	var raw = String(ceil(10.0 - timeSpent))
	if raw.length() == 1:
		raw = "0" + raw

	if player.rewinding:
		shader.visible = true
	else:
		shader.visible = false
		
	if player.bossFight:
		$ColorRect/HBoxContainer/TimerLabel.text = "-:--"
		$ColorRect/HBoxContainer/TimerLabel.modulate = bossColor
	elif player.rewinding:
		$ColorRect/HBoxContainer/TimerLabel.text = "<< -:--"
		$ColorRect/HBoxContainer/TimerLabel.modulate = rewindColor
	else:
		if timeSpent > 7.0:
			$ColorRect/HBoxContainer/TimerLabel.modulate = lowTimeColor
		else:
			$ColorRect/HBoxContainer/TimerLabel.modulate = defColor
		$ColorRect/HBoxContainer/TimerLabel.text = "0:" + raw
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
