extends Node3D

# Test script for PSX asset loading and placement
# This tests Phase 1 completion: PSX asset validation and basic placement

@onready var psx_asset_pack: PSXAssetPack
@onready var camera: Camera3D
@onready var asset_container: Node3D
@onready var ui_panel: Control
@onready var status_label: Label

var assets_visible = true
var mouse_sensitivity = 0.002
var mouse_captured = false

# Texture assignment system
var category_textures = {
	"trees": [
		"res://Assets/PSX/PSX Nature/textures/tree_1.png",
		"res://Assets/PSX/PSX Nature/textures/tree_bark_5.png",
		"res://Assets/PSX/PSX Nature/textures/tree_bark_6.png",
		"res://Assets/PSX/PSX Nature/textures/pine_bark_1.png",
		"res://Assets/PSX/PSX Nature/textures/pine_bark_2.png",
		"res://Assets/PSX/PSX Nature/textures/branch_1.png",
		"res://Assets/PSX/PSX Nature/textures/branch_2.png",
		"res://Assets/PSX/PSX Nature/textures/branch_3.png",
		"res://Assets/PSX/PSX Nature/textures/pine_branch_1.png",
		"res://Assets/PSX/PSX Nature/textures/pine_branch_2.png",
		"res://Assets/PSX/PSX Nature/textures/pine_branch_3.png",
		"res://Assets/PSX/PSX Nature/textures/grass_1.png"  # Fallback for trees
	],
	"vegetation": [
		"res://Assets/PSX/PSX Nature/textures/grass_1.png",
		"res://Assets/PSX/PSX Nature/textures/grass_2.png",
		"res://Assets/PSX/PSX Nature/textures/grass_3.png",
		"res://Assets/PSX/PSX Nature/textures/grass_4.png",
		"res://Assets/PSX/PSX Nature/textures/fern_1.png",
		"res://Assets/PSX/PSX Nature/textures/fern_2.png",
		"res://Assets/PSX/PSX Nature/textures/fern_3.png"
	],
	"stones": [
		"res://Assets/PSX/PSX Nature/textures/stone_1.png",
		"res://Assets/PSX/PSX Nature/textures/stone_2.png"
	],
	"debris": [
		"res://Assets/PSX/PSX Nature/textures/grass_1.png",  # Fallback for debris
		"res://Assets/PSX/PSX Nature/textures/stone_1.png"   # Fallback for debris
	],
	"mushrooms": [
		"res://Assets/PSX/PSX Nature/textures/grass_1.png",  # Fallback for mushrooms
		"res://Assets/PSX/PSX Nature/textures/stone_1.png"   # Fallback for mushrooms
	]
}

# Intelligent texture assignment system
var available_textures_cache = {}
var texture_assignment_mode = "conditional"  # "conditional", "random", "none"

func _ready():
	GameLogger.info("TestPSXAssets: Starting PSX asset test")
	
	# Get camera reference
	camera = get_node_or_null("Camera3D")
	if not camera:
		GameLogger.error("TestPSXAssets: Camera3D not found!")
		return
	
	# Create UI overlay
	create_ui_overlay()
	
	# Initialize intelligent texture system
	initialize_texture_system()
	
	# Load PSX asset pack
	psx_asset_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if not psx_asset_pack:
		GameLogger.error("TestPSXAssets: Failed to load PSX asset pack")
		return
	
	# Debug: Check if the asset pack has the expected content
	GameLogger.info("TestPSXAssets: Loaded PSX asset pack:")
	GameLogger.info("  - Region: " + psx_asset_pack.region_name)
	GameLogger.info("  - Environment: " + psx_asset_pack.environment_type)
	GameLogger.info("  - Total assets: " + str(psx_asset_pack.get_all_assets().size()))
	
	# If the asset pack seems empty, create a test one
	if psx_asset_pack.get_all_assets().size() < 5:
		GameLogger.warning("TestPSXAssets: PSX asset pack seems empty, creating test pack...")
		create_test_asset_pack()
	
	# Test PSX asset validation
	test_psx_asset_validation()
	
	# Test PSX asset placement
	test_psx_asset_placement()
	
	GameLogger.info("TestPSXAssets: PSX asset test completed")
	
	# Update status
	update_status("Ready! Use UI buttons to test features.")

func initialize_texture_system():
	"""Initialize the intelligent texture assignment system"""
	GameLogger.info("TestPSXAssets: Initializing intelligent texture system...")
	
	# Validate and cache available textures for each category
	for category in category_textures:
		var valid_textures = []
		var texture_paths = category_textures[category]
		
		for texture_path in texture_paths:
			if FileAccess.file_exists(texture_path):
				# Load the actual texture resource
				var texture = load(texture_path)
				if texture:
					valid_textures.append(texture)
					GameLogger.info("TestPSXAssets: Valid texture loaded: " + texture_path)
				else:
					GameLogger.warning("TestPSXAssets: Failed to load texture: " + texture_path)
			else:
				GameLogger.warning("TestPSXAssets: Missing texture file: " + texture_path)
		
		available_textures_cache[category] = valid_textures
		GameLogger.info("TestPSXAssets: Category '" + category + "' has " + str(valid_textures.size()) + " valid textures")
	
	# Create fallback textures if needed
	create_fallback_textures()

func create_fallback_textures():
	"""Create fallback textures for categories that have no valid textures"""
	for category in available_textures_cache:
		if available_textures_cache[category].size() == 0:
			GameLogger.warning("TestPSXAssets: No valid textures for category '" + category + "', creating colored fallback material...")
			var fallback_material = StandardMaterial3D.new()
			match category:
				"trees": fallback_material.albedo_color = Color.from_hsv(0.3, 0.5, 0.5)  # Dark Green
				"vegetation": fallback_material.albedo_color = Color.from_hsv(0.2, 0.7, 0.7)  # Bright Green
				"stones": fallback_material.albedo_color = Color.from_hsv(0.0, 0.0, 0.4)  # Grey
				"debris": fallback_material.albedo_color = Color.from_hsv(0.1, 0.6, 0.4)  # Brown
				"mushrooms": fallback_material.albedo_color = Color.from_hsv(0.9, 0.6, 0.8)  # Pink/Red
				_: fallback_material.albedo_color = Color.from_hsv(0.5, 0.5, 0.8)  # Default Blue
			
			# Store the fallback material directly in the cache
			available_textures_cache[category] = [fallback_material]
			GameLogger.info("TestPSXAssets: Created colored fallback material for '" + category + "'")

func create_colored_material_fallback(category: String):
	"""Create a simple colored material when no textures are available"""
	var color = Color.WHITE
	
	match category:
		"trees":
			color = Color(0.4, 0.3, 0.2)  # Brown
		"vegetation":
			color = Color(0.2, 0.6, 0.2)  # Green
		"stones":
			color = Color(0.5, 0.5, 0.5)  # Gray
		"debris":
			color = Color(0.3, 0.2, 0.1)  # Dark brown
		"mushrooms":
			color = Color(0.8, 0.4, 0.4)  # Reddish
		_:
			color = Color(0.7, 0.7, 0.7)  # Light gray
	
	# Store the color for later use
	if not available_textures_cache.has("fallback_colors"):
		available_textures_cache["fallback_colors"] = {}
	available_textures_cache["fallback_colors"][category] = color

