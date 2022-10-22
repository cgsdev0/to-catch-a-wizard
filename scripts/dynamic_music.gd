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

var faded = false
func on_boss_enter():
	if !faded:
		faded = true
		$Crossfader.play("main_to_boss")
		yield(get_tree().create_timer(0.1), "timeout")
		$BossTrack.seek($Main.get_playback_position() / $Main.stream.get_length() * $BossTrack.stream.get_length())
	elif !$BossTrack.playing:
		$BossTrack.pitch_scale = 1.0
		$BossTrack.volume_db = -5.0
		$BossTrack.play()
		
func on_you_died():
	$Crossfader.play("boss_fade_out")
	
func _ready():
	Events.connect("boss_entry", self, "on_boss_enter")
	Events.connect("rewind", self, "on_rewind")
	Events.connect("you_died", self, "on_you_died")
	Events.connect("rewind_end", self, "on_rewind_end")
