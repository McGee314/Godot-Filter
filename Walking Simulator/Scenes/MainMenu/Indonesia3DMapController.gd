class_name Indonesia3DMapController
extends Node3D

# 3D Indonesia Map for Region Selection
# Replaces SVG map in main menu for selecting Indonesia Barat, Tengah, Timur

# Map configuration
@export var map_scale: Vector3 = Vector3(0.6, 0.08, 0.6)  # Smaller and slightly flatter
@export var camera_initial_position: Vector3 = Vector3(0, 140, 140)
@export var camera_initial_rotation: Vector3 = Vector3(-45, 0, 0)

# Camera control
@export var camera_move_speed: float = 10.0
@export var camera_zoom_speed: float = 5.0
@export var camera_rotation_speed: float = 2.0
@export var zoom_min_distance: float = 6.0
@export var zoom_max_distance: float = 450.0
@export var zoom_keys_speed: float = 20.0

# POI (Point of Interest) system
@export var poi_marker_scene: PackedScene = preload("res://Scenes/MainMenu/POIMarker.tscn")
@export var cooking_game_scene: PackedScene

# Node references
@onready var map_mesh: MeshInstance3D = $IndonesiaMap
@onready var map_camera: Camera3D = $MapCamera
@onready var poi_container: Node3D = $POIContainer
@onready var ui_overlay: Control = $UIOverlay

# UI elements
@onready var region_info_panel: Panel = $UIOverlay/RegionInfoPanel
@onready var region_name_label: Label = $UIOverlay/RegionInfoPanel/VBoxContainer/RegionNameLabel
@onready var region_description_label: Label = $UIOverlay/RegionInfoPanel/VBoxContainer/RegionDescriptionLabel
@onready var cooking_game_button: Button = $UIOverlay/RegionInfoPanel/VBoxContainer/CookingGameButton
@onready var explore_region_button: Button = $UIOverlay/RegionInfoPanel/VBoxContainer/ExploreRegionButton
@onready var back_to_menu_button: Button = $UIOverlay/BackToMenuButton

# Region data structure for 3 main regions
var region_data: Array[Dictionary] = [
	{
		"id": "indonesia_barat",
		"name": "Indonesia Barat",
		"description": "Traditional Market Experience in Jakarta",
		"position": Vector3(-1.2, 0, -0.5),  # Jakarta area
		"scene_path": "res://Scenes/IndonesiaBarat/PasarScene.tscn",
		"color": Color.RED,
		"unlocked": true
	},
	{
		"id": "indonesia_tengah", 
		"name": "Indonesia Tengah",
		"description": "Mount Tambora Experience in NTB",
		"position": Vector3(-0.5, 0, 0.0),  # NTB area
		"scene_path": "res://Scenes/IndonesiaTengah/TamboraScene.tscn",
		"color": Color.YELLOW,
		"unlocked": true
	},
	{
		"id": "indonesia_timur",
		"name": "Indonesia Timur", 
		"description": "Papua Highlands Experience",
		"position": Vector3(2.0, 0, 0.5),  # Papua area
		"scene_path": "res://Scenes/IndonesiaTimur/PapuaScene.tscn",
		"color": Color.BLUE,
		"unlocked": true
	}
]

# Current state
var current_region: Dictionary = {}
var is_camera_moving: bool = false
var target_camera_position: Vector3
var target_camera_rotation: Vector3

# Input handling
var mouse_sensitivity: float = 0.002
var is_mouse_captured: bool = false
var last_clicked_map_position: Vector3 = Vector3.ZERO
@export var enable_marker_placement_mode: bool = false

# Runtime placeholders for regions
var region_placeholders: Dictionary = {}
var is_dragging_placeholder: bool = false
var dragging_region_id: String = ""
var dragging_original_pos: Vector3 = Vector3.ZERO
var pending_confirm_region_id: String = ""
var is_pending_confirm: bool = false
var debug_mode: bool = false

