class_name CulturalAudioManager
extends Node

# Audio players
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer
@onready var effect_player: AudioStreamPlayer = $EffectPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

# Audio settings
@export var master_volume: float = 1.0
@export var ambient_volume: float = 0.3
@export var effect_volume: float = 0.7
@export var voice_volume: float = 0.8

# Region-specific audio data
var region_ambient_sounds: Dictionary = {
	"Indonesia Barat": {
		"ambient": "market_ambience.ogg",
		"description": "Traditional market sounds with vendor calls and crowd noise"
	},
	"Indonesia Tengah": {
		"ambient": "mountain_wind.ogg", 
		"description": "Mountain wind and natural sounds"
	},
	"Indonesia Timur": {
		"ambient": "jungle_sounds.ogg",
		"description": "Jungle ambience with birds and nature sounds"
	}
}

# Cultural audio effects
var cultural_audio_effects: Dictionary = {
	"artifact_collection": "collection_chime.ogg",
	"artifact_description": "cultural_narration.ogg",
	"npc_greeting": "npc_hello.ogg",
	"region_transition": "transition_sound.ogg"
}

# Current audio state
var current_region: String = ""
var is_ambient_playing: bool = false

func _ready():
	setup_audio_players()
	connect_signals()

func setup_audio_players():
	# Set up audio players
	ambient_player.volume_db = linear_to_db(ambient_volume)
	effect_player.volume_db = linear_to_db(effect_volume)
	voice_player.volume_db = linear_to_db(voice_volume)
	
	# Set up audio buses if needed
	ambient_player.bus = "Ambient"
	effect_player.bus = "SFX"
	voice_player.bus = "Voice"

func connect_signals():
	GlobalSignals.on_region_audio_change.connect(_on_region_audio_change)
	GlobalSignals.on_play_cultural_audio.connect(_on_play_cultural_audio)

func _on_region_audio_change(region: String, audio_type: String):
	match audio_type:
		"ambient":
			play_region_ambience(region)
		"transition":
			play_region_transition(region)

func _on_play_cultural_audio(audio_id: String, region: String):
	play_cultural_audio(audio_id, region)

func play_region_ambience(region: String):
	if current_region == region and is_ambient_playing:
		return
	
	current_region = region
	
	# Stop current ambient audio
	if ambient_player.playing:
		ambient_player.stop()
	
	# Load and play new ambient audio
	var ambient_data = region_ambient_sounds.get(region, {})
	var ambient_file = ambient_data.get("ambient", "")
	
	if ambient_file:
		var audio_path = "res://Assets/Audio/Ambient/" + ambient_file
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			ambient_player.stream = audio_stream
			ambient_player.play()
			is_ambient_playing = true
			
			print("Playing ambient audio for ", region, ": ", ambient_data.get("description", ""))
		else:
			print("Warning: Ambient audio file not found: ", audio_path)
	else:
		print("Warning: No ambient audio defined for region: ", region)

func play_cultural_audio(audio_id: String, region: String):
	var audio_file = cultural_audio_effects.get(audio_id, "")
	
	if audio_file:
		var audio_path = "res://Assets/Audio/Effects/" + audio_file
		if ResourceLoader.exists(audio_path):
			var audio_stream = load(audio_path)
			effect_player.stream = audio_stream
			effect_player.play()
			
			print("Playing cultural audio: ", audio_id, " for region: ", region)
		else:
			print("Warning: Cultural audio file not found: ", audio_path)
	else:
		print("Warning: No cultural audio defined for ID: ", audio_id)

func play_region_transition(region: String):
	# Play transition sound when changing regions
	play_cultural_audio("region_transition", region)
	
	# Fade out current ambient
	if ambient_player.playing:
		fade_out_ambient()
	
	# Wait a moment then start new ambient
	await get_tree().create_timer(1.0).timeout
	play_region_ambience(region)

func fade_out_ambient():
	# Simple fade out effect
	var tween = create_tween()
	tween.tween_property(ambient_player, "volume_db", -80.0, 1.0)
	await tween.finished
	ambient_player.stop()
	ambient_player.volume_db = linear_to_db(ambient_volume)

func play_voice_audio(audio_stream: AudioStream):
	if audio_stream:
		voice_player.stream = audio_stream
		voice_player.play()

func stop_all_audio():
	ambient_player.stop()
	effect_player.stop()
	voice_player.stop()
	is_ambient_playing = false

func set_master_volume(volume: float):
	master_volume = volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))

func set_ambient_volume(volume: float):
	ambient_volume = volume
	ambient_player.volume_db = linear_to_db(volume)

func set_effect_volume(volume: float):
	effect_volume = volume
	effect_player.volume_db = linear_to_db(volume)

func set_voice_volume(volume: float):
	voice_volume = volume
	voice_player.volume_db = linear_to_db(volume)

# Utility functions for audio management
func pause_ambient():
	if ambient_player.playing:
		ambient_player.stream_paused = true

func resume_ambient():
	if ambient_player.stream_paused:
		ambient_player.stream_paused = false

func get_current_region() -> String:
	return current_region

func is_audio_playing() -> bool:
	return ambient_player.playing or effect_player.playing or voice_player.playing