func create_ui_overlay():
	"""Create a simple UI overlay with buttons"""
	# Create main UI panel
	ui_panel = Control.new()
	ui_panel.name = "TestUIPanel"
	add_child(ui_panel)
	
	# Set UI to fill screen
	ui_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create status label
	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "PSX Asset Test - Ready"
	status_label.position = Vector2(10, 10)
	status_label.size = Vector2(400, 30)
	ui_panel.add_child(status_label)
	
	# Create button container
	var button_container = VBoxContainer.new()
	button_container.name = "ButtonContainer"
	button_container.position = Vector2(10, 50)
	button_container.size = Vector2(200, 400)
	ui_panel.add_child(button_container)
	
	# Create buttons
	var buttons = [
		{"name": "TestValidation", "text": "Test Validation", "callback": "test_psx_asset_validation"},
		{"name": "TestPlacement", "text": "Test Placement", "callback": "test_psx_asset_placement"},
		{"name": "AssetInfo", "text": "Asset Info", "callback": "show_asset_info"},
		{"name": "TextureStats", "text": "Texture Stats", "callback": "show_texture_stats"},
		{"name": "ToggleMode", "text": "Toggle Mode: " + texture_assignment_mode, "callback": "toggle_texture_mode"},
		{"name": "ApplyTextures", "text": "Apply Textures", "callback": "apply_textures_to_all_assets"},
		{"name": "ResetTextures", "text": "Reset Textures", "callback": "reset_texture_assignments"},
		{"name": "UVCheck", "text": "Check UV Mapping", "callback": "test_uv_mapping"},
		{"name": "UVFix", "text": "Apply UV Fix", "callback": "apply_textures_with_uv_fix"},
		{"name": "TreeUVFix", "text": "Tree UV Fix", "callback": "apply_tree_uv_fix"},
		{"name": "UVMappingTest", "text": "Test UV Mapping Types", "callback": "test_uv_mapping_types"},
		{"name": "SmartTextures", "text": "Smart Texture Assignment", "callback": "apply_smart_textures"},
		{"name": "ToggleVisibility", "text": "Toggle Assets", "callback": "toggle_asset_visibility"},
		{"name": "ReloadAssets", "text": "Reload Assets", "callback": "reload_assets"},
		{"name": "TreeTest", "text": "Tree Test (Isolated)", "callback": "open_tree_test"},
		{"name": "FormatTest", "text": "Format Comparison", "callback": "open_format_comparison"}
	]
	
	for button_data in buttons:
		var button = Button.new()
		button.name = button_data.name
		button.text = button_data.text
		button.custom_minimum_size = Vector2(180, 30)
		button_container.add_child(button)
		button.pressed.connect(Callable(self, button_data.callback))
	
	# Create camera controls info
	var camera_info = Label.new()
	camera_info.name = "CameraInfo"
	camera_info.text = "Camera: WASD to move, TAB to capture mouse, SPACE to toggle assets, ESC to exit scene"
	camera_info.position = Vector2(10, 460)
	camera_info.size = Vector2(500, 30)
	ui_panel.add_child(camera_info)

func update_status(message: String):
	"""Update the status label"""
	if status_label:
		status_label.text = "PSX Asset Test - " + message
	GameLogger.info("TestPSXAssets: " + message)

func show_asset_info():
	"""Show asset pack information"""
	if psx_asset_pack:
		var info = psx_asset_pack.get_pack_info()
		update_status("Asset Pack Info: " + str(info))
	else:
		update_status("No asset pack loaded")

func show_texture_stats():
	"""Show texture assignment statistics"""
	var stats = get_texture_assignment_stats()
	var message = "Textures: " + str(stats.assets_with_textures) + "/" + str(stats.total_assets) + " assets"
	update_status(message)

func toggle_texture_mode():
	"""Toggle texture assignment mode and update button text"""
	toggle_texture_assignment_mode()
	
	# Update button text
	var toggle_button = ui_panel.get_node_or_null("ButtonContainer/ToggleMode")
	if toggle_button:
		toggle_button.text = "Toggle Mode: " + texture_assignment_mode
	
	update_status("Mode: " + texture_assignment_mode)

func create_test_asset_pack():
	"""Create a comprehensive test PSX asset pack with ALL assets"""
	psx_asset_pack = PSXAssetPack.new()
	psx_asset_pack.region_name = "Test"
	psx_asset_pack.environment_type = "test"
	
	# Add proper pine tree assets using Shared folder structure
	psx_asset_pack.trees = [
		"res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_1.glb",
		"res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_2.glb",
		"res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_3.glb"
	]
	
	# Include vegetation using Shared folder structure
	psx_asset_pack.vegetation = [
		"res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_1.glb",
		"res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_2.glb",
		"res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_3.glb",
		"res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_4.glb",
		"res://Assets/Terrain/Shared/psx_models/vegetation/ferns/fern_1.glb",
		"res://Assets/Terrain/Shared/psx_models/vegetation/ferns/fern_2.glb",
		"res://Assets/Terrain/Shared/psx_models/vegetation/ferns/fern_3.glb"
	]
	
	psx_asset_pack.stones = [
		"res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_1.glb",
		"res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_2.glb",
		"res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_3.glb",
		"res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_4.glb",
		"res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_5.glb"
	]
	
	psx_asset_pack.debris = [
		"res://Assets/Terrain/Shared/psx_models/debris/logs/tree_log_1.dae",  # No GLB version available
		"res://Assets/Terrain/Shared/psx_models/debris/stumps/tree_stump_1.dae"  # No GLB version available
	]
	
	# Include mushrooms using Shared folder structure
	psx_asset_pack.mushrooms = [
		"res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_1.glb",
		"res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_2.glb",
		"res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_3.glb",
		"res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_4.glb"
	]
	
	GameLogger.info("TestPSXAssets: Created comprehensive test asset pack with " + str(psx_asset_pack.get_all_assets().size()) + " assets")

func test_psx_asset_validation():
	"""Test PSX asset pack validation"""
	update_status("Testing PSX asset validation...")
	
	# Validate all assets
	var validation = psx_asset_pack.validate_assets()
	if validation.valid:
		var message = "Validation PASSED: " + str(validation.valid_assets) + "/" + str(validation.total_assets) + " assets"
		update_status(message)
	else:
		update_status("Validation FAILED: " + str(validation.missing))
	
	# Test each category
	var categories = ["trees", "vegetation", "stones", "debris", "mushrooms"]
	for category in categories:
		var assets = psx_asset_pack.get_assets_by_category(category)
		GameLogger.info("TestPSXAssets: Category '" + category + "': " + str(assets.size()) + " assets")
		
		# Test first asset in each category
		if assets.size() > 0:
			var first_asset = assets[0]
			var scene = load(first_asset)
			if not scene:
				update_status("Failed to load " + category + " asset: " + first_asset.get_file())
				return
	
	update_status("All assets validated successfully!")

func test_psx_asset_placement():
	"""Test PSX asset placement functionality with comprehensive error handling"""
	update_status("Testing PSX asset placement...")
	
	# Create a container for placed assets
	asset_container = Node3D.new()
	asset_container.name = "PSXAssetContainer"
	add_child(asset_container)
	
	# Test placing assets from each category with detailed error reporting
	var categories = ["trees", "vegetation", "stones", "debris", "mushrooms"]
	var placement_positions = [
		Vector3(2, 0, 2),   # Trees
		Vector3(-2, 0, 2),  # Vegetation
		Vector3(2, 0, -2),  # Stones
		Vector3(-2, 0, -2), # Debris
		Vector3(0, 0, 0)    # Mushrooms
	]
	
	# Add more positions for multiple assets
	var additional_positions = [
		Vector3(4, 0, 4),   # Additional trees
		Vector3(-4, 0, 4),  # Additional stones
		Vector3(4, 0, -4),  # Additional debris
		Vector3(-4, 0, -4), # Additional trees
		Vector3(0, 0, 4),   # Additional stones
		Vector3(0, 0, -4)   # Additional debris
	]
	
	# Track placement results
	var placement_results = {
		"successful": 0,
		"failed": 0,
		"skipped": 0,
		"details": {}
	}
	
	# Place assets from each category with comprehensive testing
	for i in range(categories.size()):
		var category = categories[i]
		var position = placement_positions[i]
		
		# Get all assets in this category
		var category_assets = psx_asset_pack.get_assets_by_category(category)
		if category_assets.size() == 0:
			placement_results.skipped += 1
			continue
		
		# Test each asset in the category
		var successful_placements = 0
		for asset_path in category_assets:
			var result = try_place_asset(asset_path, position, asset_container, category)
			if result.success:
				successful_placements += 1
				placement_results.successful += 1
				# Move position slightly for next asset
				position += Vector3(1, 0, 1)
			else:
				placement_results.failed += 1
		
		placement_results.details[category] = {
			"total": category_assets.size(),
			"successful": successful_placements,
			"failed": category_assets.size() - successful_placements
		}
	
	# Place additional assets for categories that work
	var working_categories = ["trees", "stones", "debris"]
	for i in range(working_categories.size()):
		var category = working_categories[i]
		var position = additional_positions[i]
		
		var asset_path = psx_asset_pack.get_random_asset(category)
		if asset_path != "":
			var result = try_place_asset(asset_path, position, asset_container, category)
			if result.success:
				placement_results.successful += 1
			else:
				placement_results.failed += 1
	
	# Report final results
	var message = "Placement: " + str(placement_results.successful) + " successful, " + str(placement_results.failed) + " failed"
	update_status(message)

