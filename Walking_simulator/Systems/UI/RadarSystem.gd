class_name RadarSystem
extends BaseUIComponent

func _init():
	print("RadarSystem: _init() called")

# Radar configuration
@export var radar_size: float = 200.0
@export var radar_scale: float = 0.1  # How much of the world to show
@export var player_icon_color: Color = Color.WHITE
@export var poi_icon_color: Color = Color.YELLOW
@export var npc_icon_color: Color = Color.BLUE
@export var artifact_icon_color: Color = Color.GREEN
@export var path_color: Color = Color.GRAY

# Radar elements
@onready var radar_circle: ColorRect = $RadarCircle
@onready var north_indicator: Label = $NorthIndicator
@onready var player_icon: Control = $PlayerIcon
@onready var poi_container: Control = $POIContainer
@onready var path_container: Control = $PathContainer
@onready var radar_border: ColorRect = $RadarBorder

# World references
var player: CharacterBody3D
var current_scene: Node3D
var poi_list: Array[Dictionary] = []
var npc_list: Array[CulturalNPC] = []
var artifact_list: Array[CulturalItem] = []
var path_points: Array[Vector3] = []

# Radar state
var is_radar_visible: bool = true
var radar_center: Vector2
var player_position: Vector2
var player_rotation: float

func _ready():
	GameLogger.info("RadarSystem: ===== RADAR SYSTEM READY CALLED =====")
	GameLogger.info("RadarSystem: Node name: " + name)
	GameLogger.info("RadarSystem: Node path: " + get_path())
	GameLogger.info("RadarSystem: Parent: " + str(get_parent().name if get_parent() else "None"))
	
	# Ensure this node can receive input
	process_mode = Node.PROCESS_MODE_INHERIT
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	setup_radar()
	find_world_objects()
	setup_scene_paths()
	update_radar_display()
	GameLogger.info("RadarSystem: Radar system initialized successfully")
	
	# Show brief instruction about radar
	show_radar_instruction()
	
	# Temporary test: Show radar after 5 seconds to verify it works
	await get_tree().create_timer(5.0).timeout
	GameLogger.info("RadarSystem: Testing radar visibility")
	show_radar()
	await get_tree().create_timer(3.0).timeout
	hide_radar()
	GameLogger.info("RadarSystem: Test complete - radar should be hidden again")

func show_radar_instruction():
	# Create a temporary instruction label
	var instruction = Label.new()
	instruction.text = "Press R to toggle radar"
	instruction.add_theme_font_size_override("font_size", 18)
	instruction.add_theme_color_override("font_color", Color.WHITE)
	instruction.position = Vector2(20, 20)
	instruction.z_index = 100
	
	# Add to the radar system
	add_child(instruction)
	
	# Remove after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(instruction):
		instruction.queue_free()

func setup_radar():
	# Set radar size and position
	radar_circle.custom_minimum_size = Vector2(radar_size, radar_size)
	radar_circle.size = Vector2(radar_size, radar_size)
	radar_center = Vector2(radar_size / 2, radar_size / 2)
	
	# Ensure the radar control itself has the right size
	custom_minimum_size = Vector2(radar_size, radar_size)
	size = Vector2(radar_size, radar_size)
	
	# Style the radar circle with border
	radar_circle.color = Color(0, 0, 0, 0.8)
	
	# Setup radar border (GTA-style dashed border)
	setup_radar_border()
	
	# Setup north indicator
	north_indicator.text = "N"
	north_indicator.add_theme_color_override("font_color", Color.WHITE)
	north_indicator.add_theme_font_size_override("font_size", 16)
	north_indicator.position = Vector2(radar_center.x - 8, 10)
	
	# Setup player icon (teardrop shape)
	setup_player_icon()
	
	# Initially hide radar (toggle with R key)
	visible = false
	is_radar_visible = false
	
	GameLogger.info("RadarSystem: Radar setup complete - hidden by default, press R to toggle")
	GameLogger.info("RadarSystem: Radar position: " + str(position) + ", size: " + str(radar_size))

