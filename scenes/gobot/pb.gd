extends PhysicalBone

var audio_player : AudioStreamPlayer3D
var prev_trans : Vector3 = Vector3.ZERO
var prev_speed : float = 0.0
var hit_sounds = [
	preload("res://sounds/metal/hit_01.wav")
]

func _ready():
	audio_player = AudioStreamPlayer3D.new()
	audio_player.bus = "Sounds"
	add_child(audio_player)
	audio_player.stream = hit_sounds[0]

func _physics_process(_delta):
	pass
#	var speed = (translation - prev_trans).length()
#	var diff = speed - prev_speed
#	if abs(diff) > 0.02:
#		audio_player.pitch_scale = rand_range(0.8, 1.1)
#		audio_player.play()
#	prev_trans = translation
#	prev_speed = speed
