class_name Indonesia3DMapControllerFinal
extends Node3D

## Final version of the 3D Indonesia Map with working drag & drop placeholders
## This version uses the new SOLID shader architecture for better maintainability

@export var shader_applier: Indonesia3DMapShaderApplier
@export var simple_terrain_applier: SimpleTerrainApplier
@export var artistic_enhancer: ArtisticColorEnhancer
@export var map_config: Indonesia3DMapConfig

# Camera control variables (loaded from config)
var camera_zoom_speed: float = 3.0  # Slower zoom for better control
var mouse_sensitivity: float = 0.3  # Lower sensitivity for smoother rotation
var camera_min_distance: float = 100.0  # Prevent getting too close with huge placeholders
var camera_max_distance: float = 400.0  # Much further max distance to see huge placeholders

# Map and UI references
@onready var map_camera: Camera3D = $MapCamera
@onready var ui_overlay: Control = $UIOverlay
@onready var back_to_menu_button: Button = $UIOverlay/BackToMenuButton
@onready var instructions_label: Label = $UIOverlay/InstructionsLabel
@onready var region_info_panel: Panel = $UIOverlay/RegionInfoPanel
@onready var poi_container: Node3D = $POIContainer
@onready var cooking_game_button: Button = $UIOverlay/RegionInfoPanel/VBoxContainer/CookingGameButton
@onready var explore_region_button: Button = $UIOverlay/RegionInfoPanel/VBoxContainer/ExploreRegionButton

# Map control variables
var target_camera_position: Vector3
var target_camera_rotation: Vector3
var is_camera_moving: bool = false
var camera_move_speed: float = 2.0
var is_mouse_captured: bool = false

# UI positioning
var last_clicked_placeholder_position: Vector3 = Vector3.ZERO

# Region data loaded from config
var region_data: Array[Dictionary] = []

# Current selection
var current_region: Dictionary = {}

# Region placeholders (read-only, no drag & drop)
var region_placeholders: Dictionary = {}

# Map scale and positioning
var map_scale: float = 0.6
var camera_initial_position: Vector3 = Vector3(20, 80, 120)  # Higher and further back to see all Indonesia

func _ready():
	GameLogger.info("🚀 Indonesia3DMapControllerFinal _ready() called!")
	_load_config()
	setup_map()
	setup_ui()
	setup_camera()
	connect_signals()
	# Setup visual enhancement systems first (before placeholders)
	_setup_simple_terrain_system()
	_setup_artistic_enhancement()
	# Temporarily disable other shader system until we fix all shader compilation issues
	# _setup_shader_system()
	
	# Create placeholders AFTER shader system to prevent scale reset
	_create_region_placeholders()
	GameLogger.info("🚀 Final Indonesia3D Map initialization completed!")

func _load_config():
	"""Load configuration with coordinates and settings"""
	GameLogger.info("📂 Loading Indonesia 3D Map configuration...")
	
	# Load or create config
	if not map_config:
		map_config = Indonesia3DMapConfig.load_from_file()
	
	# Load region data from config
	region_data = map_config.get_region_data()
	GameLogger.info("📍 Loaded " + str(region_data.size()) + " regions from config")
	
	# Load camera settings from config with enhanced defaults
	var settings = map_config.map_settings
	camera_zoom_speed = settings.get("camera_zoom_speed", 3.0)  # Smoother zoom
	mouse_sensitivity = settings.get("mouse_sensitivity", 0.3)  # Better control
	camera_min_distance = settings.get("camera_min_distance", 40.0)  # Prevent fogginess
	camera_max_distance = settings.get("camera_max_distance", 150.0)  # Better visibility
	camera_initial_position = settings.get("camera_initial_position", Vector3(0, 50, 30))
	
	GameLogger.info("⚙️ Camera settings loaded from config")

func setup_map():
	"""Setup the 3D Indonesia map using student's OBJ model"""
	create_basic_indonesia_map()
	create_sea_plane()
	GameLogger.info("✅ Indonesia map setup completed!")

