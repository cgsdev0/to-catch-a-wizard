extends KinematicBody2D

onready var level = get_parent().get_node("TileMap/Node2D")
onready var player = get_parent().get_node("Player")
var solution = []
var i = 0

var motion = Vector2(0, 0)
const normal = Vector2(0, -1)
var turn_timer = 0
var attack_timer = 0
var facing = 0
var jump_tries = 0
var start = position
enum EnemyState { ATTACKING, FOLLOWING }
var enemy_state = EnemyState.FOLLOWING

var resolve_timer = 0
var needs_resolve = false

func colorize(color: Color = Color(1, 1, 1, 1)):
	$Sprite.modulate = color

# Called when the node enters the scene tree for the first time.
func _ready():
	solve()
	print(solution)
	update()

func _process(_delta):
	update()

func solve():
	needs_resolve = false
	start = position
	solution = level.graph.get_point_path(
		level.graph.get_closest_point(position),
		level.graph.get_closest_point(player.position))
	i = 0
	if len(solution) >= 1:
		if (
			(facing >= 0 and position.x > solution[i].x + 16) or
			(facing <= 0 and position.x < solution[i].x + 16)
		) and position.y < solution[i].y + 16:
			i += 1
	if i >= len(solution):
		resolve_timer = 0
		needs_resolve = true
		print("i'll try again")

func path():
	if i >= len(solution):
		return Vector2(0,0)
	if i == 0:
		return (solution[i] + Vector2(16,16) - start)
	return (solution[i] - solution[i-1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	motion.y += 28 * delta * 50
	turn_timer += delta
	resolve_timer += delta
	attack_timer += delta

	if enemy_state == EnemyState.ATTACKING:

		motion.x = 0
		if attack_timer > 0.5:
			enemy_state = EnemyState.FOLLOWING
			attack_timer = 0
			colorize()
	elif enemy_state == EnemyState.FOLLOWING:
		if needs_resolve and resolve_timer > 0.5:
			print("trying again")
			solve()
		var cur_path = path()
		facing = sign(cur_path.x)
		if facing != 0:
			$Sprite.scale.x = -facing
		if (is_on_floor() and
		abs(position.x - player.position.x) < 40 and
		abs(position.y - player.position.y) < 60):
			motion.x = 0
			if attack_timer > 0.5:
				attack_timer = 0
				enemy_state = EnemyState.ATTACKING
				colorize(Color.red) # temp
		elif i < len(solution):
			motion.x = 206 * facing
		else:
			motion.x = 0
		if is_on_floor():
			if jump_tries >= 1:
				# resolve
				solve()
				jump_tries = 0
			if i < len(solution):
				# jump
				if position.y - solution[i].y > 10:
					motion.y = -500
					jump_tries += 1
				if (
					(facing >= 0 and position.x > solution[i].x + 16) or
					(facing <= 0 and position.x < solution[i].x + 16)
				) and position.y < solution[i].y + 16:
					jump_tries = 0
					i += 1
					if i > 1 or i >= len(solution):
						solve()

	motion = move_and_slide(motion, normal)


func draw_arrow(a: Vector2, b: Vector2, color: Color):
	draw_line(a, b, color)
	var tip_unit_vector = (b - a).normalized()
	draw_line(b, b + tip_unit_vector.rotated(2.7) * 6, color)
	draw_line(b, b + tip_unit_vector.rotated(-2.7) * 6, color)


func _draw():
	var prev_edge = null
	var a = 0
	for edge in solution:
		if prev_edge and a >= i:
			draw_arrow(prev_edge + Vector2(16, 16) - position, edge  + Vector2(16, 16) - position, Color.red)
		a += 1
		prev_edge = edge
	# draw goal
	if i < len(solution):
		draw_line(Vector2(solution[i].x + 16, position.y - 16) - position,  Vector2(solution[i].x + 16, position.y + 16) - position, Color.blue)
