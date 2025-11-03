extends Node

# Global game state management for the exhibition

# Current region being explored
var current_region: String = ""

# Player progress tracking
var visited_regions: Array[String] = []
var collected_artifacts: Dictionary = {}
var cultural_knowledge: Dictionary = {}

# System references
var cultural_inventory: CulturalInventory
var audio_manager: CulturalAudioManager

# Exhibition settings
var exhibition_mode: bool = true
var session_duration: float = 900.0  # 15 minutes default
var current_session_time: float = 0.0

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

# Language settings (for international audience)
var current_language: String = "en"  # Default to English

# Topeng Nusantara settings
var selected_mask_type: String = ""  # "preset" or "custom"
var selected_mask_id: int = -1       # For preset masks (1-7)
var custom_mask_components: Dictionary = {
	"base": -1,
	"mata": -1,
	"mulut": -1
}

# Region-specific data
var region_data: Dictionary = {
	"Indonesia Barat": {
		"title": "Traditional Market Cuisine",
		"description": "Explore Indonesian street food culture in traditional markets",
		"duration": 600.0,  # 10 minutes
		"foods": ["Soto", "Lotek", "Baso", "Sate"],
		"locations": ["Jakarta", "Serang", "Bandung", "Bogor", "Garut", "Cirebon"]
	},
	"Indonesia Tengah": {
		"title": "Mount Tambora Historical Experience",
		"description": "Journey through the 1815 eruption that changed the world",
		"duration": 900.0,  # 15 minutes
		"historical_events": ["1815 Eruption", "Global Climate Impact", "Historical Significance"],
		"elevations": ["Base Camp", "Mid Slope", "Summit"]
	},
	"Indonesia Timur": {
		"title": "Papua Cultural Artifact Collection",
		"description": "Discover ancient artifacts and Papua ethnic culture",
		"duration": 1200.0,  # 20 minutes
		"artifacts": ["Batu Dootomo", "Kapak Perunggu", "Traditional Tools"],
		"sites": ["Bukit Megalitik Tutari", "Traditional Villages", "Archaeological Sites"]
	}
}

func _ready():
	# Make this node persistent across scene changes
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if exhibition_mode:
		current_session_time += delta
		
		# Check if session time limit reached
		var current_region_data = region_data.get(current_region, {})
		var max_duration = current_region_data.get("duration", session_duration)
		
		if current_session_time >= max_duration:
			show_session_complete_message()

func start_region_session(region_name: String):
	current_region = region_name
	current_session_time = 0.0
	
	if not region_name in visited_regions:
		visited_regions.append(region_name)
	
	GameLogger.info("Started session for: " + region_name)
	
	# Start region-specific audio
	if audio_manager:
		audio_manager.play_region_ambience(region_name)

func get_current_region_data() -> Dictionary:
	return region_data.get(current_region, {})

func add_cultural_knowledge(region: String, knowledge: String):
	if not region in cultural_knowledge:
		cultural_knowledge[region] = []
	
	if not knowledge in cultural_knowledge[region]:
		cultural_knowledge[region].append(knowledge)
		
		# Emit signal for UI updates
		GlobalSignals.on_learn_cultural_info.emit(knowledge, region)

func collect_artifact(region: String, artifact: String):
	if not region in collected_artifacts:
		collected_artifacts[region] = []
	
	if not artifact in collected_artifacts[region]:
		collected_artifacts[region].append(artifact)
		print("Collected artifact: ", artifact, " in ", region)
		
		# Update inventory if available
		if cultural_inventory:
			# Load the cultural item resource
			var item_path = "res://Systems/Items/ItemData/" + artifact + ".tres"
			if ResourceLoader.exists(item_path):
				var item = load(item_path)
				cultural_inventory.add_cultural_artifact(item, region)
		
		# Play collection audio
		if audio_manager:
			audio_manager.play_cultural_audio("artifact_collection", region)

func get_session_progress() -> float:
	var current_region_data = region_data.get(current_region, {})
	var max_duration = current_region_data.get("duration", session_duration)
	return (current_session_time / max_duration) * 100.0

func get_remaining_time() -> float:
	var current_region_data = region_data.get(current_region, {})
	var max_duration = current_region_data.get("duration", session_duration)
	return max(0.0, max_duration - current_session_time)

func show_session_complete_message():
	# This will be called when session time is up
	print("Session complete for: ", current_region)
	# You can implement a UI popup here to show completion message

func reset_exhibition_data():
	current_region = ""
	visited_regions.clear()
	collected_artifacts.clear()
	cultural_knowledge.clear()
	current_session_time = 0.0

func save_exhibition_data():
	# Save progress for exhibition tracking
	var save_data = {
		"visited_regions": visited_regions,
		"collected_artifacts": collected_artifacts,
		"cultural_knowledge": cultural_knowledge,
		"session_time": current_session_time
	}
	
	var save_file = FileAccess.open("user://exhibition_data.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func load_exhibition_data():
	# Load saved progress
	if FileAccess.file_exists("user://exhibition_data.save"):
		var save_file = FileAccess.open("user://exhibition_data.save", FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				# Cast arrays to proper types
				var temp_visited = data.get("visited_regions", [])
				visited_regions.clear()
				for region in temp_visited:
					visited_regions.append(str(region))
				
				collected_artifacts = data.get("collected_artifacts", {}).duplicate()
				cultural_knowledge = data.get("cultural_knowledge", {}).duplicate()
				current_session_time = data.get("session_time", 0.0)

# Save/Load system support
func get_collected_items() -> Array:
	# Return collected items for save system
	# This can be expanded to include inventory items, achievements, etc.
	var items = []
	if current_region != "":
		items.append({"type": "region", "name": current_region})
	return items