func try_place_asset(asset_path: String, position: Vector3, container: Node3D, category: String) -> Dictionary:
	"""Try to place an asset with comprehensive error handling"""
	var result = {
		"success": false,
		"error": "",
		"asset_path": asset_path
	}
	
	# Try to load the asset
	var asset_scene = null
	
	# Try to load with error handling
	asset_scene = load(asset_path)
	
	if not asset_scene:
		result.error = "Failed to load scene"
		return result
	
	# Try to instantiate
	var asset_instance = null
	asset_instance = asset_scene.instantiate()
	
	if not asset_instance:
		result.error = "Failed to instantiate scene"
		return result
	
	# Check if the instance has any visual components
	var has_visual = false
	if asset_instance is Node3D:
		# Check for MeshInstance3D, CSGBox3D, or other visual nodes
		var visual_nodes = []
		collect_visual_nodes(asset_instance, visual_nodes)
		has_visual = visual_nodes.size() > 0
		
		if not has_visual:
			result.error = "No visual components found"
			return result
	
	# Place the asset
	asset_instance.transform.origin = position
	container.add_child(asset_instance)
	
	# Assign texture if needed
	assign_texture_to_asset(asset_instance, category)
	
	# Check if asset has textures and mark accordingly
	var has_textures = check_asset_has_textures(asset_instance)
	var marker_color = Color.GREEN if has_textures else Color.YELLOW
	
	# Add a visual marker (small sphere) to show placement location
	var marker = CSGSphere3D.new()
	marker.radius = 0.1
	marker.material = StandardMaterial3D.new()
	marker.material.albedo_color = marker_color
	marker.position = position
	marker.position.y = 0.1  # Slightly above ground
	container.add_child(marker)
	
	result.success = true
	GameLogger.info("TestPSXAssets: Successfully placed " + category + " asset: " + asset_path.get_file() + " at " + str(position))
	
	return result

func collect_visual_nodes(node: Node, visual_nodes: Array):
	"""Recursively collect visual nodes from the scene tree"""
	if node is MeshInstance3D or node is CSGBox3D or node is CSGCylinder3D or node is CSGSphere3D:
		visual_nodes.append(node)
	
	for child in node.get_children():
		collect_visual_nodes(child, visual_nodes)

func check_asset_has_textures(asset_instance: Node) -> bool:
	"""Check if an asset instance has textures"""
	if asset_instance is Node3D:
		return check_node_for_textures(asset_instance)
	return false

func check_node_for_textures(node: Node) -> bool:
	"""Recursively check if a node has textures"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material and material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					if std_material.albedo_texture:
						return true
	
	for child in node.get_children():
		if check_node_for_textures(child):
			return true
	
	return false

func assign_texture_to_asset(asset_instance: Node, category: String):
	"""Intelligently assign appropriate texture to an asset based on category and mode"""
	if texture_assignment_mode == "none":
		return
	
	if not asset_instance is Node3D:
		return
	
	# Check if asset already has textures
	if check_asset_has_textures(asset_instance):
		GameLogger.info("TestPSXAssets: Asset already has textures, skipping assignment")
		return
	
	# Special handling for tree assets - preserve original UV mapping and use specific textures
	if category == "trees":
		assign_tree_specific_texture(asset_instance)
		return
	
	# Get available resources for this category from cache
	var available_resources = available_textures_cache.get(category, [])
	if available_resources.size() > 0:
		# Select resource based on mode
		var selected_resource = null
		match texture_assignment_mode:
			"conditional":
				selected_resource = available_resources[0]
			"random":
				selected_resource = available_resources[randi() % available_resources.size()]
		
		if selected_resource is Texture2D:
			apply_texture_to_node(asset_instance, selected_resource)
			GameLogger.info("TestPSXAssets: Applied texture " + selected_resource.resource_path.get_file() + " to " + category + " asset")
		elif selected_resource is StandardMaterial3D:
			apply_material_to_node(asset_instance, selected_resource)
			GameLogger.info("TestPSXAssets: Applied colored fallback material to " + category + " asset")
		else:
			GameLogger.error("TestPSXAssets: Invalid resource type in cache for category " + category + " (type: " + str(selected_resource.get_class()) + ")")
	else:
		GameLogger.warning("TestPSXAssets: No textures or fallback materials available for category: " + category)

func try_fallback_texture(asset_instance: Node, category: String, failed_texture: Texture2D):
	"""Try to use a fallback texture if the selected one failed to load"""
	var available_textures = available_textures_cache.get(category, [])
	
	# Remove the failed texture from the list
	available_textures.erase(failed_texture)
	
	if available_textures.size() > 0:
		# Try the next available texture
		var fallback_texture = available_textures[0]
		if fallback_texture is Texture2D:
			apply_texture_to_node(asset_instance, fallback_texture)
			GameLogger.info("TestPSXAssets: Applied fallback texture " + fallback_texture.resource_path.get_file() + " to " + category + " asset")
		elif fallback_texture is StandardMaterial3D:
			apply_material_to_node(asset_instance, fallback_texture)
			GameLogger.info("TestPSXAssets: Applied fallback material to " + category + " asset")
		else:
			GameLogger.error("TestPSXAssets: Invalid fallback resource type for category " + category)
			apply_colored_material_fallback_to_asset(asset_instance, category)
	else:
		GameLogger.warning("TestPSXAssets: No fallback textures available for category: " + category)
		apply_colored_material_fallback_to_asset(asset_instance, category)

func apply_colored_material_fallback_to_asset(asset_instance: Node, category: String):
	"""Apply a colored material when no textures are available"""
	var fallback_colors = available_textures_cache.get("fallback_colors", {})
	var color = fallback_colors.get(category, Color(0.7, 0.7, 0.7))
	
	apply_color_to_node(asset_instance, color)
	GameLogger.info("TestPSXAssets: Applied colored material to " + category + " asset: " + str(color))

func apply_color_to_node(node: Node, color: Color):
	"""Apply a solid color to all MeshInstance3D nodes"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material and material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					std_material.albedo_color = color
					GameLogger.info("TestPSXAssets: Applied color " + str(color) + " to mesh surface " + str(i))
	
	# Recursively apply to children
	for child in node.get_children():
		apply_color_to_node(child, color)

func apply_material_to_node(node: Node, material: StandardMaterial3D):
	"""Apply a StandardMaterial3D to a node"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				node.set_surface_override_material(i, material)
	
	# Recursively apply to children
	for child in node.get_children():
		apply_material_to_node(child, material)

func assign_tree_specific_texture(asset_instance: Node):
	"""Assign tree-specific texture while preserving original UV mapping"""
	GameLogger.info("TestPSXAssets: Assigning tree-specific texture to " + asset_instance.name)
	
	# Try to match the asset name to its specific texture
	var asset_name = asset_instance.name
	var texture_path = ""
	
	# Extract the tree number from the asset name (e.g., "tree_1" -> "1")
	if asset_name.begins_with("tree_"):
		var tree_number = asset_name.substr(5)  # Remove "tree_" prefix
		texture_path = "res://Assets/PSX/PSX Nature/textures/tree_" + tree_number + ".png"
		
		# Check if the specific texture exists
		if not FileAccess.file_exists(texture_path):
			GameLogger.warning("TestPSXAssets: Specific texture not found: " + texture_path)
			# Fall back to the first available tree texture
			var available_textures = available_textures_cache.get("trees", [])
			if available_textures.size() > 0:
				texture_path = available_textures[0] if available_textures[0] is String else ""
			else:
				GameLogger.error("TestPSXAssets: No tree textures available")
				return
	else:
		# For non-numbered trees, use the first available texture
		var available_textures = available_textures_cache.get("trees", [])
		if available_textures.size() > 0:
			texture_path = available_textures[0] if available_textures[0] is String else ""
		else:
			GameLogger.error("TestPSXAssets: No tree textures available")
			return
	
	if texture_path == "":
		GameLogger.error("TestPSXAssets: Could not determine texture path for " + asset_name)
		return
	
	# Load the texture
	var texture = load(texture_path)
	if not texture:
		GameLogger.error("TestPSXAssets: Failed to load tree texture: " + texture_path)
		return
	
	# Apply texture to the COMPLETE tree as a unit, preserving ALL original UV mapping
	apply_complete_tree_texture(asset_instance, texture)
	GameLogger.info("TestPSXAssets: Applied tree-specific texture " + texture_path.get_file() + " to " + asset_name)

func apply_complete_tree_texture(node: Node, texture: Texture2D):
	"""Apply texture to the complete tree as a unit, preserving ALL original structure"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			GameLogger.info("TestPSXAssets: Applying texture to complete tree mesh: " + node.name)
			
			# Apply texture to ALL surfaces without modifying ANY UV mapping
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if not material:
					# Create new material if none exists
					material = StandardMaterial3D.new()
					mesh.surface_set_material(i, material)
				
				if material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					std_material.albedo_texture = texture
					# Set texture filtering for PSX style
					std_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
					# DO NOT modify UV scaling - keep original
					GameLogger.info("TestPSXAssets: Applied texture to surface " + str(i) + " with COMPLETE original UV mapping")
	
	# Recursively apply to children
	for child in node.get_children():
		apply_complete_tree_texture(child, texture)