func _ready():
	GameLogger.info("🚀 Indonesia3DMapController _ready() called!")
	setup_map()
	# Temporarily disable POI circles to remove unwanted circles
	# setup_pois()
	setup_ui()
	setup_camera()
	connect_signals()
	_create_region_placeholders()
	_update_debug_label()
	GameLogger.info("🚀 Indonesia3DMapController initialization completed!")
	
	# Log all children to see what's in the scene
	GameLogger.info("🔍 Scene children:")
	for child in get_children():
		GameLogger.info("  - " + child.name + " (" + str(child.get_class()) + ")")
		if child.get_child_count() > 0:
			for grandchild in child.get_children():
				GameLogger.info("    - " + grandchild.name + " (" + str(grandchild.get_class()) + ")")

func setup_map():
	"""Setup the 3D Indonesia map using student's OBJ model"""
	# Load the actual Indonesia model from student assets
	create_basic_indonesia_map()

func create_basic_indonesia_map():
	"""Indonesia map is now set up directly in the scene file - just verify it's working"""
	GameLogger.info("🔧 Verifying Indonesia map setup...")
	
	# Check if the mesh is already set (from scene file)
	if map_mesh.mesh != null:
		GameLogger.info("✅ Indonesia model is already loaded from scene file")
		GameLogger.info("🔧 Mesh: " + str(map_mesh.mesh.resource_path))
		GameLogger.info("🔧 Transform: " + str(map_mesh.transform))
		GameLogger.info("🔧 Material: " + str(map_mesh.material_override))
	else:
		GameLogger.warning("⚠️ No mesh found on IndonesiaMap node - falling back to basic shapes")
		create_fallback_basic_map()
	
	# Add some basic terrain features using CSG shapes
	# Temporarily disabled to debug center cylinder issue
	# create_basic_terrain_features()
	
	# Add just the sea plane (without the confusing cylinders)
	create_sea_plane()
	
	GameLogger.info("✅ Indonesia map verification completed!")

func create_sea_plane():
	"""Create just the sea plane without terrain features"""
	GameLogger.info("🌊 Creating sea plane...")
	
	# Add a big water plane surrounding islands (temporary sea)
	var sea_plane := MeshInstance3D.new()
	sea_plane.name = "SeaPlane"
	var plane := PlaneMesh.new()
	plane.size = Vector2(100.0, 100.0)  # Much larger sea covering all Indonesia
	sea_plane.mesh = plane
	sea_plane.position = Vector3(0, -0.5, 0)
	
	# Create blue sea material
	var sea_mat := StandardMaterial3D.new()
	sea_mat.albedo_color = Color(0.2, 0.4, 0.8, 0.8)
	sea_mat.metallic = 0.0
	sea_mat.roughness = 0.1
	sea_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sea_plane.material_override = sea_mat
	
	# Add collision to sea plane so raycast can detect it
	var sea_body := StaticBody3D.new()
	sea_body.name = "SeaCollision"
	var sea_collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(100.0, 0.1, 100.0)  # Match larger sea size
	sea_collision.shape = box_shape
	sea_body.add_child(sea_collision)
	sea_plane.add_child(sea_body)
	
	add_child(sea_plane)
	
	GameLogger.info("🌊 Sea plane with collision created successfully")

func create_fallback_basic_map():
	"""Create a fallback basic map if the Indonesia model fails to load"""
	GameLogger.info("🔧 Creating fallback basic map...")
	
	# Create a simple plane for the base
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(20, 12)
	
	map_mesh.mesh = plane_mesh
	map_mesh.scale = map_scale
	map_mesh.position = Vector3.ZERO
	
	# Add a simple material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.2)  # Green for Indonesia
	material.roughness = 0.8
	map_mesh.material_override = material
	
	GameLogger.info("✅ Fallback basic map created")

func create_colored_material():
	"""Create a colored material for the Indonesia model - following student's approach"""
	GameLogger.info("🔧 Creating colored material for Indonesia...")
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.2)  # Green for Indonesia
	material.roughness = 0.8
	material.metallic = 0.0
	# Use material_override like student's approach
	map_mesh.material_override = material
	GameLogger.info("✅ Colored material applied using material_override")

