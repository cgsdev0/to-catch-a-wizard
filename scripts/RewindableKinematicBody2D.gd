extends RigidBody2D

const normal = Vector2(0, -1)

var rewinding = false
var recording = false
var rewind_duration = 10.0
var rewind_delta = 0.0
var rewind_state = {
	"position": [],
	"rotation": [],
}

var initial_pos = Vector2()

func _integrate_forces(state):
	if rewinding:
		linear_velocity = Vector2()
		angular_velocity = 0.0
	if $CollisionShape2D.disabled and initial_pos == global_position:
		global_position = initial_pos
		$CollisionShape2D.set_deferred("disabled", false)
		
func _physics_process(delta):
	if not rewinding and recording: 
		rewind_state["position"].append(global_position)
		rewind_state["rotation"].append(rotation)
	elif rewinding:
		compute_rewind(delta)

func on_record():
	recording = true
	
func on_rewind():
	rewind_delta = 0.0
	rewinding = true
	$CollisionShape2D.set_deferred("disabled", true)
	
func compute_rewind(delta):
	rewind_delta += delta
	var rewind_speed = rewind_delta * 3.2
	if rewind_state["position"].empty():
		self.angular_velocity = 0.0
		self.gravity_scale = 0.0
		self.linear_velocity = Vector2()
		rewinding = false
		recording = null
		global_position = initial_pos
		rotation = 0
		return
	var pos = rewind_state["position"].pop_back()
	var rot = rewind_state["rotation"].pop_back()
	if !rewind_state["position"].empty() && rewind_speed > 1:
		pos = rewind_state["position"].pop_back()
		rot = rewind_state["rotation"].pop_back()
		if !rewind_state["position"].empty() && rewind_speed > 2:
			pos = rewind_state["position"].pop_back()
			rot = rewind_state["rotation"].pop_back()
	rotation = rot
	global_position = pos
	
	if rewind_state["position"].empty():
		self.angular_velocity = 0.0
		self.gravity_scale = 0.0
		self.linear_velocity = Vector2()
		rewinding = false
		recording = null
		rotation = rot
		global_position = pos
		
# Called when the node enters the scene tree for the first time.
func _ready():
	initial_pos = global_position
	Events.connect("rewind", self, "on_rewind")
	Events.connect("record", self, "on_record")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
