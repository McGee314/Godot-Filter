extends Node3D
class_name TamboraHikingTrail

# Tambora Hiking Trail Manager
# Based on real Tambora hiking trail with 5 positions from base to summit
# Reference: Hiking mount tambora (9.-11.01.2020)

signal trail_generated
signal asset_placement_complete

@export var trail_length: float = 5000.0  # Total trail length in meters
@export var max_elevation_gain: float = 2032.0  # 2722m - 690m
@export var trail_width: float = 2.0  # Trail width in meters

# Trail positions based on real Tambora hiking data
var trail_positions = {
	"Start": {"elevation": 690.0, "distance": 0.0, "terrain_type": "jungle_base"},
	"Pos1": {"elevation": 1077.0, "distance": 1200.0, "terrain_type": "forest_mid"},
	"Pos2": {"elevation": 1366.0, "distance": 2400.0, "terrain_type": "forest_high"},
	"Pos3": {"elevation": 1600.0, "distance": 3200.0, "terrain_type": "stream_area"},
	"Pos4": {"elevation": 2000.0, "distance": 4000.0, "terrain_type": "volcanic_mid"},
	"Summit": {"elevation": 2722.0, "distance": 5000.0, "terrain_type": "volcanic_summit"}
}

# Terrain characteristics for each section
var terrain_profiles = {
	"jungle_base": {
		"vegetation_density": 0.8,
		"tree_types": ["pine"],
		"ground_cover": ["grass", "ferns"],
		"debris_density": 0.6,
		"rock_density": 0.3,
		"path_visibility": 0.9
	},
	"forest_mid": {
		"vegetation_density": 0.9,
		"tree_types": ["pine"],
		"ground_cover": ["grass", "ferns"],
		"debris_density": 0.7,
		"rock_density": 0.4,
		"path_visibility": 0.8
	},
	"forest_high": {
		"vegetation_density": 0.7,
		"tree_types": ["pine"],
		"ground_cover": ["grass"],
		"debris_density": 0.5,
		"rock_density": 0.6,
		"path_visibility": 0.7
	},
	"stream_area": {
		"vegetation_density": 0.6,
		"tree_types": ["pine"],
		"ground_cover": ["grass"],
		"debris_density": 0.4,
		"rock_density": 0.8,
		"path_visibility": 0.6,
		"water_features": true
	},
	"volcanic_mid": {
		"vegetation_density": 0.3,
		"tree_types": [],
		"ground_cover": ["grass"],
		"debris_density": 0.2,
		"rock_density": 0.9,
		"path_visibility": 0.5
	},
	"volcanic_summit": {
		"vegetation_density": 0.1,
		"tree_types": [],
		"ground_cover": [],
		"debris_density": 0.1,
		"rock_density": 1.0,
		"path_visibility": 0.3
	}
}

var current_position: String = "Start"
var terrain_manager: TerrainManager
var asset_placer: ProceduralAssetPlacer
var trail_path: PackedVector3Array = []

func _ready():
	GameLogger.info("Initializing Tambora Hiking Trail")
	
	# Get references to components
	terrain_manager = get_node("../Terrain3D")
	asset_placer = get_node_or_null("ProceduralAssets")
	
	# Connect signals
	if asset_placer:
		asset_placer.asset_placed.connect(_on_asset_placed)
		GameLogger.info("Connected to asset placer signals")
	else:
		GameLogger.warning("ProceduralAssets node not found - asset placement will be disabled")
	
	# Initialize trail
	generate_trail_path()
	
	# Only setup UI connections if we're not in a test scene
	if not is_in_test_scene():
		setup_ui_connections()
	else:
		GameLogger.info("Running in test mode - skipping UI connections")

func generate_trail_path():
	"""Generate the hiking trail path from base to summit"""
	GameLogger.info("Generating Tambora hiking trail path")
	
	trail_path.clear()
	var segment_count = 100  # Number of points along the trail
	
	for i in range(segment_count + 1):
		var progress = float(i) / segment_count
		var distance = progress * trail_length
		var elevation = get_elevation_at_distance(distance)
		var _terrain_type = get_terrain_type_at_distance(distance)
		
		# Create 3D position (x = distance, y = elevation, z = slight variation for natural path)
		var x = distance
		var y = elevation
		var z = sin(progress * PI * 4) * 5.0  # Natural path variation
		
		trail_path.append(Vector3(x, y, z))
	
	GameLogger.info("Trail path generated with %d points" % trail_path.size())
	trail_generated.emit()

func get_elevation_at_distance(distance: float) -> float:
	"""Calculate elevation at given distance along trail"""
	var progress = distance / trail_length
	
	# Use smooth elevation curve based on real Tambora data
	# Start at 690m, end at 2722m with realistic slope changes
	var base_elevation = 690.0
	var elevation_gain = 2032.0
	
	# Create realistic elevation profile with steeper sections
	var elevation_curve = smoothstep(0.0, 1.0, progress)
	elevation_curve = pow(elevation_curve, 1.2)  # Slightly steeper in middle
	
	return base_elevation + (elevation_gain * elevation_curve)

func get_terrain_type_at_distance(distance: float) -> String:
	"""Determine terrain type at given distance"""
	var progress = distance / trail_length
	
	if progress < 0.2:
		return "jungle_base"
	elif progress < 0.4:
		return "forest_mid"
	elif progress < 0.6:
		return "forest_high"
	elif progress < 0.7:
		return "stream_area"
	elif progress < 0.9:
		return "volcanic_mid"
	else:
		return "volcanic_summit"

