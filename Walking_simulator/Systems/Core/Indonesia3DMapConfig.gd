class_name Indonesia3DMapConfig
extends Resource

## Configuration resource for Indonesia 3D Map coordinates and settings
## Stores the final tested coordinates for region placeholders

# Current Placeholder Positions:
# Indonesia Barat: (-120.8738, 19.7, 66.2856)
# Indonesia Tengah: (-13.45436, 19.7, 77.36392)
# Indonesia Timur: (160.3569, 19.7, -1.466873)

@export var region_coordinates: Dictionary = {
	"indonesia_barat": {
		"name": "Indonesia Barat",
		"description": "Jakarta & Traditional Markets",
		"scene_path": "res://Scenes/IndonesiaBarat/PasarScene.tscn",
		"position": Vector3(-120.8738, 19.7, 66.2856),  # FINAL TESTED COORDINATES
		"color": Color.RED,
		"unlock_status": true
	},
	"indonesia_tengah": {
		"name": "Indonesia Tengah",
		"description": "NTB & Mount Tambora", 
		"scene_path": "res://Scenes/IndonesiaTengah/TamboraScene.tscn",
		"position": Vector3(-13.45436, 19.7, 77.36392),  # FINAL TESTED COORDINATES
		"color": Color.GREEN,
		"unlock_status": true
	},
	"indonesia_timur": {
		"name": "Indonesia Timur",
		"description": "Papua Highlands",
		"scene_path": "res://Scenes/IndonesiaTimur/PapuaScene.tscn", 
		"position": Vector3(160.3569, 19.7, -1.466873),  # FINAL TESTED COORDINATES
		"color": Color.BLUE,
		"unlock_status": true
	}
}

@export var map_settings: Dictionary = {
	"map_scale": 0.6,
	"camera_initial_position": Vector3(20, 80, 120),  # Better position to see all Indonesia
	"camera_zoom_speed": 8.0,  # Faster zoom for better navigation
	"mouse_sensitivity": 0.5,
	"camera_min_distance": 30.0,  # Closer minimum for detail
	"camera_max_distance": 300.0  # Further maximum for overview
}

@export var placeholder_settings: Dictionary = {
	"default_height_offset": 8.0,  # How high above region position
	"scattered_height": 10.0,      # Height when scattered (I key)
	"minimum_drag_height": 8.0,    # Minimum Y during drag & drop
	"drag_height_offset": 3.0,     # Extra height during drag
	"scale_multiplier": 4.0,       # Size multiplier for visibility
	"collision_radius": 2.0,       # Collision area for easy clicking
	"collision_height": 3.0        # Collision height
}

@export var sea_settings: Dictionary = {
	"sea_width": 400.0,
	"sea_depth": 200.0,
	"sea_position": Vector3(20, -0.3, 38),
	"sea_color": Color(0.1, 0.3, 0.7, 0.9)
}

@export var scatter_positions: Dictionary = {
	"indonesia_barat": Vector3(-12, 10.0, -8),
	"indonesia_tengah": Vector3(0, 10.0, 12),
	"indonesia_timur": Vector3(12, 10.0, -12)
}

## Get region data as array (for compatibility with existing code)
func get_region_data() -> Array[Dictionary]:
	var regions: Array[Dictionary] = []
	for region_id in region_coordinates:
		var region_data = region_coordinates[region_id].duplicate()
		region_data["id"] = region_id
		regions.append(region_data)
	return regions

## Update region position and save to config
func update_region_position(region_id: String, new_position: Vector3):
	if region_id in region_coordinates:
		region_coordinates[region_id]["position"] = new_position
		GameLogger.info("💾 Updated config position for " + region_id + ": " + str(new_position))
		# Auto-save could be implemented here
	else:
		GameLogger.warning("Region not found in config: " + region_id)

## Get specific region position
func get_region_position(region_id: String) -> Vector3:
	if region_id in region_coordinates:
		return region_coordinates[region_id]["position"]
	return Vector3.ZERO

## Get region info
func get_region_info(region_id: String) -> Dictionary:
	if region_id in region_coordinates:
		var info = region_coordinates[region_id].duplicate()
		info["id"] = region_id
		return info
	return {}

## Save config to file (for persistent storage)
func save_to_file(file_path: String = "user://indonesia_3d_map_config.tres"):
	var error = ResourceSaver.save(self, file_path)
	if error == OK:
		GameLogger.info("💾 Config saved to: " + file_path)
	else:
		GameLogger.error("❌ Failed to save config: " + str(error))

## Load config from file
static func load_from_file(file_path: String = "user://indonesia_3d_map_config.tres") -> Indonesia3DMapConfig:
	if ResourceLoader.exists(file_path):
		var config = load(file_path) as Indonesia3DMapConfig
		if config:
			GameLogger.info("📂 Config loaded from: " + file_path)
			return config
		else:
			GameLogger.warning("⚠️ Failed to load config from: " + file_path)
	
	# Return default config if file doesn't exist
	GameLogger.info("📝 Using default config")
	return Indonesia3DMapConfig.new()
