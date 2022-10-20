extends KinematicBody2D

export var velocity = Vector2(0, 0)

var explosion = preload("res://scenes/explosion.tscn")

var spent = false

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
		
func _ready():
	$LaunchSound.play()
func _physics_process(delta):
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, global_position + velocity * delta * 5.0, [self])
		if result && result.collider:
			if result.collider.name == "Boss":
				result.collider.teleport()
		move(delta)

func explode():
	if !spent:
		$Particles/A.emitting = false
		$Particles/B.emitting = false
		spent = true
		var expl = explosion.instance()
		expl.collision_layer = collision_layer & 0b111111111111111111111110
		expl.collision_mask = collision_mask & 0b111111111111111111111110
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		$CollisionShape2D.set_deferred("disabled", true)
		expl.global_position = global_position
		expl.get_node("CPUParticles2D").emitting = true
		Events.emit_signal("shake")
		get_parent().add_child(expl)
		velocity = Vector2.ZERO;
		yield(get_tree().create_timer(1.0), "timeout")
		queue_free()
		
func move(delta):
	var coll = move_and_collide(velocity * delta)
	if coll != null && !spent:
#		done_exploding = true
		explode()
		if coll.collider.has_method("explode"):
			coll.collider.explode()
		
		
#	rewind_state["position"].append(position)
#	rewind_state["done_exploding"].append(done_exploding)