func place_assets_along_trail():
	"""Place PSX assets procedurally along the hiking trail"""
	GameLogger.info("Starting procedural asset placement along Tambora trail")
	
	# Ensure asset placer exists
	asset_placer = ensure_asset_placer_exists()
	
	# Clear existing assets
	asset_placer.clear_assets()
	
	# Place assets along trail segments
	for i in range(trail_path.size() - 1):
		var start_pos = trail_path[i]
		var end_pos = trail_path[i + 1]
		var distance = start_pos.x
		var terrain_type = get_terrain_type_at_distance(distance)
		var profile = terrain_profiles[terrain_type]
		
		# Place assets based on terrain profile
		place_terrain_assets(start_pos, end_pos, profile)
	
	GameLogger.info("Asset placement completed")

func place_terrain_assets(start_pos: Vector3, end_pos: Vector3, profile: Dictionary):
	"""Place assets for a specific terrain profile"""
	var _segment_length = start_pos.distance_to(end_pos)
	var mid_point = (start_pos + end_pos) / 2.0
	
	# Place trees
	if profile.tree_types.size() > 0 and randf() < profile.vegetation_density * 0.3:
		var tree_type = profile.tree_types[randi() % profile.tree_types.size()]
		asset_placer.place_tree(mid_point, tree_type)
	
	# Place ground cover
	if profile.ground_cover.size() > 0 and randf() < profile.vegetation_density * 0.5:
		var cover_type = profile.ground_cover[randi() % profile.ground_cover.size()]
		asset_placer.place_vegetation(mid_point, cover_type)
	
	# Place rocks
	if randf() < profile.rock_density * 0.4:
		asset_placer.place_stone(mid_point)
	
	# Place debris
	if randf() < profile.debris_density * 0.3:
		asset_placer.place_debris(mid_point)

func setup_ui_connections():
	"""Connect UI buttons to functions"""
	var ui = get_node_or_null("../../UI")
	
	if not ui:
		GameLogger.warning("UI not found - running in test mode or headless")
		return
	
	var control_panel = ui.get_node_or_null("ControlPanel")
	if not control_panel:
		GameLogger.warning("ControlPanel not found in UI")
		return
	
	var vbox = control_panel.get_node_or_null("VBoxContainer")
	if not vbox:
		GameLogger.warning("VBoxContainer not found in ControlPanel")
		return
	
	var generate_btn = vbox.get_node_or_null("Button")
	var place_btn = vbox.get_node_or_null("Button2")
	var reset_btn = vbox.get_node_or_null("Button3")
	
	if generate_btn:
		generate_btn.pressed.connect(_on_generate_trail_pressed)
		GameLogger.info("Connected Generate Trail button")
	
	if place_btn:
		place_btn.pressed.connect(_on_place_assets_pressed)
		GameLogger.info("Connected Place Assets button")
	
	if reset_btn:
		reset_btn.pressed.connect(_on_reset_scene_pressed)
		GameLogger.info("Connected Reset Scene button")

func _on_generate_trail_pressed():
	"""UI callback for generating trail"""
	GameLogger.info("Generating trail from UI")
	generate_trail_path()

func _on_place_assets_pressed():
	"""UI callback for placing assets"""
	GameLogger.info("Placing assets from UI")
	place_assets_along_trail()

func _on_reset_scene_pressed():
	"""UI callback for resetting scene"""
	GameLogger.info("Resetting Tambora scene")
	if asset_placer:
		asset_placer.clear_assets()
	generate_trail_path()

func _on_asset_placed(asset_type: String, position: Vector3):
	"""Callback when an asset is placed"""
	GameLogger.debug("Asset placed: %s at %s" % [asset_type, position])

func get_trail_info() -> Dictionary:
	"""Get current trail information"""
	return {
		"total_length": trail_length,
		"max_elevation": 2722.0,
		"min_elevation": 690.0,
		"positions": trail_positions,
		"current_position": current_position
	}

func get_position_at_distance(distance: float) -> String:
	"""Get position name at given distance"""
	for pos_name in trail_positions:
		var pos_data = trail_positions[pos_name]
		if distance <= pos_data.distance:
			return pos_name
	return "Summit"

func is_in_test_scene() -> bool:
	"""Check if we're running in a test scene"""
	# Check if we're in a test scene by looking at the scene tree
	var current_scene = get_tree().current_scene
	if current_scene and "Test" in current_scene.name:
		return true
	
	# Also check if we have a parent with "Test" in the name
	var parent = get_parent()
	while parent:
		if "Test" in parent.name:
			return true
		parent = parent.get_parent()
	
	return false

func ensure_asset_placer_exists() -> ProceduralAssetPlacer:
	"""Ensure the ProceduralAssets node exists, create if needed"""
	if asset_placer:
		return asset_placer
	
	GameLogger.info("Creating ProceduralAssetPlacer node...")
	asset_placer = ProceduralAssetPlacer.new()
	asset_placer.name = "ProceduralAssets"
	add_child(asset_placer)
	
	# Connect signals
	asset_placer.asset_placed.connect(_on_asset_placed)
	GameLogger.info("Created and connected ProceduralAssetPlacer")
	
	return asset_placer