func create_basic_terrain_features():
	"""Create basic terrain features using CSG shapes"""
	GameLogger.info("🔧 Creating terrain features...")
	
	# Create a container for terrain features
	var terrain_features = Node3D.new()
	terrain_features.name = "TerrainFeatures"
	add_child(terrain_features)
	
	GameLogger.info("🔧 Terrain features container created")
	
	# Add some basic mountains/hills using CSG shapes
	# Sumatra (West)
	var sumatra_hill = CSGCylinder3D.new()
	sumatra_hill.name = "SumatraHill"
	sumatra_hill.position = Vector3(-2.5, 0.5, -1.0)
	sumatra_hill.radius = 1.0
	sumatra_hill.height = 1.0
	var sumatra_material = StandardMaterial3D.new()
	sumatra_material.albedo_color = Color(0.4, 0.7, 0.4)
	terrain_features.add_child(sumatra_hill)
	
	# Java (Center)
	var java_hill = CSGCylinder3D.new()
	java_hill.name = "JavaHill"
	java_hill.position = Vector3(-0.5, 0.3, 0.0)
	java_hill.radius = 0.8
	java_hill.height = 0.6
	var java_material = StandardMaterial3D.new()
	java_material.albedo_color = Color(0.5, 0.8, 0.5)
	terrain_features.add_child(java_hill)
	
	# Papua (East)
	var papua_mountain = CSGCylinder3D.new()
	papua_mountain.name = "PapuaMountain"
	papua_mountain.position = Vector3(2.0, 0.8, 0.5)
	papua_mountain.radius = 1.2
	papua_mountain.height = 1.6
	var papua_material = StandardMaterial3D.new()
	papua_material.albedo_color = Color(0.3, 0.6, 0.3)
	terrain_features.add_child(papua_mountain)
	
	# Removed confusing center cylinder

	# Add a big water plane surrounding islands (temporary sea)
	var sea_plane := MeshInstance3D.new()
	sea_plane.name = "SeaPlane"
	var plane := PlaneMesh.new()
	# Expand sea to cover the whole archipelago
	plane.size = Vector2(400, 220)
	sea_plane.mesh = plane
	sea_plane.position = Vector3(0, -0.5, 0)
	var sea_mat := StandardMaterial3D.new()
	sea_mat.albedo_color = Color(0.1, 0.2, 0.5)
	sea_mat.roughness = 0.1
	sea_mat.metallic = 0.0
	sea_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sea_mat.albedo_color.a = 0.85
	sea_plane.material_override = sea_mat
	terrain_features.add_child(sea_plane)

func setup_pois():
	"""Setup region markers on the map"""
	for region in region_data:
		create_region_marker(region)

func create_region_marker(region: Dictionary):
	"""Create a region marker for a specific location"""
	# Check if poi_marker_scene is available; fallback to preload if not set by scene
	if poi_marker_scene == null:
		GameLogger.warning("⚠️ poi_marker_scene was null; preloading default POIMarker.tscn")
		poi_marker_scene = preload("res://Scenes/MainMenu/POIMarker.tscn")
	
	# Create region marker using the POIMarker scene
	var marker = poi_marker_scene.instantiate()
	marker.name = "Region_" + region.id
	marker.position = region.position + Vector3(0, 0.5, 0)
	poi_container.add_child(marker)
	
	# Set region data
	marker.set_poi_data(region)
	
	# Connect region signals
	marker.poi_clicked.connect(_on_region_clicked)
	marker.poi_hovered.connect(_on_region_hovered)
	marker.poi_unhovered.connect(_on_region_unhovered)

func _on_region_clicked(region_info: Dictionary):
	"""Handle region click event"""
	select_region(region_info.id)

func _on_region_hovered(region_info: Dictionary):
	"""Handle region hover event"""
	GameLogger.info("Hovering over: " + region_info.name)

func _on_region_unhovered(region_info: Dictionary):
	"""Handle region unhover event"""
	GameLogger.info("Stopped hovering over: " + region_info.name)