func apply_texture_to_node(node: Node, texture: Texture2D):
	"""Recursively apply texture to all MeshInstance3D nodes with proper settings"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material and material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					if not std_material.albedo_texture:  # Only apply if no texture exists
						std_material.albedo_texture = texture
						
						# Set proper texture settings based on object size
						var object_size = get_object_size(node)
						if object_size < 0.5:  # Small objects like mushrooms
							std_material.uv1_scale = Vector3(2.0, 2.0, 2.0)  # Tile more
						elif object_size < 1.0:  # Medium objects
							std_material.uv1_scale = Vector3(1.5, 1.5, 1.5)
						else:  # Large objects like trees
							std_material.uv1_scale = Vector3(1.0, 1.0, 1.0)
						
						GameLogger.info("TestPSXAssets: Applied texture to mesh surface " + str(i) + " with scale " + str(std_material.uv1_scale))
	
	# Recursively apply to children
	for child in node.get_children():
		apply_texture_to_node(child, texture)

func get_object_size(node: Node3D) -> float:
	"""Get the approximate size of an object for texture scaling"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			var aabb = mesh.get_aabb()
			return max(aabb.size.x, aabb.size.y, aabb.size.z)
	return 1.0

func get_texture_assignment_stats() -> Dictionary:
	"""Get statistics about texture assignments"""
	var stats = {
		"total_assets": 0,
		"assets_with_textures": 0,
		"assets_without_textures": 0,
		"textures_assigned": 0,
		"by_category": {}
	}
	
	if not asset_container:
		return stats
	
	# Count assets in container
	count_assets_in_node(asset_container, stats)
	
	return stats

func count_assets_in_node(node: Node, stats: Dictionary):
	"""Recursively count assets and their texture status"""
	if node.name.begins_with("grass_") or node.name.begins_with("tree_") or node.name.begins_with("stone_") or node.name.begins_with("mushroom_") or node.name.begins_with("fern_"):
		stats.total_assets += 1
		
		if check_asset_has_textures(node):
			stats.assets_with_textures += 1
		else:
			stats.assets_without_textures += 1
	
	for child in node.get_children():
		count_assets_in_node(child, stats)

func toggle_texture_assignment_mode():
	"""Toggle between texture assignment modes"""
	match texture_assignment_mode:
		"conditional":
			texture_assignment_mode = "random"
		"random":
			texture_assignment_mode = "none"
		"none":
			texture_assignment_mode = "conditional"
	
	GameLogger.info("TestPSXAssets: Current mode: " + texture_assignment_mode)

func apply_textures_to_all_assets():
	"""Apply textures to all assets in the container"""
	if not asset_container:
		update_status("No asset container found")
		return
	
	update_status("Applying textures to all assets...")
	var applied_count = 0
	
	# Apply textures to all assets in container
	apply_textures_to_node_recursive(asset_container, applied_count)
	
	update_status("Applied textures to " + str(applied_count) + " assets")

func apply_textures_to_node_recursive(node: Node, applied_count: int):
	"""Recursively apply textures to assets in the node tree"""
	# Check if this node is an asset that needs texture
	if node.name.begins_with("grass_"):
		assign_texture_to_asset(node, "vegetation")
		applied_count += 1
	elif node.name.begins_with("tree_"):
		assign_texture_to_asset(node, "trees")
		applied_count += 1
	elif node.name.begins_with("stone_"):
		assign_texture_to_asset(node, "stones")
		applied_count += 1
	elif node.name.begins_with("mushroom_"):
		assign_texture_to_asset(node, "mushrooms")
		applied_count += 1
	elif node.name.begins_with("fern_"):
		assign_texture_to_asset(node, "vegetation")
		applied_count += 1
	
	# Recursively process children
	for child in node.get_children():
		apply_textures_to_node_recursive(child, applied_count)

func reset_texture_assignments():
	"""Reset all texture assignments (remove applied textures)"""
	if not asset_container:
		update_status("No asset container found")
		return
	
	update_status("Resetting texture assignments...")
	var reset_count = 0
	
	# Reset textures in all assets
	reset_textures_in_node_recursive(asset_container, reset_count)
	
	update_status("Reset textures for " + str(reset_count) + " assets")

func reset_textures_in_node_recursive(node: Node, reset_count: int):
	"""Recursively reset textures in the node tree"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material and material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					if std_material.albedo_texture:
						std_material.albedo_texture = null
						reset_count += 1
						GameLogger.info("TestPSXAssets: Reset texture for mesh surface " + str(i))
	
	# Recursively process children
	for child in node.get_children():
		reset_textures_in_node_recursive(child, reset_count)

func test_texture_diagnostics():
	"""Comprehensive texture diagnostics"""
	GameLogger.info("TestPSXAssets: Texture diagnostics...")
	
	# Check if texture files exist directly
	var texture_paths = [
		"res://Assets/PSX/PSX Nature/textures/grass_1.png",
		"res://Assets/PSX/PSX Nature/textures/fern_1.png",
		"res://Assets/PSX/PSX Nature/textures/mushrooms_n_1.png"
	]
	
	GameLogger.info("TestPSXAssets: Checking texture file existence:")
	for texture_path in texture_paths:
		var exists = FileAccess.file_exists(texture_path)
		GameLogger.info("TestPSXAssets: " + texture_path + " exists: " + str(exists))
	
	# Check what the GLB files are actually trying to load
	var test_asset = "res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_1.glb"
	var asset_scene = load(test_asset)
	if asset_scene:
		var asset_instance = asset_scene.instantiate()
		if asset_instance:
			var fbx_texture_paths = []
			collect_texture_paths(asset_instance, fbx_texture_paths)
			
			GameLogger.info("TestPSXAssets: FBX references " + str(fbx_texture_paths.size()) + " textures:")
			for path in fbx_texture_paths:
				GameLogger.info("TestPSXAssets: FBX texture: " + path)
				var fbx_exists = FileAccess.file_exists(path)
				GameLogger.info("TestPSXAssets: FBX texture exists: " + str(fbx_exists))
			
			asset_instance.queue_free()
		else:
			GameLogger.error("TestPSXAssets: No instance")
	else:
		GameLogger.error("TestPSXAssets: No scene")

func test_simple_glb_textures():
	"""Simple test to get GLB texture paths"""
	GameLogger.info("TestPSXAssets: Simple GLB texture test...")
	
	var test_asset = "res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_1.glb"
	var asset_scene = load(test_asset)
	if asset_scene:
		var asset_instance = asset_scene.instantiate()
		if asset_instance:
			var fbx_texture_paths = []
			collect_texture_paths(asset_instance, fbx_texture_paths)
			
			GameLogger.info("TestPSXAssets: Grass1 FBX has " + str(fbx_texture_paths.size()) + " texture references:")
			for i in range(fbx_texture_paths.size()):
				var path = fbx_texture_paths[i]
				GameLogger.info("TestPSXAssets: Texture " + str(i) + ": " + path)
			
			asset_instance.queue_free()
		else:
			GameLogger.error("TestPSXAssets: No instance")
	else:
		GameLogger.error("TestPSXAssets: No scene")

func collect_texture_paths(node: Node, texture_paths: Array):
	"""Recursively collect texture paths from the scene tree"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			# Check mesh materials
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material:
					collect_material_textures(material, texture_paths)
	
	for child in node.get_children():
		collect_texture_paths(child, texture_paths)

func collect_material_textures(material: Material, texture_paths: Array):
	"""Collect texture paths from a material"""
	if material is StandardMaterial3D:
		var std_material = material as StandardMaterial3D
		if std_material.albedo_texture:
			texture_paths.append(std_material.albedo_texture.resource_path)
		if std_material.normal_texture:
			texture_paths.append(std_material.normal_texture.resource_path)
		if std_material.roughness_texture:
			texture_paths.append(std_material.roughness_texture.resource_path)

func test_uv_mapping():
	"""Test UV mapping on all assets"""
	update_status("Testing UV mapping on all assets...")
	
	if not asset_container:
		update_status("No asset container found")
		return
	
	var total_assets = 0
	var assets_with_uv = 0
	var assets_without_uv = 0
	
	# Check UV mapping on all assets
	check_uv_mapping_recursive(asset_container, total_assets, assets_with_uv, assets_without_uv)
	
	var message = "UV Mapping: " + str(assets_with_uv) + "/" + str(total_assets) + " assets have UV"
	update_status(message)
	
	if assets_without_uv > 0:
		update_status("Some assets need UV mapping fixes!")

func check_uv_mapping_recursive(node: Node, total_assets: int, assets_with_uv: int, assets_without_uv: int):
	"""Recursively check UV mapping on all nodes"""
	if node.name.begins_with("grass_") or node.name.begins_with("tree_") or node.name.begins_with("stone_") or node.name.begins_with("mushroom_") or node.name.begins_with("fern_"):
		total_assets += 1
		
		var uv_info = check_uv_mapping(node)
		if uv_info.has_uv:
			assets_with_uv += 1
		else:
			assets_without_uv += 1
	
	for child in node.get_children():
		check_uv_mapping_recursive(child, total_assets, assets_with_uv, assets_without_uv)