func setup_radar_border():
	# Create a dashed border effect
	radar_border.custom_minimum_size = Vector2(radar_size + 4, radar_size + 4)
	radar_border.size = Vector2(radar_size + 4, radar_size + 4)
	radar_border.position = Vector2(-2, -2)
	radar_border.color = Color(1, 0.5, 1, 0.8)  # Pink/purple border like GTA

func setup_player_icon():
	# Create a teardrop-shaped player icon
	player_icon.custom_minimum_size = Vector2(12, 12)
	player_icon.size = Vector2(12, 12)
	player_icon.position = radar_center - Vector2(6, 6)
	
	# Add a visual indicator for player direction
	var direction_indicator = ColorRect.new()
	direction_indicator.name = "DirectionIndicator"
	direction_indicator.custom_minimum_size = Vector2(2, 8)
	direction_indicator.size = Vector2(2, 8)
	direction_indicator.color = Color.WHITE
	direction_indicator.position = Vector2(5, 2)
	player_icon.add_child(direction_indicator)

func find_world_objects():
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if not player:
		GameLogger.warning("RadarSystem: Player not found")
		return
	else:
		GameLogger.info("RadarSystem: Player found at " + str(player.global_position))
	
	# Find current scene
	current_scene = get_tree().current_scene
	GameLogger.info("RadarSystem: Current scene: " + current_scene.name)
	
	# Find NPCs
	find_npcs()
	
	# Find artifacts
	find_artifacts()
	
	# Find POIs based on scene
	setup_scene_pois()
	
	GameLogger.info("RadarSystem: World objects found - NPCs: " + str(npc_list.size()) + ", Artifacts: " + str(artifact_list.size()) + ", POIs: " + str(poi_list.size()))

func find_npcs():
	npc_list.clear()
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if npc is CulturalNPC:
			npc_list.append(npc)
	GameLogger.debug("RadarSystem: Found " + str(npc_list.size()) + " NPCs")

func find_artifacts():
	artifact_list.clear()
	var artifacts = get_tree().get_nodes_in_group("artifact")
	for artifact in artifacts:
		if artifact is CulturalItem:
			artifact_list.append(artifact)
	GameLogger.debug("RadarSystem: Found " + str(artifact_list.size()) + " artifacts")

func setup_scene_paths():
	path_points.clear()
	
	# Get current scene name
	var scene_name = get_tree().current_scene.name
	
	match scene_name:
		"TamboraScene":
			setup_tambora_paths()
		"PapuaScene":
			setup_papua_paths()
		"PasarScene":
			setup_pasar_paths()
		_:
			GameLogger.warning("RadarSystem: Unknown scene: " + scene_name)

func setup_tambora_paths():
	# Tambora outdoor paths
	path_points = [
		Vector3(-50, 0, -50),  # Start point
		Vector3(-30, 0, -30),  # Path to volcano
		Vector3(0, 0, 0),      # Center area
		Vector3(30, 0, 30),    # Path to summit
		Vector3(50, 0, 50),    # Volcano summit
		Vector3(20, 0, -40),   # Geological point
		Vector3(-30, 0, 20),   # Historical site
	]

func setup_papua_paths():
	# Papua outdoor paths
	path_points = [
		Vector3(-40, 0, -40),  # Start point
		Vector3(-20, 0, -20),  # Path to ancient site
		Vector3(0, 0, 0),      # Center area
		Vector3(20, 0, 20),    # Path to cultural center
		Vector3(40, 0, 30),    # Ancient site
		Vector3(-25, 0, 15),   # Cultural center
		Vector3(10, 0, -35),   # Artifact location
	]

func setup_pasar_paths():
	# Pasar market paths
	path_points = [
		Vector3(-30, 0, -30),  # Market entrance
		Vector3(-15, 0, -15),  # Main market area
		Vector3(0, 0, 0),      # Center plaza
		Vector3(15, 0, 15),    # Food area
		Vector3(25, 0, 20),    # Food stalls
		Vector3(-20, 0, 15),   # Craft market
		Vector3(0, 0, -25),    # Cultural display
	]