func create_basic_indonesia_map():
	"""Indonesia map is set up directly in the scene file - shader system will handle materials"""
	GameLogger.info("🔧 Verifying Indonesia map setup...")
	
	var map_mesh = get_node("IndonesiaMap") as MeshInstance3D
	if map_mesh and map_mesh.mesh:
		GameLogger.info("✅ Indonesia model is already loaded from scene file")
		GameLogger.info("🔧 Mesh: " + str(map_mesh.mesh.resource_path))
		GameLogger.info("🔧 Transform: " + str(map_mesh.transform))
		GameLogger.info("🎨 Material enhancement will be handled by shader system")
	else:
		GameLogger.warning("⚠️ No mesh found on IndonesiaMap node")

func create_sea_plane():
	"""Create large sea plane covering all Indonesia archipelago"""
	GameLogger.info("🌊 Creating expanded sea plane to surround all islands...")
	
	# Get sea settings from config
	var sea_settings = map_config.sea_settings if map_config else {
		"sea_width": 400.0,
		"sea_depth": 200.0,
		"sea_position": Vector3(20, -0.3, 38),
		"sea_color": Color(0.1, 0.3, 0.7, 0.9)
	}
	
	var sea_width: float = sea_settings.get("sea_width", 400.0)
	var sea_depth: float = sea_settings.get("sea_depth", 200.0)
	
	# Add a massive water plane surrounding all islands
	var sea_plane := MeshInstance3D.new()
	sea_plane.name = "SeaPlane"
	var plane := PlaneMesh.new()
	plane.size = Vector2(sea_width, sea_depth)  # Massive sea covering entire archipelago
	sea_plane.mesh = plane
	sea_plane.position = sea_settings.get("sea_position", Vector3(20, -0.3, 38))
	
	# Basic material - shader system will apply ocean wave shader
	var basic_sea_mat := StandardMaterial3D.new()
	basic_sea_mat.albedo_color = sea_settings.get("sea_color", Color(0.1, 0.3, 0.7, 0.9))
	basic_sea_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sea_plane.material_override = basic_sea_mat
	
	# Add collision to sea plane so raycast can detect it
	var sea_body := StaticBody3D.new()
	sea_body.name = "SeaCollision"
	var sea_collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(sea_width, 0.1, sea_depth)  # Match sea plane size
	sea_collision.shape = box_shape
	sea_body.add_child(sea_collision)
	sea_plane.add_child(sea_body)
	
	add_child(sea_plane)
	GameLogger.info("🌊 Massive sea plane created: " + str(sea_width) + "x" + str(sea_depth) + " units, centered at: " + str(sea_plane.position))

func setup_ui():
	"""Setup UI elements"""
	instructions_label.text = "Controls: Mouse Wheel = Zoom | Right Mouse = Rotate Left/Right | Click placeholders to explore regions"
	region_info_panel.visible = false
	
	# Hide cooking game button if it exists
	if cooking_game_button:
		cooking_game_button.visible = false

func setup_camera():
	"""Setup camera position and lighting"""
	target_camera_position = camera_initial_position
	target_camera_rotation = Vector3(-35, 0, 0)  # Better angle to see all islands
	map_camera.position = target_camera_position
	map_camera.rotation_degrees = target_camera_rotation
	map_camera.fov = 50.0  # Wider field of view to see more
	
	setup_basic_lighting()
	GameLogger.info("🔧 Camera setup completed")

func setup_basic_lighting():
	"""Add enhanced lighting for better aesthetics"""
	# Main sun light
	var sun_light = DirectionalLight3D.new()
	sun_light.name = "SunLight"
	sun_light.position = Vector3(0, 100, 100)
	sun_light.rotation_degrees = Vector3(-35, -25, 0)  # Golden hour angle
	sun_light.light_energy = 1.2
	sun_light.light_color = Color(1.0, 0.95, 0.8)  # Warm sunlight
	sun_light.shadow_enabled = true
	add_child(sun_light)
	
	# Add environment for ambient lighting
	var world_env = WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	var environment = Environment.new()
	
	# Sky settings
	var sky = Sky.new()
	var physical_sky = PhysicalSkyMaterial.new()
	# Fix property names for Godot 4
	physical_sky.sun_disk_scale = 1.0
	physical_sky.ground_color = Color(0.1, 0.1, 0.1)
	sky.sky_material = physical_sky
	environment.sky = sky
	environment.background_mode = Environment.BG_SKY
	
	# Ambient lighting
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.3
	
	# Add minimal atmospheric fog for depth (reduced for better visibility)
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.9, 0.95, 1.0)
	environment.fog_sun_scatter = 0.05
	environment.fog_density = 0.003  # Much less fog for better visibility
	
	world_env.environment = environment
	add_child(world_env)
	
	GameLogger.info("✅ Enhanced lighting with sky and atmosphere added")