func apply_textures_with_uv_fix():
	"""Apply textures to all assets with UV mapping fix"""
	if not asset_container:
		update_status("No asset container found")
		return
	
	update_status("Applying textures with UV mapping fix...")
	
	# Get available textures
	var available_textures = []
	for category in category_textures:
		available_textures.append_array(category_textures[category])
	
	if available_textures.size() == 0:
		update_status("No textures available")
		return
	
	# Apply textures with UV fix to all assets
	apply_textures_with_uv_fix_recursive(asset_container, available_textures)
	
	update_status("Applied textures with UV fix to all assets")

func apply_textures_with_uv_fix_recursive(node: Node, available_textures: Array):
	"""Recursively apply textures with UV fix using intelligent category matching"""
	# Determine category based on node name
	var category = determine_asset_category(node.name)
	
	if category != "":
		# Get textures for this specific category
		var category_textures = available_textures_cache.get(category, [])
		if category_textures.size() > 0:
			# Select a texture from the category
			var selected_texture = category_textures[randi() % category_textures.size()]
			if selected_texture is Texture2D:
				apply_texture_with_uv_fix(node, selected_texture)
				GameLogger.info("TestPSXAssets: Applied " + category + " texture with UV fix to " + node.name)
			elif selected_texture is StandardMaterial3D:
				apply_material_to_node(node, selected_texture)
				GameLogger.info("TestPSXAssets: Applied " + category + " material with UV fix to " + node.name)
			else:
				GameLogger.error("TestPSXAssets: Invalid texture type for " + category + ": " + str(selected_texture.get_class()))
		else:
			# Use fallback textures
			if available_textures.size() > 0:
				var selected_texture = available_textures[randi() % available_textures.size()]
				if selected_texture is Texture2D:
					apply_texture_with_uv_fix(node, selected_texture)
					GameLogger.info("TestPSXAssets: Applied fallback texture with UV fix to " + node.name)
				elif selected_texture is StandardMaterial3D:
					apply_material_to_node(node, selected_texture)
					GameLogger.info("TestPSXAssets: Applied fallback material with UV fix to " + node.name)
	
	for child in node.get_children():
		apply_textures_with_uv_fix_recursive(child, available_textures)

func determine_asset_category(asset_name: String) -> String:
	"""Determine the category of an asset based on its name"""
	if asset_name.begins_with("tree_"):
		return "trees"
	elif asset_name.begins_with("grass_") or asset_name.begins_with("fern_"):
		return "vegetation"
	elif asset_name.begins_with("stone_"):
		return "stones"
	elif asset_name.begins_with("mushroom_"):
		return "mushrooms"
	elif asset_name.begins_with("log_") or asset_name.begins_with("stump_"):
		return "debris"
	else:
		return ""

func check_uv_mapping(asset_instance: Node) -> Dictionary:
	"""Check if an asset has proper UV mapping"""
	var uv_info = {
		"has_uv": false,
		"uv_channels": 0,
		"mesh_surfaces": 0,
		"details": []
	}
	
	if asset_instance is Node3D:
		check_node_uv_mapping(asset_instance, uv_info)
	
	return uv_info

func check_node_uv_mapping(node: Node, uv_info: Dictionary):
	"""Recursively check UV mapping in the node tree"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			uv_info.mesh_surfaces += 1
			var surface_details = {
				"node_name": node.name,
				"surface_index": uv_info.mesh_surfaces - 1,
				"has_uv": false,
				"vertex_count": 0,
				"uv_count": 0
			}
			
			# Check if mesh has UV coordinates
			if mesh.surface_get_format(0) & Mesh.ARRAY_TEX_UV:
				uv_info.has_uv = true
				surface_details.has_uv = true
				surface_details.vertex_count = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()
				surface_details.uv_count = mesh.surface_get_arrays(0)[Mesh.ARRAY_TEX_UV].size()
				GameLogger.info("TestPSXAssets: " + node.name + " has UV mapping: " + str(surface_details.uv_count) + " UV coordinates")
			else:
				GameLogger.warning("TestPSXAssets: " + node.name + " has NO UV mapping!")
			
			uv_info.details.append(surface_details)
	
	for child in node.get_children():
		check_node_uv_mapping(child, uv_info)

func create_simple_uv_mapping(mesh: Mesh) -> Mesh:
	"""Create simple UV mapping for a mesh if it doesn't have any"""
	var new_mesh = mesh.duplicate()
	
	for surface_idx in range(new_mesh.get_surface_count()):
		var arrays = new_mesh.surface_get_arrays(surface_idx)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var normals = arrays[Mesh.ARRAY_NORMAL] if arrays.size() > Mesh.ARRAY_NORMAL else []
		
		# Create simple planar UV mapping
		var uvs = []
		for i in range(vertices.size()):
			var vertex = vertices[i]
			# Simple planar mapping based on X and Z coordinates
			var u = (vertex.x + 1.0) * 0.5  # Map X to U (0-1)
			var v = (vertex.z + 1.0) * 0.5  # Map Z to V (0-1)
			uvs.append(Vector2(u, v))
		
		# Update arrays with UV coordinates
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		new_mesh.surface_remove(surface_idx)
		new_mesh.surface_add_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return new_mesh

func create_proper_uv_mapping(mesh: Mesh, geometry_type: String = "auto") -> Mesh:
	"""Create proper UV mapping based on geometry type"""
	# Create a new ArrayMesh instead of duplicating the original
	var new_mesh = ArrayMesh.new()
	
	# Auto-detect geometry type if not specified
	if geometry_type == "auto":
		geometry_type = detect_geometry_type(mesh)
	
	GameLogger.info("TestPSXAssets: Creating UV mapping with type: " + geometry_type)
	
	# Process all surfaces from the original mesh
	for surface_idx in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface_idx)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var normals = arrays[Mesh.ARRAY_NORMAL] if arrays.size() > Mesh.ARRAY_NORMAL else []
		
		GameLogger.info("TestPSXAssets: Surface " + str(surface_idx) + " - Vertices: " + str(vertices.size()) + ", Normals: " + str(normals.size()))
		
		var uvs = []
		match geometry_type:
			"cylindrical":
				# Cylindrical mapping for tree trunks, branches
				uvs = create_cylindrical_uvs(vertices)
			"spherical":
				# Spherical mapping for round objects
				uvs = create_spherical_uvs(vertices)
			"planar":
				# Planar mapping for flat surfaces
				uvs = create_planar_uvs(vertices)
			"triplanar":
				# Triplanar mapping for complex geometry
				uvs = create_triplanar_uvs(vertices, normals)
			_:
				# Default to cylindrical for most natural objects
				uvs = create_cylindrical_uvs(vertices)
		
		# Update arrays with UV coordinates
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		
		# Add the surface to the new mesh
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		
		# Copy materials if they exist
		var material = mesh.surface_get_material(surface_idx)
		if material:
			new_mesh.surface_set_material(new_mesh.get_surface_count() - 1, material)
	
	return new_mesh

func detect_geometry_type(mesh: Mesh) -> String:
	"""Auto-detect the best UV mapping type for the geometry"""
	var arrays = mesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	
	if vertices.size() == 0:
		return "planar"
	
	# Calculate bounding box
	var min_pos = vertices[0]
	var max_pos = vertices[0]
	for vertex in vertices:
		min_pos = min_pos.min(vertex)
		max_pos = max_pos.max(vertex)
	
	var size = max_pos - min_pos
	var center = (min_pos + max_pos) * 0.5
	
	# Debug info
	GameLogger.info("TestPSXAssets: Geometry analysis - Size: " + str(size) + ", Center: " + str(center))
	
	# Check if it's roughly cylindrical (tree trunk, branch)
	var height = size.y
	var radius = (size.x + size.z) * 0.5
	if height > radius * 2.0:
		GameLogger.info("TestPSXAssets: Detected cylindrical geometry (height: " + str(height) + ", radius: " + str(radius) + ")")
		return "cylindrical"
	
	# Check if it's roughly spherical
	var aspect_ratio = max(size.x, size.y, size.z) / min(size.x, size.y, size.z)
	if aspect_ratio < 1.5:
		GameLogger.info("TestPSXAssets: Detected spherical geometry (aspect ratio: " + str(aspect_ratio) + ")")
		return "spherical"
	
	# Check if it's flat (leaves, grass)
	if size.y < (size.x + size.z) * 0.1:
		GameLogger.info("TestPSXAssets: Detected planar geometry (flat surface)")
		return "planar"
	
	# Default to cylindrical for natural objects
	GameLogger.info("TestPSXAssets: Defaulting to cylindrical geometry")
	return "cylindrical"