func setup_scene_pois():
	poi_list.clear()
	
	# Get current scene name
	var scene_name = get_tree().current_scene.name
	
	match scene_name:
		"TamboraScene":
			setup_tambora_pois()
		"PapuaScene":
			setup_papua_pois()
		"PasarScene":
			setup_pasar_pois()
		_:
			GameLogger.warning("RadarSystem: Unknown scene: " + scene_name)

func setup_tambora_pois():
	# Tambora-specific points of interest
	poi_list = [
		{
			"name": "Volcano Summit",
			"position": Vector3(50, 0, 50),
			"icon": "volcano",
			"description": "Mount Tambora summit"
		},
		{
			"name": "Historical Site",
			"position": Vector3(-30, 0, 20),
			"icon": "history",
			"description": "1815 eruption site"
		},
		{
			"name": "Geological Point",
			"position": Vector3(20, 0, -40),
			"icon": "geology",
			"description": "Rock formations"
		}
	]

func setup_papua_pois():
	# Papua-specific points of interest
	poi_list = [
		{
			"name": "Ancient Site",
			"position": Vector3(40, 0, 30),
			"icon": "ancient",
			"description": "Megalithic site"
		},
		{
			"name": "Cultural Center",
			"position": Vector3(-25, 0, 15),
			"icon": "culture",
			"description": "Traditional village"
		},
		{
			"name": "Artifact Location",
			"position": Vector3(10, 0, -35),
			"icon": "artifact",
			"description": "Ancient artifacts"
		}
	]

func setup_pasar_pois():
	# Pasar-specific points of interest
	poi_list = [
		{
			"name": "Food Stalls",
			"position": Vector3(25, 0, 20),
			"icon": "food",
			"description": "Traditional food"
		},
		{
			"name": "Craft Market",
			"position": Vector3(-20, 0, 15),
			"icon": "craft",
			"description": "Local crafts"
		},
		{
			"name": "Cultural Display",
			"position": Vector3(0, 0, -25),
			"icon": "display",
			"description": "Cultural exhibition"
		}
	]

func _process(_delta):
	if not is_radar_visible or not player:
		return
	
	update_player_position()
	update_poi_positions()
	update_npc_positions()
	update_artifact_positions()
	update_path_display()

func update_player_position():
	if not player:
		return
	
	# Update player position on radar
	var world_pos = player.global_position
	player_position = world_to_radar_position(world_pos)
	player_icon.position = player_position - Vector2(6, 6)
	
	# Update player rotation (facing direction)
	player_rotation = player.rotation.y
	player_icon.rotation = player_rotation

func world_to_radar_position(world_pos: Vector3) -> Vector2:
	# Convert world position to radar position
	var radar_pos = Vector2(world_pos.x, world_pos.z) * radar_scale
	return radar_center + radar_pos

func update_path_display():
	# Clear existing path lines
	for child in path_container.get_children():
		child.queue_free()
	
	# Draw paths between points
	for i in range(path_points.size() - 1):
		var start_pos = world_to_radar_position(path_points[i])
		var end_pos = world_to_radar_position(path_points[i + 1])
		draw_path_line(start_pos, end_pos)

func draw_path_line(start_pos: Vector2, end_pos: Vector2):
	var line = Line2D.new()
	line.name = "PathLine"
	line.points = [start_pos, end_pos]
	line.width = 2.0
	line.default_color = path_color
	line.antialiased = true
	path_container.add_child(line)

func update_poi_positions():
	# Clear existing POI icons
	for child in poi_container.get_children():
		if child.name.begins_with("poi_"):
			child.queue_free()
	
	# Create POI icons
	for poi in poi_list:
		var poi_icon = create_poi_icon(poi)
		var radar_pos = world_to_radar_position(poi.position)
		poi_icon.position = radar_pos - Vector2(8, 8)
		poi_container.add_child(poi_icon)