func connect_signals():
	"""Connect UI signals"""
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	# Remove cooking game button connection - cooking game only available in scenes
	# cooking_game_button.pressed.connect(_on_cooking_game_pressed)
	
	# Ensure explore region button exists and connect it
	if explore_region_button:
		if not explore_region_button.pressed.is_connected(_on_explore_region_pressed):
			explore_region_button.pressed.connect(_on_explore_region_pressed)
			GameLogger.info("✅ Connected explore region button signal")
		else:
			GameLogger.info("ℹ️ Explore region button signal already connected")
	else:
		GameLogger.warning("⚠️ Explore region button not found in UI!")

func _setup_shader_system():
	"""Initialize and configure the shader system"""
	GameLogger.info("🎨 Setting up shader system...")
	
	# Create shader applier if not assigned
	if not shader_applier:
		shader_applier = Indonesia3DMapShaderApplier.new()
		shader_applier.name = "ShaderApplier"
		add_child(shader_applier)
		GameLogger.info("✅ Created shader applier instance")
	
	# Apply shaders after a short delay to ensure all nodes are ready
	await get_tree().process_frame
	shader_applier.apply_all_shaders()
	
	GameLogger.info("✅ Shader system setup completed")

func _setup_simple_terrain_system():
	"""Initialize simple terrain shader system"""
	GameLogger.info("🎨 Setting up simple terrain shader system...")
	
	# Create simple terrain applier if not assigned
	if not simple_terrain_applier:
		simple_terrain_applier = SimpleTerrainApplier.new()
		simple_terrain_applier.name = "SimpleTerrainApplier"
		add_child(simple_terrain_applier)
		GameLogger.info("✅ Created simple terrain applier instance")
	
	# Apply simple terrain shader after a frame to ensure all nodes are ready
	await get_tree().process_frame
	simple_terrain_applier.apply_simple_terrain_shader()
	
	GameLogger.info("✅ Simple terrain system setup completed")

func _setup_artistic_enhancement():
	"""Initialize artistic color enhancement system"""
	GameLogger.info("🎨 Setting up artistic color enhancement...")
	
	# Create artistic enhancer if not assigned
	if not artistic_enhancer:
		artistic_enhancer = ArtisticColorEnhancer.new()
		artistic_enhancer.name = "ArtisticEnhancer"
		artistic_enhancer.current_palette = "tropical_vibrant"  # Best for Indonesia
		add_child(artistic_enhancer)
		GameLogger.info("✅ Created artistic enhancer instance")
	
	# Apply artistic enhancement after terrain system
	await get_tree().process_frame
	artistic_enhancer.apply_artistic_enhancement()
	
	GameLogger.info("✅ Artistic enhancement setup completed")

