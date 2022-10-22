extends Node

var main_gate = false
var reverse_gate = true

func _process(delta):
	if $Main.stream_paused != main_gate:
		$Main.stream_paused = main_gate
	if $Reverse.stream_paused != reverse_gate:
		$Reverse.stream_paused = reverse_gate

func save_state():
	main_gate = $Main.stream_paused
	reverse_gate = $Reverse.stream_paused
	
func on_rewind():
	$Main.stream_paused = true
	$Reverse.stream_paused = false
	save_state()

func on_rewind_end():
	$Main.stream_paused = false
	$Reverse.stream_paused = true
	save_state()

func _ready():
	Events.connect("rewind", self, "on_rewind")
	Events.connect("rewind_end", self, "on_rewind_end")