func update_npc_positions():
	# Clear existing NPC icons
	for child in poi_container.get_children():
		if child.name.begins_with("npc_"):
			child.queue_free()
	
	# Create NPC icons
	for npc in npc_list:
		if npc and is_instance_valid(npc):
			var npc_icon = create_npc_icon(npc)
			var radar_pos = world_to_radar_position(npc.global_position)
			npc_icon.position = radar_pos - Vector2(8, 8)
			poi_container.add_child(npc_icon)

func update_artifact_positions():
	# Clear existing artifact icons
	for child in poi_container.get_children():
		if child.name.begins_with("artifact_"):
			child.queue_free()
	
	# Create artifact icons
	for artifact in artifact_list:
		if artifact and is_instance_valid(artifact) and not artifact.is_collected:
			var artifact_icon = create_artifact_icon(artifact)
			var radar_pos = world_to_radar_position(artifact.global_position)
			artifact_icon.position = radar_pos - Vector2(8, 8)
			poi_container.add_child(artifact_icon)

func create_poi_icon(poi: Dictionary) -> Control:
	var icon = ColorRect.new()
	icon.name = "poi_" + poi.name
	icon.custom_minimum_size = Vector2(16, 16)
	icon.size = Vector2(16, 16)
	icon.color = poi_icon_color
	
	# Add tooltip
	icon.tooltip_text = poi.description
	
	return icon

func create_npc_icon(npc: CulturalNPC) -> Control:
	var icon = ColorRect.new()
	icon.name = "npc_" + npc.npc_name
	icon.custom_minimum_size = Vector2(12, 12)
	icon.size = Vector2(12, 12)
	icon.color = npc_icon_color
	
	# Add tooltip
	icon.tooltip_text = "Talk to " + npc.npc_name
	
	return icon

func create_artifact_icon(artifact: CulturalItem) -> Control:
	var icon = ColorRect.new()
	icon.name = "artifact_" + artifact.item_name
	icon.custom_minimum_size = Vector2(10, 10)
	icon.size = Vector2(10, 10)
	icon.color = artifact_icon_color
	
	# Add tooltip
	icon.tooltip_text = "Collect " + artifact.item_name
	
	return icon

func _on_component_unhandled_input(event):
	# Toggle radar with R key
	if event.is_action_pressed("toggle_radar"):
		GameLogger.info("RadarSystem: R key pressed - toggling radar")
		toggle_radar()
		safe_set_input_as_handled()  # Mark input as handled
	elif event is InputEventKey and event.pressed:
		# Debug: Log all key presses to see if input is working
		GameLogger.debug("RadarSystem: Key pressed - " + str(event.keycode) + " (R is 82)")

func toggle_radar():
	GameLogger.info("RadarSystem: toggle_radar() called - current visible: " + str(visible) + ", is_radar_visible: " + str(is_radar_visible))
	is_radar_visible = !is_radar_visible
	visible = is_radar_visible
	
	if is_radar_visible:
		GameLogger.info("RadarSystem: Radar shown")
		update_radar_display()
	else:
		GameLogger.info("RadarSystem: Radar hidden")

func update_radar_display():
	if not is_radar_visible:
		return
	
	# Update all radar elements
	update_player_position()
	update_poi_positions()
	update_npc_positions()
	update_artifact_positions()
	update_path_display()

# Public methods for external access
func show_radar():
	is_radar_visible = true
	visible = true
	update_radar_display()

func hide_radar():
	is_radar_visible = false
	visible = false

func refresh_radar():
	find_world_objects()
	setup_scene_paths()
	update_radar_display()

# Get nearest POI to player
func get_nearest_poi() -> Dictionary:
	if not player or poi_list.is_empty():
		return {}
	
	var nearest_poi = poi_list[0]
	var nearest_distance = player.global_position.distance_to(nearest_poi.position)
	
	for poi in poi_list:
		var distance = player.global_position.distance_to(poi.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_poi = poi
	
	return nearest_poi