func _input(event):
	"""Handle input for camera control and interaction"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check for placeholder clicks to show region info
			var camera = get_viewport().get_camera_3d()
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 1000.0
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result and result.collider:
				var collider = result.collider
				if collider.get_parent().name.begins_with("Placeholder_"):
					# Show region information
					var placeholder_node = collider.get_parent()
					var region_id = placeholder_node.name.replace("Placeholder_", "")
					last_clicked_placeholder_position = placeholder_node.global_position
					GameLogger.info("🎯 Clicked placeholder: " + region_id + " at position: " + str(last_clicked_placeholder_position))
					
					# Debug: Print current region data for this ID
					for region in region_data:
						if region.id == region_id:
							GameLogger.info("📋 Region data found: " + str(region))
							break
					
					_show_region_info(region_id)
				else:
					# Hide region info panel when clicking elsewhere
					region_info_panel.visible = false
					current_region = {}
			else:
				# Hide region info panel when clicking empty space
				region_info_panel.visible = false
				current_region = {}
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(-camera_zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(camera_zoom_speed)
	
	elif event is InputEventMouseMotion:
		# Horizontal camera rotation with mouse movement (no capture needed)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# Right mouse button for horizontal rotation
			var mouse_delta = event.relative
			target_camera_rotation.y -= mouse_delta.x * mouse_sensitivity * 0.5
			# Keep camera level (no vertical rotation)
			# target_camera_rotation.x stays constant
		elif is_mouse_captured:
			# Fallback to old mouse capture system if M key is pressed
			var mouse_delta = event.relative
			target_camera_rotation.y -= mouse_delta.x * mouse_sensitivity
			target_camera_rotation.x -= mouse_delta.y * mouse_sensitivity
			target_camera_rotation.x = clamp(target_camera_rotation.x, -80, 80)
	
	elif event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_ESCAPE:
					_show_exit_confirmation()
				KEY_M:
					toggle_mouse_capture()
				KEY_KP_ADD, KEY_EQUAL:
					_zoom_camera(-camera_zoom_speed)
				KEY_KP_SUBTRACT, KEY_MINUS:
					_zoom_camera(camera_zoom_speed)

func _process(delta):
	"""Update camera position smoothly"""
	if is_camera_moving:
		map_camera.position = map_camera.position.lerp(target_camera_position, camera_move_speed * delta)
		map_camera.rotation_degrees = map_camera.rotation_degrees.lerp(target_camera_rotation, camera_move_speed * delta)
		
		if map_camera.position.distance_to(target_camera_position) < 1.0:
			is_camera_moving = false

func _zoom_camera(zoom_delta: float):
	"""Smooth zoom camera in/out with better control"""
	var distance = target_camera_position.length()
	var new_distance = clamp(distance + zoom_delta, camera_min_distance, camera_max_distance)
	
	# Only update if distance actually changed (prevents unnecessary updates)
	if abs(new_distance - distance) > 0.1:
		var direction = target_camera_position.normalized()
		target_camera_position = direction * new_distance
		# Smooth camera movement instead of instant
		is_camera_moving = true
		GameLogger.info("🔍 Zoom: " + str(new_distance) + " (min: " + str(camera_min_distance) + ", max: " + str(camera_max_distance) + ")")

func toggle_mouse_capture():
	"""Toggle mouse capture for camera control"""
	is_mouse_captured = !is_mouse_captured
	if is_mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		GameLogger.info("🖱️ Mouse captured for camera control")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		GameLogger.info("🖱️ Mouse released")

func _show_region_info(region_id: String):
	"""Display information about the selected region near the placeholder"""
	for region in region_data:
		if region.id == region_id:
			current_region = region
			
			# Position panel near the placeholder
			if region_id in region_placeholders:
				var placeholder_node: MeshInstance3D = region_placeholders[region_id]
				var screen_pos = map_camera.unproject_position(placeholder_node.global_position)
				
				# Position panel near placeholder but keep it on screen
				var panel_width = 300.0  # Panel width
				var panel_height = 150.0  # Panel height
				var screen_size = get_viewport().get_visible_rect().size
				
				# Offset to the right of placeholder, but clamp to screen bounds
				var target_x = clamp(screen_pos.x + 50, 0, screen_size.x - panel_width)
				var target_y = clamp(screen_pos.y - panel_height/2, 0, screen_size.y - panel_height)
				
				region_info_panel.position = Vector2(target_x, target_y)
				region_info_panel.size = Vector2(panel_width, panel_height)
			
			region_info_panel.visible = true
			
			# Update UI elements with region info (using correct node names from scene)
			if region_info_panel.has_node("VBoxContainer/RegionNameLabel"):
				region_info_panel.get_node("VBoxContainer/RegionNameLabel").text = region.name
			if region_info_panel.has_node("VBoxContainer/RegionDescriptionLabel"):
				region_info_panel.get_node("VBoxContainer/RegionDescriptionLabel").text = "Click 'Explore Region' to visit " + region.name + " and discover its cultural heritage."
			
			# Hide cooking game button
			if cooking_game_button:
				cooking_game_button.visible = false
			
			GameLogger.info("🎯 Selected region: " + region.name + " | Panel positioned at: " + str(region_info_panel.position))
			break

func _create_region_placeholders():
	"""Create draggable placeholders for each region"""
	GameLogger.info("🏗️ Creating region placeholders...")
	GameLogger.info("📊 Total regions to create: " + str(region_data.size()))
	
	for region in region_data:
		GameLogger.info("==================================================")
		GameLogger.info("📍 Creating placeholder for: " + region.name + " (" + region.id + ")")
		GameLogger.info("📍 Region position: " + str(region.position))
		GameLogger.info("📍 Region color: " + str(region.color))
		var node := MeshInstance3D.new()
		node.name = "Placeholder_" + region.id
		GameLogger.info("🔧 Created MeshInstance3D node: " + node.name)
		
		# Use student's POI placeholder model only
		var placeholder_mesh_path := "res://Assets/Students/levelLoc/object/loc3vertexcolor.obj"
		GameLogger.info("🔍 Checking POI mesh file: " + placeholder_mesh_path)
		GameLogger.info("🔍 File exists: " + str(ResourceLoader.exists(placeholder_mesh_path)))
		
		if ResourceLoader.exists(placeholder_mesh_path):
			var loaded_mesh = load(placeholder_mesh_path)
			GameLogger.info("🔍 Loaded mesh: " + str(loaded_mesh))
			if loaded_mesh:
				node.mesh = loaded_mesh
				GameLogger.info("🔧 Assigned mesh to node")
				
				# Check mesh bounds for debugging
				if loaded_mesh.get_aabb():
					var mesh_size = loaded_mesh.get_aabb().size
					GameLogger.info("📏 Original mesh size (AABB): " + str(mesh_size))
				
				var pm := StandardMaterial3D.new()
				# Use config color instead of vertex colors for region identification
				pm.albedo_color = region.color
				pm.roughness = 0.4
				pm.metallic = 0.1
				pm.emission_enabled = true
				pm.emission = region.color * 0.3  # Add glow effect
				node.material_override = pm
				GameLogger.info("🎨 Applied material with color: " + str(region.color))
				
				# Use reasonable 5x scale for good visibility - apply directly to transform
				var reasonable_scale = 5.0  # 5x larger - good balance
				GameLogger.info("🔍 Setting scale to: " + str(reasonable_scale))
				
				# Set scale directly in transform matrix to prevent reset
				var scale_transform = Transform3D()
				scale_transform = scale_transform.scaled(Vector3(reasonable_scale, reasonable_scale, reasonable_scale))
				node.transform = scale_transform
				
				GameLogger.info("✅ Applied scale transform directly: " + str(node.transform.basis.get_scale()))
				
			else:
				GameLogger.error("❌ Failed to load POI mesh for: " + region.id)
		else:
			GameLogger.error("❌ POI mesh file not found: " + placeholder_mesh_path)
			
		# Position placeholder using config settings (AFTER scaling to preserve scale)
		var height_offset = map_config.placeholder_settings.get("default_height_offset", 8.0)
		GameLogger.info("🔍 Height offset: " + str(height_offset))
		node.position = region.position + Vector3(0, height_offset, 0)
		node.rotation = Vector3.ZERO
		# DO NOT reset transform.basis - it contains our scaling!
		# node.transform.basis = Basis()  # This was resetting the scale!
		GameLogger.info("📍 Final node position: " + str(node.position))
		GameLogger.info("📍 Node rotation: " + str(node.rotation))
		GameLogger.info("📍 Node scale preserved: " + str(node.transform.basis.get_scale()))
		GameLogger.info("📍 Node visible: " + str(node.visible))
		
		# Material is already set above (either student mesh or cylinder fallback)
		
		# Add collision for clicking (box shape for POI model)
		var body := StaticBody3D.new()
		body.name = "PlaceholderCollision"
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = Vector3(15.0, 20.0, 15.0)  # Reasonable collision for 5x placeholders
		shape.shape = box_shape
		body.add_child(shape)
		node.add_child(body)
		
		# Add floating label (proportional to 5x placeholder)
		var label := Label3D.new()
		label.text = region.name
		label.position = Vector3(0, 30.0, 0)  # Proportional height above 5x placeholder
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 36  # Proportional font size for 5x placeholders
		label.visible = true  # Explicitly set visible
		node.add_child(label)
		GameLogger.info("🏷️ Created label: '" + label.text + "' | Font: " + str(label.font_size) + " | Pos: " + str(label.position))
		
		GameLogger.info("🔧 Adding node to scene...")
		add_child(node)
		GameLogger.info("🔧 Node added to scene")
		
		region_placeholders[region.id] = node
		GameLogger.info("🔧 Added to placeholders dictionary")
		
		# Final verification after adding to scene
		GameLogger.info("✅ FINAL PLACEHOLDER INFO:")
		GameLogger.info("   Name: " + node.name)
		GameLogger.info("   Position: " + str(node.position))
		GameLogger.info("   Global Position: " + str(node.global_position))
		GameLogger.info("   Scale: " + str(node.scale))
		GameLogger.info("   Visible: " + str(node.visible))
		GameLogger.info("   Has Mesh: " + str(node.mesh != null))
		GameLogger.info("   Has Material: " + str(node.material_override != null))
		GameLogger.info("   Children Count: " + str(node.get_child_count()))
		
		# Check label specifically
		for child in node.get_children():
			if child is Label3D:
				var lbl = child as Label3D
				GameLogger.info("   Label Found - Text: '" + lbl.text + "' | Visible: " + str(lbl.visible) + " | Position: " + str(lbl.position))
	
	# Placeholders are already positioned at config coordinates
	GameLogger.info("🏗️ Finished creating " + str(region_placeholders.size()) + " placeholders at configured positions")
	
	# Placeholders are now properly scaled using transform method

# Deferred scaling function removed - transform scaling method works correctly

func _show_exit_confirmation():
	"""Show unified exit confirmation dialog for 3D map"""
	GameLogger.info("🔧 Showing exit confirmation from 3D Indonesia map")
	UnifiedExitDialog.show_3d_map_exit_dialog()

func _on_back_to_menu_pressed():
	"""Return to main menu (called by Back button - direct navigation)"""
	GameLogger.info("Returning to main menu from 3D map via Back button")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

# Cooking game functionality removed - cooking games are available within individual scenes
# via NPC conversations and specific locations

func _on_explore_region_pressed():
	"""Explore the selected region"""
	GameLogger.info("🔘 EXPLORE REGION BUTTON PRESSED!")
	
	if current_region.is_empty():
		GameLogger.warning("No region selected for exploration")
		return
	
	GameLogger.info("Exploring region: " + current_region.name)
	GameLogger.info("Current region data: " + str(current_region))
	
	if "scene_path" in current_region and current_region.scene_path != "":
		var scene_path = current_region.scene_path
		GameLogger.info("🎯 Navigating to scene: " + scene_path)
		
		# Check if scene file exists before trying to load it
		if ResourceLoader.exists(scene_path):
			GameLogger.info("✅ Scene file exists, changing scene...")
			get_tree().change_scene_to_file(scene_path)
		else:
			GameLogger.error("❌ Scene file not found: " + scene_path)
			# Show error message to user
			if region_info_panel.has_node("VBoxContainer/RegionDescriptionLabel"):
				region_info_panel.get_node("VBoxContainer/RegionDescriptionLabel").text = "Scene not found: " + scene_path
	else:
		GameLogger.warning("No scene path defined for region: " + current_region.name)
		if region_info_panel.has_node("VBoxContainer/RegionDescriptionLabel"):
			region_info_panel.get_node("VBoxContainer/RegionDescriptionLabel").text = "No scene configured for this region yet."

# Public API for region data access
func get_region_data() -> Array[Dictionary]:
	"""Get current region data"""
	return region_data

func get_region_position(region_id: String) -> Vector3:
	"""Get position for specific region"""
	for region in region_data:
		if region.id == region_id:
			return region.position
	return Vector3.ZERO