func create_cylindrical_uvs(vertices: PackedVector3Array) -> PackedVector2Array:
	"""Create cylindrical UV mapping for tree trunks and branches"""
	var uvs = PackedVector2Array()
	
	# Calculate bounding box to normalize coordinates
	var min_pos = vertices[0]
	var max_pos = vertices[0]
	for vertex in vertices:
		min_pos = min_pos.min(vertex)
		max_pos = max_pos.max(vertex)
	
	var size = max_pos - min_pos
	var center = (min_pos + max_pos) * 0.5
	
	# Debug info
	GameLogger.info("TestPSXAssets: Creating cylindrical UVs - Size: " + str(size) + ", Center: " + str(center))
	
	for vertex in vertices:
		# Calculate cylindrical coordinates relative to center
		var relative_pos = vertex - center
		var angle = atan2(relative_pos.x, relative_pos.z)
		var u = (angle + PI) / (2.0 * PI)  # Map angle to U (0-1)
		
		# Map height to V coordinate, normalized to actual height
		var v = (vertex.y - min_pos.y) / size.y if size.y > 0 else 0.5
		
		# Ensure UV coordinates are in valid range
		u = clamp(u, 0.0, 1.0)
		v = clamp(v, 0.0, 1.0)
		
		uvs.append(Vector2(u, v))
	
	# Debug UV range
	var min_uv = uvs[0]
	var max_uv = uvs[0]
	for uv in uvs:
		min_uv = min_uv.min(uv)
		max_uv = max_uv.max(uv)
	GameLogger.info("TestPSXAssets: Cylindrical UV range - Min: " + str(min_uv) + ", Max: " + str(max_uv))
	
	return uvs

func create_spherical_uvs(vertices: PackedVector3Array) -> PackedVector2Array:
	"""Create spherical UV mapping for round objects"""
	var uvs = PackedVector2Array()
	
	# Calculate bounding box to find center
	var min_pos = vertices[0]
	var max_pos = vertices[0]
	for vertex in vertices:
		min_pos = min_pos.min(vertex)
		max_pos = max_pos.max(vertex)
	
	var center = (min_pos + max_pos) * 0.5
	
	for vertex in vertices:
		# Calculate direction from center
		var relative_pos = vertex - center
		var direction = relative_pos.normalized()
		
		# Calculate spherical coordinates
		var u = 0.5 + atan2(direction.x, direction.z) / (2.0 * PI)
		var v = 0.5 - asin(direction.y) / PI
		
		# Ensure UV coordinates are in valid range
		u = clamp(u, 0.0, 1.0)
		v = clamp(v, 0.0, 1.0)
		
		uvs.append(Vector2(u, v))
	
	return uvs

func create_planar_uvs(vertices: PackedVector3Array) -> PackedVector2Array:
	"""Create planar UV mapping for flat surfaces like leaves"""
	var uvs = PackedVector2Array()
	
	# Calculate bounding box to normalize UV coordinates
	var min_pos = vertices[0]
	var max_pos = vertices[0]
	for vertex in vertices:
		min_pos = min_pos.min(vertex)
		max_pos = max_pos.max(vertex)
	
	var size = max_pos - min_pos
	
	# Debug info
	GameLogger.info("TestPSXAssets: Creating planar UVs - Size: " + str(size))
	
	for vertex in vertices:
		# Normalize coordinates based on actual geometry bounds
		var u = (vertex.x - min_pos.x) / size.x if size.x > 0 else 0.5
		var v = (vertex.z - min_pos.z) / size.z if size.z > 0 else 0.5
		
		# Ensure UV coordinates are in valid range
		u = clamp(u, 0.0, 1.0)
		v = clamp(v, 0.0, 1.0)
		
		uvs.append(Vector2(u, v))
	
	# Debug UV range
	var min_uv = uvs[0]
	var max_uv = uvs[0]
	for uv in uvs:
		min_uv = min_uv.min(uv)
		max_uv = max_uv.max(uv)
	GameLogger.info("TestPSXAssets: Planar UV range - Min: " + str(min_uv) + ", Max: " + str(max_uv))
	
	return uvs

func create_triplanar_uvs(vertices: PackedVector3Array, normals: PackedVector3Array) -> PackedVector2Array:
	"""Create triplanar UV mapping for complex geometry"""
	var uvs = PackedVector2Array()
	
	GameLogger.info("TestPSXAssets: Creating triplanar UVs for complex geometry")
	
	for i in range(vertices.size()):
		var vertex = vertices[i]
		var normal = normals[i] if i < normals.size() else Vector3.UP
		
		# Choose the dominant axis for mapping
		var abs_normal = normal.abs()
		var dominant_axis = 0
		if abs_normal.y > abs_normal.x and abs_normal.y > abs_normal.z:
			dominant_axis = 1  # Y dominant
		elif abs_normal.z > abs_normal.x:
			dominant_axis = 2  # Z dominant
		
		var u = 0.0
		var v = 0.0
		
		match dominant_axis:
			0:  # X dominant
				u = (vertex.z + 1.0) * 0.5
				v = (vertex.y + 1.0) * 0.5
			1:  # Y dominant
				u = (vertex.x + 1.0) * 0.5
				v = (vertex.z + 1.0) * 0.5
			2:  # Z dominant
				u = (vertex.x + 1.0) * 0.5
				v = (vertex.y + 1.0) * 0.5
		
		# Ensure UV coordinates are in valid range
		u = clamp(u, 0.0, 1.0)
		v = clamp(v, 0.0, 1.0)
		
		uvs.append(Vector2(u, v))
	
	return uvs

func create_tree_specific_uv_mapping(mesh: Mesh) -> Mesh:
	"""Create specialized UV mapping for tree assets with improved algorithms"""
	var new_mesh = ArrayMesh.new()
	
	GameLogger.info("TestPSXAssets: Creating improved tree-specific UV mapping")
	
	# Process all surfaces from the original mesh
	for surface_idx in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface_idx)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var normals = arrays[Mesh.ARRAY_NORMAL] if arrays.size() > Mesh.ARRAY_NORMAL else []
		
		# Analyze the surface to determine if it's trunk, branch, or leaf
		var size = Vector3.ZERO
		var center = Vector3.ZERO
		
		if vertices.size() > 0:
			var min_pos = vertices[0]
			var max_pos = vertices[0]
			for vertex in vertices:
				min_pos = min_pos.min(vertex)
				max_pos = max_pos.max(vertex)
			size = max_pos - min_pos
			center = (min_pos + max_pos) * 0.5
		
		GameLogger.info("TestPSXAssets: Tree surface " + str(surface_idx) + " - Size: " + str(size) + ", Center: " + str(center))
		
		var uvs = PackedVector2Array()
		
		# Improved detection logic for tree parts
		var height_ratio = size.y / max(size.x, size.z) if max(size.x, size.z) > 0 else 0
		var flatness_ratio = size.y / (size.x + size.z) if (size.x + size.z) > 0 else 0
		
		# Check if it's a leaf (very flat and wide)
		if flatness_ratio < 0.15 and size.x > 0.5 and size.z > 0.5:
			GameLogger.info("TestPSXAssets: Detected leaf surface, using improved planar mapping")
			uvs = create_improved_planar_uvs(vertices, "leaf")
		# Check if it's a trunk (tall and cylindrical)
		elif height_ratio > 2.0 and size.x > 0.3 and size.z > 0.3:
			GameLogger.info("TestPSXAssets: Detected trunk surface, using improved cylindrical mapping")
			uvs = create_improved_cylindrical_uvs(vertices, "trunk")
		# Check if it's a branch (medium height, cylindrical)
		elif height_ratio > 1.0 and size.x > 0.2 and size.z > 0.2:
			GameLogger.info("TestPSXAssets: Detected branch surface, using improved cylindrical mapping")
			uvs = create_improved_cylindrical_uvs(vertices, "branch")
		# Check if it's a root or stump (short and wide)
		elif height_ratio < 0.5 and (size.x > 0.5 or size.z > 0.5):
			GameLogger.info("TestPSXAssets: Detected root/stump surface, using improved planar mapping")
			uvs = create_improved_planar_uvs(vertices, "root")
		else:
			# Complex shape - use improved triplanar
			GameLogger.info("TestPSXAssets: Detected complex surface, using improved triplanar mapping")
			uvs = create_improved_triplanar_uvs(vertices, normals)
		
		# Update arrays with UV coordinates
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		
		# Add the surface to the new mesh
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		
		# Copy materials if they exist
		var material = mesh.surface_get_material(surface_idx)
		if material:
			new_mesh.surface_set_material(new_mesh.get_surface_count() - 1, material)
	
	return new_mesh

