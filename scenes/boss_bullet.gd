extends KinematicBody2D

export var velocity = Vector2(0, 0)
export var tracking_rate = 2

var explosion = preload("res://scenes/boss_explosion.tscn")

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
var player

func _ready():
	Events.connect("remove_boss_bullets", self, "on_boss_cleanup")

func on_boss_cleanup():
	queue_free()
	
func _physics_process(delta):
	move(delta)

var spent = false

func explode():
	if spent:
		return
	spent = true
#		done_exploding = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	$Particles/A.emitting = false
	$Particles/B.emitting = false
	var expl = explosion.instance()
	$CollisionShape2D.set_deferred("disabled", true)
	expl.global_position = global_position
	expl.get_node("CPUParticles2D").emitting = true
	Events.emit_signal("shake")
	get_parent().add_child(expl)
	velocity = Vector2.ZERO
	Events.emit_signal("boss_bullet_down")
	yield(get_tree().create_timer(1.0), "timeout")
	queue_free()
		
func move(delta):
	var desired = (player.global_position - global_position).normalized()
	var norm
	if tracking_rate == -1:
		norm = desired
	else:
		if velocity.normalized().angle_to(desired) > 0:
			norm = velocity.rotated(delta * tracking_rate).normalized()
		else:
			norm = velocity.rotated(-delta * tracking_rate).normalized()
	velocity = norm * velocity.length()
	
	var coll = move_and_collide(velocity * delta)
	if coll != null && !spent:
		explode()
		if coll.collider.has_method("explode"):
			coll.collider.explode()
		
#	rewind_state["position"].append(position)
#	rewind_state["done_exploding"].append(done_exploding)