func setup_ui():
	"""Setup UI overlay for the 3D map"""
	# Initially hide the region info panel
	region_info_panel.visible = false
	
	# Set button texts
	cooking_game_button.text = "Play Cooking Game"
	explore_region_button.text = "Explore Region"
	back_to_menu_button.text = "Back to Main Menu"

func setup_camera():
	"""Setup the camera for 3D map navigation"""
	GameLogger.info("🔧 Setting up camera at position: " + str(camera_initial_position))
	map_camera.position = camera_initial_position
	map_camera.rotation_degrees = camera_initial_rotation
	target_camera_position = camera_initial_position
	target_camera_rotation = camera_initial_rotation
	
	# Add basic lighting to make the Indonesia model more visible
	setup_basic_lighting()
	
	GameLogger.info("🔧 Camera setup completed")

func setup_basic_lighting():
	"""Add basic lighting to make the Indonesia model visible"""
	GameLogger.info("🔧 Setting up basic lighting...")
	
	# Add a directional light
	var light = DirectionalLight3D.new()
	light.name = "MapLight"
	light.light_energy = 1.0
	light.light_color = Color.WHITE
	# Point the light by rotating it instead of assigning a non-existent property
	var dir := Vector3(-0.5, -1.0, -0.5).normalized()
	light.transform = Transform3D(Basis.looking_at(dir, Vector3.UP), light.transform.origin)
	light.shadow_enabled = true
	
	# Add to the scene
	add_child(light)
	GameLogger.info("✅ Basic lighting added")

func connect_signals():
	"""Connect UI signals"""
	cooking_game_button.pressed.connect(_on_cooking_game_pressed)
	explore_region_button.pressed.connect(_on_explore_region_pressed)
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)