func create_improved_planar_uvs(vertices: PackedVector3Array, part_type: String = "leaf") -> PackedVector2Array:
	"""Create improved planar UV mapping for tree leaves and flat surfaces"""
	var uvs = PackedVector2Array()
	
	# Calculate bounding box
	var min_pos = vertices[0]
	var max_pos = vertices[0]
	for vertex in vertices:
		min_pos = min_pos.min(vertex)
		max_pos = max_pos.max(vertex)
	
	var size = max_pos - min_pos
	var center = (min_pos + max_pos) * 0.5
	
	GameLogger.info("TestPSXAssets: Creating improved planar UVs for " + part_type + " - Size: " + str(size))
	
	for vertex in vertices:
		# Use X and Z for planar mapping (Y is up)
		var u = (vertex.x - min_pos.x) / size.x if size.x > 0 else 0.5
		var v = (vertex.z - min_pos.z) / size.z if size.z > 0 else 0.5
		
		# Apply different scaling based on part type
		match part_type:
			"leaf":
				# Leaves need more texture detail
				u *= 3.0  # Tile 3 times horizontally
				v *= 3.0  # Tile 3 times vertically
			"root":
				# Roots need less tiling
				u *= 1.5
				v *= 1.5
			_:
				# Default scaling
				u *= 2.0
				v *= 2.0
		
		# Ensure UV coordinates are in valid range
		u = clamp(u, 0.0, 1.0)
		v = clamp(v, 0.0, 1.0)
		
		uvs.append(Vector2(u, v))
	
	return uvs

func create_improved_cylindrical_uvs(vertices: PackedVector3Array, part_type: String = "trunk") -> PackedVector2Array:
	"""Create improved cylindrical UV mapping for tree trunks and branches"""
	var uvs = PackedVector2Array()
	
	# Calculate bounding box
	var min_pos = vertices[0]
	var max_pos = vertices[0]
	for vertex in vertices:
		min_pos = min_pos.min(vertex)
		max_pos = max_pos.max(vertex)
	
	var size = max_pos - min_pos
	var center = (min_pos + max_pos) * 0.5
	
	GameLogger.info("TestPSXAssets: Creating improved cylindrical UVs for " + part_type + " - Size: " + str(size))
	
	for vertex in vertices:
		# Calculate cylindrical coordinates
		var relative_pos = vertex - center
		var angle = atan2(relative_pos.x, relative_pos.z)
		var u = (angle + PI) / (2.0 * PI)  # Map angle to U (0-1)
		
		# Map height to V coordinate
		var v = (vertex.y - min_pos.y) / size.y if size.y > 0 else 0.5
		
		# Apply different scaling based on part type
		match part_type:
			"trunk":
				# Trunks need more vertical detail
				u *= 2.0  # Tile 2 times around
				v *= 4.0  # Tile 4 times vertically
			"branch":
				# Branches need moderate tiling
				u *= 1.5
				v *= 2.0
			_:
				# Default scaling
				u *= 2.0
				v *= 2.0
		
		# Ensure UV coordinates are in valid range
		u = clamp(u, 0.0, 1.0)
		v = clamp(v, 0.0, 1.0)
		
		uvs.append(Vector2(u, v))
	
	return uvs

func create_improved_triplanar_uvs(vertices: PackedVector3Array, normals: PackedVector3Array) -> PackedVector2Array:
	"""Create improved triplanar UV mapping for complex tree geometry"""
	var uvs = PackedVector2Array()
	
	GameLogger.info("TestPSXAssets: Creating improved triplanar UVs for complex geometry")
	
	for i in range(vertices.size()):
		var vertex = vertices[i]
		var normal = normals[i] if i < normals.size() else Vector3.UP
		
		# Choose the dominant axis for mapping
		var abs_normal = normal.abs()
		var dominant_axis = 0
		if abs_normal.y > abs_normal.x and abs_normal.y > abs_normal.z:
			dominant_axis = 1  # Y dominant
		elif abs_normal.z > abs_normal.x:
			dominant_axis = 2  # Z dominant
		
		var u = 0.0
		var v = 0.0
		
		match dominant_axis:
			0:  # X dominant
				u = (vertex.z + 1.0) * 0.5
				v = (vertex.y + 1.0) * 0.5
			1:  # Y dominant
				u = (vertex.x + 1.0) * 0.5
				v = (vertex.z + 1.0) * 0.5
			2:  # Z dominant
				u = (vertex.x + 1.0) * 0.5
				v = (vertex.y + 1.0) * 0.5
		
		# Apply moderate tiling for complex parts
		u *= 2.0
		v *= 2.0
		
		# Ensure UV coordinates are in valid range
		u = clamp(u, 0.0, 1.0)
		v = clamp(v, 0.0, 1.0)
		
		uvs.append(Vector2(u, v))
	
	return uvs

func apply_texture_with_uv_fix(node: Node, texture: Texture2D):
	"""Apply texture with UV mapping fix"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			# Check if mesh has UV mapping
			var has_uv = mesh.surface_get_format(0) & Mesh.ARRAY_TEX_UV
			
			GameLogger.info("TestPSXAssets: Processing " + node.name + " - Has UV: " + str(has_uv))
			
			if not has_uv:
				GameLogger.warning("TestPSXAssets: " + node.name + " has no UV mapping, creating proper mapping...")
				
				# Use tree-specific mapping for tree assets
				var fixed_mesh
				if node.name.begins_with("tree_") or node.get_parent() and node.get_parent().name.begins_with("tree_"):
					GameLogger.info("TestPSXAssets: Using tree-specific UV mapping for " + node.name)
					fixed_mesh = create_tree_specific_uv_mapping(mesh)
				else:
					fixed_mesh = create_proper_uv_mapping(mesh, "auto")
				
				node.mesh = fixed_mesh
				mesh = fixed_mesh
				GameLogger.info("TestPSXAssets: Applied proper UV mapping to " + node.name)
			else:
				# For tree assets, preserve original UV mapping
				if node.name.begins_with("tree_") or node.get_parent() and node.get_parent().name.begins_with("tree_"):
					GameLogger.info("TestPSXAssets: " + node.name + " is a tree asset with original UV mapping, preserving it")
				else:
					GameLogger.info("TestPSXAssets: " + node.name + " already has UV mapping, checking quality...")
					# Check UV quality and potentially improve it for non-tree assets
					var arrays = mesh.surface_get_arrays(0)
					if arrays.size() > Mesh.ARRAY_TEX_UV:
						var uvs = arrays[Mesh.ARRAY_TEX_UV]
						var min_uv = uvs[0]
						var max_uv = uvs[0]
						for uv in uvs:
							min_uv = min_uv.min(uv)
							max_uv = max_uv.max(uv)
						GameLogger.info("TestPSXAssets: " + node.name + " UV range - Min: " + str(min_uv) + ", Max: " + str(max_uv))
			
			# Apply texture to all surfaces
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material and material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					if not std_material.albedo_texture:
						std_material.albedo_texture = texture
						GameLogger.info("TestPSXAssets: Applied texture with UV fix to " + node.name + " surface " + str(i))
	
	# Recursively apply to children
	for child in node.get_children():
		apply_texture_with_uv_fix(child, texture)

func test_uv_mapping_types():
	"""Test different UV mapping types on assets"""
	update_status("Testing different UV mapping types...")
	
	if not asset_container:
		update_status("No asset container found")
		return
	
	var mapping_types = ["cylindrical", "spherical", "planar", "triplanar"]
	var current_type = 0
	
	# Apply different mapping types to assets
	apply_uv_mapping_type_to_assets(asset_container, mapping_types[current_type])
	
	update_status("Applied " + mapping_types[current_type] + " UV mapping to assets")
	
	# Cycle through mapping types on next call
	current_type = (current_type + 1) % mapping_types.size()

func apply_uv_mapping_type_to_assets(node: Node, mapping_type: String):
	"""Apply specific UV mapping type to assets"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			# Create new mesh with specific UV mapping
			var new_mesh = create_proper_uv_mapping(mesh, mapping_type)
			node.mesh = new_mesh
			GameLogger.info("TestPSXAssets: Applied " + mapping_type + " UV mapping to " + node.name)
	
	# Recursively apply to children
	for child in node.get_children():
		apply_uv_mapping_type_to_assets(child, mapping_type)

func apply_smart_textures():
	"""Apply intelligent texture assignment to all assets"""
	update_status("Applying smart texture assignment...")
	
	if not asset_container:
		update_status("No asset container found")
		return
	
	var applied_count = 0
	var failed_count = 0
	
	# Apply smart textures to all assets
	apply_smart_textures_recursive(asset_container, applied_count, failed_count)
	
	var message = "Smart textures: " + str(applied_count) + " applied, " + str(failed_count) + " failed"
	update_status(message)

