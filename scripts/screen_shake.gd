extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var RANDOM_SHAKE_STRENGTH = 8.0
export var SHAKE_DECAY_RATE = 6.0

onready var rand = RandomNumberGenerator.new()

var shake_strength = 0.0

func on_shake():
	shake_strength = RANDOM_SHAKE_STRENGTH

func _process(delta):
	shake_strength = lerp(shake_strength, 0, SHAKE_DECAY_RATE * delta)
	self.offset = get_random_offset()
	
func get_random_offset():
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)

# Called when the node enters the scene tree for the first time.
func _ready():
	rand.randomize()
	Events.connect("shake", self, "on_shake")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
