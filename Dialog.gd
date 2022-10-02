extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("show_dialog", self, "on_show_dialog")
	pass # Replace with function body.

func on_show_dialog(title, subtitle, description):
	get_tree().paused = true
	$Dialog/Background/MarginContainer/VBoxContainer/Title.text = title
	$Dialog/Background/MarginContainer/VBoxContainer/Subtext.text = subtitle
	$Dialog/Background/MarginContainer/VBoxContainer/Description.text = description.c_unescape()
	print(description)
	self.modulate = Color(1, 1, 1, 0)
	$AnimationPlayer.play("Fade")
	self.visible = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		$AnimationPlayer.play_backwards("Fade")
		yield(get_tree().create_timer(0.25), "timeout")
		self.visible = false
		get_tree().paused = false
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
