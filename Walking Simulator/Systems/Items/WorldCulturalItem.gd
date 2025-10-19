extends CulturalInteractableObject

@export var item_name: String
@export var cultural_region: String
@export var collection_animation: PackedScene
@export var collection_sound: AudioStream

var is_collected: bool = false

func _ready():
	# Add to artifact group for radar detection
	add_to_group("artifact")
	
	# Set up interaction prompt
	interaction_prompt = "Press E to collect " + item_name
	
	# Connect to global signals
	GlobalSignals.on_collect_artifact.connect(_on_artifact_collected)

func _interact():
	if not is_collected:
		collect_item()

func collect_item():
	if is_collected:
		return
	
	is_collected = true
	
	# Load the cultural item resource
	var item_path = "res://Systems/Items/ItemData/" + item_name + ".tres"
	if ResourceLoader.exists(item_path):
		var _item = load(item_path)  # Loaded but not used in current implementation
		
		# Add to player inventory
		Global.collect_artifact(cultural_region, item_name)
		
		# Emit collection signal
		GlobalSignals.on_collect_artifact.emit(item_name, cultural_region)
		
		# Play collection effects
		play_collection_effects()
		
		# Hide the item
		visible = false
		
		# Optional: Show collection message
		show_collection_message(item_name)
	else:
		print("Warning: Cultural item resource not found: ", item_path)

func play_collection_effects():
	# Play collection sound
	if collection_sound:
		var audio_player = AudioStreamPlayer3D.new()
		audio_player.stream = collection_sound
		audio_player.volume_db = -10.0
		add_child(audio_player)
		audio_player.play()
		
		# Remove audio player after playing
		await audio_player.finished
		audio_player.queue_free()
	
	# Play collection animation if available
	if collection_animation:
		var anim_instance = collection_animation.instantiate()
		add_child(anim_instance)
		await get_tree().create_timer(2.0).timeout
		anim_instance.queue_free()

func show_collection_message(_item_name: String):
	# Create a simple collection message
	var message = "Collected: " + item_name  # Use the exported variable
	print(message)
	
	# You can implement a more sophisticated UI message here
	# For now, we'll use the existing interaction system

func _on_artifact_collected(artifact_name: String, _region: String):
	# This function can be used for additional collection logic
	if artifact_name == item_name:
		print("Artifact collected: ", artifact_name, " from ", _region)