func apply_smart_textures_recursive(node: Node, applied_count: int, failed_count: int):
	"""Recursively apply smart textures to assets"""
	# Determine category and apply appropriate texture
	var category = determine_asset_category(node.name)
	
	if category != "":
		# Check if asset needs texture
		if not check_asset_has_textures(node):
			# Apply UV mapping first if needed
			if node is MeshInstance3D:
				var mesh = node.mesh
				if mesh and not (mesh.surface_get_format(0) & Mesh.ARRAY_TEX_UV):
					var new_mesh = create_proper_uv_mapping(mesh, "auto")
					node.mesh = new_mesh
					GameLogger.info("TestPSXAssets: Applied UV mapping to " + node.name)
			
			# Apply texture
			assign_texture_to_asset(node, category)
			applied_count += 1
			GameLogger.info("TestPSXAssets: Applied smart texture to " + node.name + " (category: " + category + ")")
		else:
			GameLogger.info("TestPSXAssets: " + node.name + " already has textures, skipping")
	
	# Recursively process children
	for child in node.get_children():
		apply_smart_textures_recursive(child, applied_count, failed_count)

func apply_tree_uv_fix():
	"""Apply tree-specific UV mapping to all tree assets"""
	update_status("Applying tree-specific UV mapping...")
	
	if not asset_container:
		update_status("No asset container found")
		return
	
	var fixed_count = 0
	
	# Apply tree-specific UV mapping to all tree assets
	apply_tree_uv_fix_recursive(asset_container, fixed_count)
	
	update_status("Applied tree UV fix to " + str(fixed_count) + " tree assets")

func apply_tree_uv_fix_recursive(node: Node, fixed_count: int):
	"""Recursively apply tree-specific UV mapping"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh and (node.name.begins_with("tree_") or node.get_parent() and node.get_parent().name.begins_with("tree_")):
			GameLogger.info("TestPSXAssets: Applying tree-specific UV mapping to " + node.name)
			var new_mesh = create_tree_specific_uv_mapping(mesh)
			node.mesh = new_mesh
			fixed_count += 1
			GameLogger.info("TestPSXAssets: Applied tree UV fix to " + node.name)
	
	# Recursively process children
	for child in node.get_children():
		apply_tree_uv_fix_recursive(child, fixed_count)

func _input(event):
	# Mouse camera rotation
	if event is InputEventMouseMotion and mouse_captured:
		if camera:
			camera.rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity)
	
	# Simple keyboard controls
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				toggle_asset_visibility()
			KEY_TAB:
				toggle_mouse_capture()
			KEY_ESCAPE:
				get_tree().quit()
	
	# Camera controls
	if camera:
		var camera_speed = 5.0
		var delta = get_process_delta_time()
		
		if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
			camera.translate(Vector3.LEFT * camera_speed * delta)
		if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
			camera.translate(Vector3.RIGHT * camera_speed * delta)
		if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
			camera.translate(Vector3.FORWARD * camera_speed * delta)
		if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
			camera.translate(Vector3.BACK * camera_speed * delta)

func debug_asset_loading():
	"""Debug function to test asset loading directly"""
	GameLogger.info("TestPSXAssets: Debug asset loading...")
	
	# Debug: Show what's actually in the PSX asset pack
	GameLogger.info("TestPSXAssets: PSX Asset Pack Debug Info:")
	GameLogger.info("  - Region: " + psx_asset_pack.region_name)
	GameLogger.info("  - Environment: " + psx_asset_pack.environment_type)
	GameLogger.info("  - Trees array size: " + str(psx_asset_pack.trees.size()))
	GameLogger.info("  - Vegetation array size: " + str(psx_asset_pack.vegetation.size()))
	GameLogger.info("  - Stones array size: " + str(psx_asset_pack.stones.size()))
	GameLogger.info("  - Debris array size: " + str(psx_asset_pack.debris.size()))
	GameLogger.info("  - Mushrooms array size: " + str(psx_asset_pack.mushrooms.size()))
	
	# Show actual content of arrays
	if psx_asset_pack.trees.size() > 0:
		GameLogger.info("  - Trees: " + str(psx_asset_pack.trees))
	if psx_asset_pack.vegetation.size() > 0:
		GameLogger.info("  - Vegetation: " + str(psx_asset_pack.vegetation))
	if psx_asset_pack.stones.size() > 0:
		GameLogger.info("  - Stones: " + str(psx_asset_pack.stones))
	if psx_asset_pack.debris.size() > 0:
		GameLogger.info("  - Debris: " + str(psx_asset_pack.debris))
	if psx_asset_pack.mushrooms.size() > 0:
		GameLogger.info("  - Mushrooms: " + str(psx_asset_pack.mushrooms))
	
	# Test loading a specific asset directly
	var test_path = "res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_1.glb"
	GameLogger.info("TestPSXAssets: Testing path: " + test_path)
	
	var scene = load(test_path)
	if scene:
		GameLogger.info("TestPSXAssets: Successfully loaded scene: " + str(scene))
		GameLogger.info("TestPSXAssets: Scene type: " + str(scene.get_class()))
		
		# Try to instantiate it
		var instance = scene.instantiate()
		if instance:
			GameLogger.info("TestPSXAssets: Successfully instantiated scene")
			instance.position = Vector3(0, 0, 5)
			add_child(instance)
		else:
			GameLogger.error("TestPSXAssets: Failed to instantiate scene")
	else:
		GameLogger.error("TestPSXAssets: Failed to load scene")

func toggle_asset_visibility():
	"""Toggle visibility of all placed assets"""
	if asset_container:
		assets_visible = !assets_visible
		asset_container.visible = assets_visible
		update_status("Assets visible: " + str(assets_visible))
	else:
		update_status("No asset container found")

func reload_assets():
	"""Reload and replace all assets"""
	update_status("Reloading assets...")
	
	# Remove old container
	if asset_container:
		asset_container.queue_free()
	
	# Create new container and place assets
	asset_container = Node3D.new()
	asset_container.name = "PSXAssetContainer"
	add_child(asset_container)
	
	# Re-run placement test
	test_psx_asset_placement()
	
	update_status("Assets reloaded successfully")

func toggle_mouse_capture():
	"""Toggle mouse capture for camera rotation"""
	mouse_captured = !mouse_captured
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		update_status("Mouse captured - move mouse to rotate camera")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		update_status("Mouse released - press TAB to capture again")

func check_texture_status():
	"""Check texture status of all visible assets"""
	GameLogger.info("TestPSXAssets: Checking texture status of visible assets...")
	
	if not asset_container:
		GameLogger.warning("TestPSXAssets: No asset container found")
		return
	
	var assets_without_textures = []
	var assets_with_textures = []
	
	check_node_textures(asset_container, assets_without_textures, assets_with_textures)
	
	GameLogger.info("TestPSXAssets: Texture Status Report:")
	GameLogger.info("  - Assets with textures: " + str(assets_with_textures.size()))
	GameLogger.info("  - Assets without textures: " + str(assets_without_textures.size()))
	
	if assets_without_textures.size() > 0:
		GameLogger.warning("TestPSXAssets: Assets without textures:")
		for asset in assets_without_textures:
			GameLogger.warning("    - " + asset)
	
	if assets_with_textures.size() > 0:
		GameLogger.info("TestPSXAssets: Assets with textures:")
		for asset in assets_with_textures:
			GameLogger.info("    - " + asset)

func check_node_textures(node: Node, without_textures: Array, with_textures: Array):
	"""Recursively check texture status of nodes"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			var has_texture = false
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material and material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					if std_material.albedo_texture:
						has_texture = true
						break
			
			var asset_name = node.name
			if node.get_parent():
				asset_name = node.get_parent().name + "/" + asset_name
			
			if has_texture:
				with_textures.append(asset_name)
			else:
				without_textures.append(asset_name)
	
	for child in node.get_children():
		check_node_textures(child, without_textures, with_textures)

func open_tree_test():
	"""Open the isolated tree test scene"""
	update_status("Opening isolated tree test...")
	GameLogger.info("TestPSXAssets: Opening isolated tree test scene")
	
	# Change to the tree test scene
	get_tree().change_scene_to_file("res://Tests/PSX_Assets/test_tree_isolated.tscn")

func open_format_comparison():
	"""Open the format comparison test scene"""
	update_status("Opening format comparison test...")
	GameLogger.info("TestPSXAssets: Opening format comparison test scene")
	
	# Change to the format comparison test scene
	get_tree().change_scene_to_file("res://Tests/PSX_Assets/test_format_comparison.tscn")