func _input(event):
	"""Handle input for camera control and POI interaction"""
	# Log all mouse events for debugging
	if event is InputEventMouseButton:
		GameLogger.info("🖱️ MouseButton: " + str(event.button_index) + " | Pressed: " + str(event.pressed) + " | Position: " + str(event.position))
	elif event is InputEventMouseMotion:
		if is_dragging_placeholder:
			GameLogger.info("🖱️ MouseMotion during drag: " + str(event.position) + " | Relative: " + str(event.relative))
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check for POI interaction
			var camera = get_viewport().get_camera_3d()
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 1000.0
			
			GameLogger.info("🔍 Mouse click at: " + str(event.position) + " | Raycast from: " + str(from) + " to: " + str(to))
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result and result.collider:
				var collider = result.collider
				GameLogger.info("🎯 Hit collider: " + str(collider.name) + " | Parent: " + str(collider.get_parent().name) + " | Position: " + str(result.position))
				
				if collider.get_parent().name.begins_with("Region_"):
					var region_id = collider.get_parent().name.replace("Region_", "")
					GameLogger.info("🗺️ Selected region: " + region_id)
					select_region(region_id)
				elif collider.get_parent().name.begins_with("Placeholder_"):
					# Start dragging this placeholder (collision is child of placeholder)
					var placeholder_node = collider.get_parent()
					is_dragging_placeholder = true
					dragging_region_id = placeholder_node.name.replace("Placeholder_", "")
					dragging_original_pos = placeholder_node.position
					is_pending_confirm = false
					pending_confirm_region_id = ""
					GameLogger.info("🎯 START DRAGGING placeholder: " + dragging_region_id + " | Original pos: " + str(dragging_original_pos))
					GameLogger.info("🔧 Drag state: is_dragging=" + str(is_dragging_placeholder) + " | region=" + dragging_region_id + " | mouse_captured=" + str(is_mouse_captured))
				else:
					# Store clicked map position for placement mode
					last_clicked_map_position = result.position
					DisplayServer.clipboard_set(str(last_clicked_map_position))
					GameLogger.info("🗺️ Clicked map at: " + str(last_clicked_map_position) + " | Collider: " + str(collider.name) + " | Parent: " + str(collider.get_parent().name))
					if enable_marker_placement_mode:
						GameLogger.info("📌 Placement mode ON. Click position copied: " + str(last_clicked_map_position))
			else:
				GameLogger.info("❌ No collision detected from raycast")
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and is_dragging_placeholder:
			# Finish dragging; wait for confirmation (Enter to confirm, Esc to cancel)
			GameLogger.info("🔧 Mouse release during drag: was_dragging=" + str(is_dragging_placeholder) + " | region=" + dragging_region_id)
			is_dragging_placeholder = false
			is_pending_confirm = true
			pending_confirm_region_id = dragging_region_id
			GameLogger.info("📝 Release detected. Press Enter to confirm or Esc to cancel placement for: " + pending_confirm_region_id)
			
		elif (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN) and event.pressed and is_dragging_placeholder:
			# While dragging: mouse wheel moves up/down
			if dragging_region_id in region_placeholders:
				var node: MeshInstance3D = region_placeholders[dragging_region_id]
				var delta_y := 0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.1
				node.position.y = max(-1.0, node.position.y + delta_y)
				GameLogger.info("↕ Height: " + str(node.position.y))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(-camera_zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(camera_zoom_speed)
	
	# Drag placeholder along ground plane while holding mouse
	if event is InputEventMouseMotion and is_dragging_placeholder and dragging_region_id in region_placeholders:
		GameLogger.info("🖱️ Mouse motion during drag: " + str(event.position) + " | Dragging: " + dragging_region_id)
		var ground_pos = _raycast_to_ground(event.position)
		if ground_pos != null:
			var node: MeshInstance3D = region_placeholders[dragging_region_id]
			var old_pos = node.position
			# Ensure placeholder stays above the pulau (minimum Y = 10.0, Y is UP!)
			var new_y = max(10.0, ground_pos.y + 5.0)
			node.position = Vector3(ground_pos.x, new_y, ground_pos.z)
			GameLogger.info("📍 Moved placeholder from: " + str(old_pos) + " to: " + str(node.position) + " (min Y enforced)")
		else:
			GameLogger.warning("❌ Failed to raycast to ground during drag")
	elif event is InputEventMouseMotion and is_dragging_placeholder:
		GameLogger.warning("🚨 Mouse motion during drag but conditions failed: dragging=" + str(is_dragging_placeholder) + " | region_exists=" + str(dragging_region_id in region_placeholders) + " | region_id=" + dragging_region_id)
	
	elif event is InputEventMouseMotion and is_mouse_captured:
		# Camera rotation with mouse (only when not dragging)
		var mouse_delta = event.relative
		target_camera_rotation.y -= mouse_delta.x * mouse_sensitivity
		target_camera_rotation.x -= mouse_delta.y * mouse_sensitivity
		target_camera_rotation.x = clamp(target_camera_rotation.x, -80, 80)
	
	elif event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_ESCAPE:
					if is_pending_confirm and pending_confirm_region_id != "":
						# Cancel placement; revert position
						var node: MeshInstance3D = region_placeholders[pending_confirm_region_id]
						node.position = dragging_original_pos
						is_pending_confirm = false
						pending_confirm_region_id = ""
						GameLogger.info("❎ Placement cancelled")
					else:
						_on_back_to_menu_pressed()
				KEY_M:
					toggle_mouse_capture()
				KEY_P:
					enable_marker_placement_mode = !enable_marker_placement_mode
					GameLogger.info("🛠 Placement mode: " + ("ON" if enable_marker_placement_mode else "OFF"))
				KEY_I:
					_scatter_placeholders_wide()
				KEY_O:
					_snap_placeholders_to_regions()
				KEY_F3:
					debug_mode = !debug_mode
					_update_debug_label()
				KEY_ENTER, KEY_KP_ENTER:
					if is_pending_confirm and pending_confirm_region_id != "":
						var node: MeshInstance3D = region_placeholders[pending_confirm_region_id]
						_set_region_position(pending_confirm_region_id, node.position - Vector3(0, 0.3, 0))
						GameLogger.info("✅ Confirmed position for " + pending_confirm_region_id + ": " + str(node.position))
						is_pending_confirm = false
						pending_confirm_region_id = ""
				# Assign last clicked position to regions for fast placement
				KEY_1:
					_set_region_position("indonesia_barat", last_clicked_map_position)
				KEY_2:
					_set_region_position("indonesia_tengah", last_clicked_map_position)
				KEY_3:
					_set_region_position("indonesia_timur", last_clicked_map_position)
				KEY_KP_ADD, KEY_EQUAL:
					_zoom_camera(-zoom_keys_speed * 0.5)
				KEY_KP_SUBTRACT, KEY_MINUS:
					_zoom_camera(zoom_keys_speed * 0.5)

func _process(delta):
	"""Update camera movement and animations"""
	# Keyboard zoom hold
	if Input.is_action_pressed("ui_page_up"):
		_zoom_camera(-zoom_keys_speed * delta)
	elif Input.is_action_pressed("ui_page_down"):
		_zoom_camera(zoom_keys_speed * delta)
	# Smooth camera movement
	if is_camera_moving:
		map_camera.position = map_camera.position.lerp(target_camera_position, delta * 2.0)
		map_camera.rotation = map_camera.rotation.lerp(target_camera_rotation, delta * 2.0)
		
		# Check if camera has reached target
		if map_camera.position.distance_to(target_camera_position) < 0.1:
			is_camera_moving = false

func _zoom_camera(delta_amount: float):
	"""Zoom camera in/out with clamped distance from origin"""
	if not map_camera:
		return
	var forward := map_camera.global_transform.basis.z.normalized()
	var new_pos := map_camera.global_position + forward * delta_amount
	var distance := new_pos.length()
	if distance < zoom_min_distance:
		new_pos = new_pos.normalized() * zoom_min_distance
	elif distance > zoom_max_distance:
		new_pos = new_pos.normalized() * zoom_max_distance
	map_camera.global_position = new_pos


func select_region(region_id: String):
	"""Select a region and show information"""
	# Find region data
	var region = null
	for r in region_data:
		if r.id == region_id:
			region = r
			break
	
	if not region:
		GameLogger.error("Region not found: " + region_id)
		return
	
	current_region = region
	
	# Update UI
	region_name_label.text = region.name
	region_description_label.text = region.description
	
	# Show region info panel
	region_info_panel.visible = true
	
	# Move camera to region
	move_camera_to_region(region)
	
	GameLogger.info("Selected Region: " + region.name)

func move_camera_to_region(region: Dictionary):
	"""Move camera to focus on selected region"""
	var region_position = region.position
	var camera_offset = Vector3(0, 3, 2)
	target_camera_position = region_position + camera_offset
	target_camera_rotation = Vector3(-20, 0, 0)
	is_camera_moving = true

func _set_region_position(region_id: String, pos: Vector3):
	for i in region_data.size():
		if region_data[i].id == region_id:
			region_data[i].position = pos
			GameLogger.info("✅ Updated position for " + region_id + ": " + str(pos))
			_update_region_placeholder(region_data[i])
			_update_debug_label()
			return
	GameLogger.warning("Region id not found: " + region_id)

func _create_temp_marker(_pos: Vector3):
	# Disabled by default; kept for debugging if needed
	pass

func _create_region_placeholders():
	GameLogger.info("🏗️ Creating region placeholders...")
	# Create simple cylinder placeholders for each region
	for region in region_data:
		GameLogger.info("📍 Creating placeholder for: " + region.name + " (" + region.id + ")")
		var node := MeshInstance3D.new()
		node.name = "Placeholder_" + region.id
		# Try to use student's placeholder mesh; fallback to cylinder
		var placeholder_mesh_path := "res://Assets/Students/levelLoc/object/loc3vertexcolor.obj"
		if ResourceLoader.exists(placeholder_mesh_path):
			var loaded_mesh = load(placeholder_mesh_path)
			if loaded_mesh:
				node.mesh = loaded_mesh
				var pm := StandardMaterial3D.new()
				pm.vertex_color_use_as_albedo = true
				pm.roughness = 0.4
				node.material_override = pm
				node.scale = Vector3(4.0, 4.0, 4.0)  # Make placeholders even bigger
				GameLogger.info("✅ Using student mesh for: " + region.id)
			else:
				var cyl := CylinderMesh.new()
				cyl.top_radius = 2.5  # Even bigger cylinder
				cyl.bottom_radius = 2.5
				cyl.height = 3.0
				node.mesh = cyl
				GameLogger.info("⚠️ Fallback to cylinder for: " + region.id)
		else:
			var cyl := CylinderMesh.new()
			cyl.top_radius = 2.5  # Even bigger cylinder
			cyl.bottom_radius = 2.5
			cyl.height = 3.0
			node.mesh = cyl
			GameLogger.info("⚠️ Student mesh not found, using cylinder for: " + region.id)
		node.position = region.position + Vector3(0, 10.0, 0)  # Start 2x higher above pulau (Y is UP!)
		node.rotation = Vector3.ZERO  # Ensure placeholders are upright (not tilted)
		node.transform.basis = Basis()  # Reset any inherited rotation to make perfectly upright
		if node.material_override == null:
			var m := StandardMaterial3D.new()
			m.albedo_color = region.color
			node.material_override = m
		add_child(node)
		# Add wide collision for easy click
		var body := StaticBody3D.new()
		body.name = "PlaceholderCollision"
		var shape := CollisionShape3D.new()
		var cyl_shape := CylinderShape3D.new()
		cyl_shape.radius = 1.2
		cyl_shape.height = 1.2
		shape.shape = cyl_shape
		body.add_child(shape)
		node.add_child(body)
		GameLogger.info("🔘 Added collision body to: " + node.name)
		# Add floating label for clarity
		var label := Label3D.new()
		label.text = region.name
		label.position = Vector3(0, 0.6, 0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		node.add_child(label)
		region_placeholders[region.id] = node
		GameLogger.info("✅ Created placeholder: " + node.name + " at: " + str(node.position))
	# Start with wide scatter so they don't overlap
	_scatter_placeholders_wide()
	_update_debug_label()
	GameLogger.info("🏗️ Finished creating " + str(region_placeholders.size()) + " placeholders")

func _update_region_placeholder(region: Dictionary):
	if region.id in region_placeholders:
		var node: MeshInstance3D = region_placeholders[region.id]
		node.position = region.position + Vector3(0, 10.0, 0)  # Keep 2x higher above pulau (Y is UP!)
		node.rotation = Vector3.ZERO  # Keep upright
		node.transform.basis = Basis()  # Reset rotation to make perfectly upright
	_update_debug_label()

func _raycast_to_ground(screen_pos: Vector2) -> Variant:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		GameLogger.warning("❌ No camera found for ground raycast")
		return null
	
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 1000.0
	
	# Try physics raycast first (to hit sea plane or other objects)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	# Exclude the placeholder we're dragging from collision
	if is_dragging_placeholder and dragging_region_id in region_placeholders:
		var dragging_node: MeshInstance3D = region_placeholders[dragging_region_id]
		var collision_body = dragging_node.get_node("PlaceholderCollision")
		if collision_body:
			query.exclude = [collision_body.get_rid()]
			GameLogger.info("🚫 Excluding dragged placeholder from raycast: " + dragging_region_id)
	
	var result = space_state.intersect_ray(query)
	
	if result and result.position:
		GameLogger.info("🎯 Ground raycast hit: " + str(result.position) + " on " + str(result.collider.name if result.collider else "unknown"))
		return result.position
	else:
		# Fallback to plane intersection at y=0
		var dir = camera.project_ray_normal(screen_pos)
		var plane = Plane(Vector3.UP, 0.0)
		var hit = plane.intersects_ray(from, dir)
		if hit:
			GameLogger.info("🎯 Ground raycast fallback to plane: " + str(hit))
		else:
			GameLogger.warning("❌ Ground raycast failed completely")
		return hit

func _scatter_placeholders_wide():
	# Place far apart for easy grabbing
	if region_placeholders.is_empty():
		return
	var ids := ["indonesia_barat", "indonesia_tengah", "indonesia_timur"]
	var offsets := {
		"indonesia_barat": Vector3(-12, 12.0, -8),
		"indonesia_tengah": Vector3(0, 12.0, 12),
		"indonesia_timur": Vector3(12, 12.0, -12)
	}
	for id in ids:
		if id in region_placeholders:
			var node: MeshInstance3D = region_placeholders[id]
			node.position = offsets[id]
			GameLogger.info("📍 Scatter " + id + " -> " + str(node.position))
	_update_debug_label()

func _snap_placeholders_to_regions():
	for region in region_data:
		_update_region_placeholder(region)
	GameLogger.info("📍 Snap placeholders to region positions")

func _ensure_debug_label() -> Label:
	if not ui_overlay.has_node("DebugLabel"):
		var lbl := Label.new()
		lbl.name = "DebugLabel"
		lbl.add_theme_color_override("font_color", Color(1,1,0))
		lbl.position = Vector2(20, 20)
		ui_overlay.add_child(lbl)
	return ui_overlay.get_node("DebugLabel") as Label

func _update_debug_label():
	var lbl := _ensure_debug_label()
	if not debug_mode:
		lbl.visible = false
		return
	lbl.visible = true
	var text := "Placeholders (press I=Scatter, O=Snap, Enter=Confirm, Esc=Cancel)\n"
	for region in region_data:
		var placeholder_node = region_placeholders.get(region.id, null)
		if placeholder_node:
			var n: MeshInstance3D = placeholder_node as MeshInstance3D
			text += region.name + ": " + str(n.position) + "\n"
	lbl.text = text

func _on_cooking_game_pressed():
	"""Start the cooking game for the selected region"""
	if current_region.is_empty():
		GameLogger.warning("No region selected for cooking game")
		return
	
	GameLogger.info("Starting cooking game for: " + current_region.name)
	
	# For now, just show a message that cooking games are integrated in the scenes
	show_error_message("Cooking games are integrated as mini-games within the region scenes. Please explore the region first!")

func _on_explore_region_pressed():
	"""Explore the selected region"""
	if current_region.is_empty():
		GameLogger.warning("No region selected for exploration")
		return
	
	GameLogger.info("Exploring region: " + current_region.name)
	
	# Load the region scene
	var region_scene_path = current_region.scene_path
	if ResourceLoader.exists(region_scene_path):
		# Set global region data
		Global.current_region = current_region.name
		Global.start_region_session(current_region.name)
		get_tree().change_scene_to_file(region_scene_path)
	else:
		GameLogger.error("Region scene not found: " + region_scene_path)
		show_error_message("Region exploration not available yet!")

func _on_back_to_menu_pressed():
	"""Return to main menu"""
	GameLogger.info("Returning to main menu from 3D map")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func toggle_mouse_capture():
	"""Toggle mouse capture for camera control"""
	is_mouse_captured = !is_mouse_captured
	if is_mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func show_error_message(message: String):
	"""Show error message to user"""
	var popup = AcceptDialog.new()
	popup.dialog_text = message
	popup.title = "Information"
	add_child(popup)
	popup.popup_centered()
	
	# Auto-remove after 3 seconds
	await get_tree().create_timer(3.0).timeout
	popup.queue_free()

# Public methods for external access
func get_region_data(region_id: String) -> Dictionary:
	"""Get region data by ID"""
	for region in region_data:
		if region.id == region_id:
			return region
	return {}

func unlock_region(region_id: String):
	"""Unlock a region"""
	for region in region_data:
		if region.id == region_id:
			region.unlocked = true
			GameLogger.info("Unlocked region: " + region.name)
			break

func is_region_unlocked(region_id: String) -> bool:
	"""Check if region is unlocked"""
	for region in region_data:
		if region.id == region_id:
			return region.unlocked
	return false
