extends Node2D
tool

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var width: float = 40
export var height: float = 3

export var fg_color: Color = Color.red
export var bg_color: Color = Color.black
export var border_color: Color = Color.black

export var value: float = 10
export var max_value: float = 10
export var min_width = 2.0

func _process(delta):
	if visible:
		position.x = get_viewport().size.x / 2
		update()
func _draw():
	draw_rect(Rect2(-width / 2, -height, width, height), bg_color)
	var sliver_size = width / (max_value * 2)
	var missing = max_value - value
	var adjust = missing * (sliver_size / max_value)
	var inner_width = max(min_width, value / max_value * width - adjust)
	draw_rect(Rect2(-inner_width / 2, -height, inner_width, height), fg_color)
	draw_rect(Rect2(-width / 2, -height, width, height), border_color, false)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
