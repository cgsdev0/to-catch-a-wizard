extends KinematicBody2D

export var velocity = Vector2(0, 0)

var explosion = preload("res://scenes/explosion.tscn")

#var rewind_state = {
#	"position": [],
#	"done_exploding": [],
#}

#var rewind_delta = 0.0
#var rewinding = false
#var done_exploding = false

#func _ready():
#	Events.connect("rewind", self, "on_rewind")
		
#func on_rewind():
#	rewind_delta = 0.0
#	rewinding = true
#	$CollisionShape2D.set_deferred("disabled", true)
#
#func compute_rewind(delta):
#	rewind_delta += delta
#	var rewind_speed = rewind_delta * 3.2
#	if rewind_state["position"].empty():
#		queue_free()
#		return
#	var pos = rewind_state["position"].pop_back()
#	var done = rewind_state["done_exploding"].pop_back()
#	if !rewind_state["position"].empty() && rewind_speed > 1:
#		pos = rewind_state["position"].pop_back()
#		done = rewind_state["done_exploding"].pop_back()
#		if !rewind_state["position"].empty() && rewind_speed > 2:
#			pos = rewind_state["position"].pop_back()
#			done = rewind_state["done_exploding"].pop_back()
#	position = pos
#	if done_exploding && !done:
#		done_exploding = false
#		$Particles/A.emitting = !done
#		$Particles/B.emitting = !done
#		$Particles/A.amount = 90
#		$Particles/B.amount = 90
#		$Particles/A.initial_velocity = 200
#		$Particles/B.initial_velocity = 200
#		$Particles/A.lifetime = 0.8
#		$Particles/B.lifetime = 0.8
#
#	if rewind_state["position"].empty():
#		queue_free()
		
func _physics_process(delta):
#	if rewinding:
#		compute_rewind(delta)
#	else:
		move(delta)

func move(delta):
	var coll = move_and_collide(velocity * delta)
	if coll != null:
#		done_exploding = true
		$Particles/A.emitting = false
		$Particles/B.emitting = false
		var expl = explosion.instance()
		expl.global_position = global_position
		expl.get_node("CPUParticles2D").emitting = true
		Events.emit_signal("shake")
		get_parent().add_child(expl)
		velocity = Vector2.ZERO;
		queue_free()
		
#	rewind_state["position"].append(position)
#	rewind_state["done_exploding"].append(done_exploding)
