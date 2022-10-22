extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var lit = false

var rewinding = false
var recording = false
var rewind_duration = 10.0
var rewind_delta = 0.0
var rewind_state = {
	"lit": [],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material.set_shader_param("position", global_position)
	if lit:
		$AnimatedSprite.play("on")
		$Sprite.visible = true
		$Smoke.emitting = true
	else:
		Events.connect("rewind", self, "on_rewind")
		Events.connect("record", self, "on_record")

	
func on_record():
	recording = true
	
func on_rewind():
	rewind_delta = 0.0
	rewinding = true

func _physics_process(delta):
	if not rewinding and recording: 
		rewind_state["lit"].append(lit)
	elif rewinding:
		compute_rewind(delta)
		
func compute_rewind(delta):
	rewind_delta += delta
	var rewind_speed = rewind_delta * 3.2
	if rewind_state["lit"].empty():
		lit = false
		$AnimatedSprite.play("off")
		$Sprite.visible = false
		rewinding = false
		$Smoke.emitting = false
		return
	var l = rewind_state["lit"].pop_back()
	if !rewind_state["lit"].empty() && rewind_speed > 1:
		l = rewind_state["lit"].pop_back()
		if !rewind_state["lit"].empty() && rewind_speed > 2:
			l = rewind_state["lit"].pop_back()
	
	if !l:
		lit = false
		$AnimatedSprite.play("off")
		$Sprite.visible = false
		$Smoke.emitting = false
	if rewind_state["lit"].empty():
		lit = false
		$AnimatedSprite.play("off")
		$Smoke.emitting = false
		$Sprite.visible = false
		rewinding = false
		

func light():
	if !lit:
		lit = true
		$AnimatedSprite.play("on")
		$Sprite.visible = true
		$AudioStreamPlayer2D.play()
		$Smoke.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
