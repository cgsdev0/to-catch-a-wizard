extends KinematicBody2D

const normal = Vector2(0, -1)

var rewinding = false
var recording = false
var rewind_duration = 10.0
var rewind_state = {
	"position": [],
	"rotation": [],
}
var velocity = Vector2()

func _physics_process(delta):
	# Process velocity -> movement
	velocity = move_and_slide(velocity, normal)
	if not rewinding and recording: 
		if rewind_duration * Engine.iterations_per_second == rewind_state["position"].size():
			rewind()
			return
		
		rewind_state["position"].append(global_position)
		rewind_state["rotation"].append(rotation)
	elif rewinding:
		compute_rewind(delta)

func rewind():
	rewinding = true
	$CollisionShape2D.set_deferred("disabled", true)
	
func compute_rewind(delta):
	var pos = rewind_state["position"].pop_back()
	var rot = rewind_state["rotation"].pop_back()
	
	if rewind_state["position"].empty():
		$CollisionShape2D.set_deferred("disabled", false)
		rewinding = false
		global_position = pos
		rotation = rot
		return
		
	rotation = rot
	global_position = pos
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
