tool
extends Node2D



enum NodeType {EDGE_LEFT, EDGE_RIGHT, EDGE_CENTER, FLOOR}

export var nodes = []
export var edges = []
var solution = []
var graph = AStar2D.new()

onready var player = get_parent().get_parent().get_node("Player")

func is_node(pos: Vector2):
	# hilariously slow
	for n in nodes:
		if n["pos"] == pos:
			return true
	return false

func hash_vec(vec: Vector2):
	var res = int(vec.x*1000 + vec.y)
	return res

func connect_pos(a: Vector2, b: Vector2, bi: bool):
	edges.push_back([a, b])
	graph.connect_points(hash_vec(a), hash_vec(b), bi)

# Called when the node enters the scene tree for the first time.
func calculate_graph():
	nodes = []
	var tiles = get_parent()
	for i in tiles.get_used_cells():
			var left_edge = (tiles.get_cellv(i + Vector2(-1, 0)) == TileMap.INVALID_CELL) and tiles.get_cellv(i+Vector2(0, -1)) == TileMap.INVALID_CELL and tiles.get_cellv(i+Vector2(0, -2)) == TileMap.INVALID_CELL
			var right_edge = (tiles.get_cellv(i + Vector2(1, 0)) == TileMap.INVALID_CELL) and tiles.get_cellv(i+Vector2(0, -1)) == TileMap.INVALID_CELL and tiles.get_cellv(i+Vector2(0, -2)) == TileMap.INVALID_CELL

			if left_edge and right_edge:
				nodes.push_back({"pos":i + Vector2(0, -1), "type": NodeType.EDGE_CENTER})
			elif left_edge:
				nodes.push_back({"pos":i + Vector2(0, -1), "type": NodeType.EDGE_LEFT})
			elif right_edge:
				nodes.push_back({"pos":i + Vector2(0, -1), "type": NodeType.EDGE_RIGHT})
			elif(tiles.get_cellv(i + Vector2(0, -1)) == TileMap.INVALID_CELL and tiles.get_cellv(i + Vector2(0, -2)) == TileMap.INVALID_CELL):
				nodes.push_back({"pos":i + Vector2(0, -1), "type": NodeType.FLOOR})

	for n in nodes:
		graph.add_point(hash_vec(n["pos"]), tiles.map_to_world(n["pos"]))

	for n in nodes:
		# find drops
		if n["type"] == NodeType.EDGE_LEFT or n["type"] == NodeType.EDGE_CENTER:
			for p in range(1,20):
				if is_node(n["pos"] + Vector2(-1,p)):
					connect_pos(n["pos"], n["pos"] + Vector2(-1,p), false)
					break
		if n["type"] == NodeType.EDGE_RIGHT or n["type"] == NodeType.EDGE_CENTER:
			for p in range(1,20):
				if is_node(n["pos"] + Vector2(1,p)):
					connect_pos(n["pos"], n["pos"] + Vector2(1,p), false)
					break
		# find upward jumps
		for y in range(1, 3):
			for x in range(-3, 4):
				if x == 0:
					continue
				if y >= 2 and (x == -4 or x == 5):
					continue
				if is_node(n["pos"] + Vector2(x, -y)):
					connect_pos(n["pos"], n["pos"] + Vector2(x, -y), false)
		# like a good neighbor
		if is_node(n["pos"] + Vector2(1, 0)):
			connect_pos(n["pos"], n["pos"] + Vector2(1, 0), true)
		if is_node(n["pos"] + Vector2(-1, 0)):
			connect_pos(n["pos"], n["pos"] + Vector2(-1, 0), true)

	update()

func _ready():
		calculate_graph()

#func _process(delta):
#    if not Engine.editor_hint:
#        solution = graph.get_point_path(9008, graph.get_closest_point(player.position))
#        update()

const colors = {
NodeType.EDGE_CENTER: Color(0,0.5,1,0.4),
NodeType.EDGE_LEFT: Color(0,0.5,1,0.4),
NodeType.EDGE_RIGHT: Color(0,0.5,1,0.4),
NodeType.FLOOR: Color(0.8,0.1,0.1,0.4)
}
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func draw_rect2(pos, size, color):
	var points_arc = []
	points_arc.push_back(pos)
	points_arc.push_back(pos + Vector2(size, 0))
	points_arc.push_back(pos + Vector2(size, size))
	points_arc.push_back(pos + Vector2(0, size))

	draw_polygon(points_arc, [color])

func draw_arrow(a: Vector2, b: Vector2, color: Color):
	draw_line(a, b, color)
	var tip_unit_vector = (b - a).normalized()
	draw_line(b, b + tip_unit_vector.rotated(2.7) * 6, color)
	draw_line(b, b + tip_unit_vector.rotated(-2.7) * 6, color)

func _draw():
	var tiles = get_parent()
	for node in nodes:
		draw_rect2(tiles.map_to_world(node["pos"]) + Vector2(4,4), 24, colors[node["type"]])
	for edge in edges:
		draw_arrow(tiles.map_to_world(edge[0]) + Vector2(16, 16), tiles.map_to_world(edge[1])  + Vector2(16, 16), Color.black)
	var prev_edge = null
	for edge in solution:
		if prev_edge:
			draw_arrow(prev_edge + Vector2(16, 16), edge  + Vector2(16, 16), Color.red)
		prev_edge = edge
