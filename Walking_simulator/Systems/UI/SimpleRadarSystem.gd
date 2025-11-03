extends BaseUIComponent

# Import custom icon classes (use different names to avoid conflicts)
const MapPinIconClass = preload("res://Systems/UI/MapPinIcon.gd")
const PathLineClass = preload("res://Systems/UI/PathLine.gd")

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
var npc_list: Array[Node] = []
var artifact_list: Array[Node] = []
var path_points: Array[Vector3] = []

# Radar state
var is_radar_visible: bool = true
var radar_center: Vector2
var player_position: Vector2
var player_rotation: float

# Use MapPinIcon.IconType instead of local enum

func _on_component_ready():
	GameLogger.info("SimpleRadarSystem: _ready() called")
	GameLogger.info("SimpleRadarSystem: ===== SIMPLE RADAR SYSTEM READY =====")
	
	# Set up input handling
	process_mode = Node.PROCESS_MODE_INHERIT
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Initialize radar
	setup_radar()
	find_world_objects()
	setup_scene_paths()
	update_radar_display()
	
	# Initially hide radar (toggle with R key)
	visible = false
	is_radar_visible = false
	
	GameLogger.info("SimpleRadarSystem: Radar system initialized successfully")

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
	
	# Setup legend
	setup_legend()
	
	GameLogger.info("SimpleRadarSystem: Radar setup complete - hidden by default, press R to toggle")

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

func setup_legend():
	# Get legend container with error handling
	var legend = get_node_or_null("Legend")
	if not legend:
		GameLogger.warning("SimpleRadarSystem: Legend node not found, skipping legend setup")
		return
	
	GameLogger.info("SimpleRadarSystem: Setting up legend")
	
	# Setup legend icons with null checks
	var legend_player_icon = get_node_or_null("Legend/PlayerLegend/PlayerIcon")
	var npc_icon = get_node_or_null("Legend/NPCLegend/NPCIcon")
	var poi_icon = get_node_or_null("Legend/POILegend/POIIcon")
	var artifact_icon = get_node_or_null("Legend/ArtifactLegend/ArtifactIcon")
	
	if legend_player_icon:
		setup_legend_icon(legend_player_icon, player_icon_color, MapPinIconClass.IconType.PLAYER)
	if npc_icon:
		setup_legend_icon(npc_icon, npc_icon_color, MapPinIconClass.IconType.GUIDE)
	if poi_icon:
		setup_legend_icon(poi_icon, poi_icon_color, MapPinIconClass.IconType.CULTURE)
	if artifact_icon:
		setup_legend_icon(artifact_icon, artifact_icon_color, MapPinIconClass.IconType.ARTIFACT)
	
	# Style legend labels with null checks
	var labels = [
		get_node_or_null("Legend/LegendTitle"),
		get_node_or_null("Legend/PlayerLegend/PlayerLabel"),
		get_node_or_null("Legend/NPCLegend/NPCLabel"),
		get_node_or_null("Legend/POILegend/POILabel"),
		get_node_or_null("Legend/ArtifactLegend/ArtifactLabel")
	]
	
	for label in labels:
		if label:
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_font_size_override("font_size", 12)
	
	GameLogger.info("SimpleRadarSystem: Legend setup complete")

func setup_legend_icon(icon_container: Control, color: Color, icon_type: int):
	if not icon_container:
		return
	
	# Create map pin icon for legend
	var legend_icon = MapPinIconClass.new()
	legend_icon.icon_type = icon_type
	legend_icon.icon_color = color
	legend_icon.custom_minimum_size = Vector2(16, 16)
	legend_icon.size = Vector2(16, 16)
	icon_container.add_child(legend_icon)

func find_world_objects():
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		GameLogger.info("SimpleRadarSystem: Player found at " + str(player.global_position))
	
	# Find NPCs
	npc_list = get_tree().get_nodes_in_group("npc")
	GameLogger.debug("SimpleRadarSystem: Found " + str(npc_list.size()) + " NPCs")
	
	# Find artifacts
	artifact_list = get_tree().get_nodes_in_group("artifact")
	GameLogger.debug("SimpleRadarSystem: Found " + str(artifact_list.size()) + " artifacts")
	
	# Get current scene name
	var scene_name = get_tree().current_scene.name
	GameLogger.info("SimpleRadarSystem: Current scene: " + scene_name)
	
	# Setup scene-specific POIs
	match scene_name:
		"TamboraScene":
			setup_tambora_pois()
		"PapuaScene":
			setup_papua_pois()
		"PasarScene":
			setup_pasar_pois()
		_:
			GameLogger.warning("SimpleRadarSystem: Unknown scene: " + scene_name)
	
	GameLogger.info("SimpleRadarSystem: World objects found - NPCs: " + str(npc_list.size()) + ", Artifacts: " + str(artifact_list.size()) + ", POIs: " + str(poi_list.size()))

func setup_tambora_pois():
	# Tambora-specific points of interest
	poi_list = [
		{
			"name": "Volcano Summit",
			"position": Vector3(50, 0, 50),
			"icon_type": MapPinIconClass.IconType.VOLCANO,
			"description": "Mount Tambora summit"
		},
		{
			"name": "Historical Site",
			"position": Vector3(-30, 0, 20),
			"icon_type": MapPinIconClass.IconType.HISTORY,
			"description": "1815 eruption site"
		},
		{
			"name": "Geological Point",
			"position": Vector3(20, 0, -40),
			"icon_type": MapPinIconClass.IconType.GEOLOGY,
			"description": "Rock formations"
		}
	]

func setup_papua_pois():
	# Papua-specific points of interest
	poi_list = [
		{
			"name": "Ancient Site",
			"position": Vector3(40, 0, 30),
			"icon_type": MapPinIconClass.IconType.ANCIENT,
			"description": "Megalithic site"
		},
		{
			"name": "Cultural Center",
			"position": Vector3(-25, 0, 15),
			"icon_type": MapPinIconClass.IconType.CULTURE,
			"description": "Traditional village"
		},
		{
			"name": "Artifact Location",
			"position": Vector3(10, 0, -35),
			"icon_type": MapPinIconClass.IconType.ARTIFACT,
			"description": "Ancient artifacts"
		}
	]

func setup_pasar_pois():
	# Pasar-specific points of interest
	poi_list = [
		{
			"name": "Food Stalls",
			"position": Vector3(25, 0, 20),
			"icon_type": MapPinIconClass.IconType.FOOD,
			"description": "Traditional food"
		},
		{
			"name": "Craft Market",
			"position": Vector3(-20, 0, 15),
			"icon_type": MapPinIconClass.IconType.CRAFT,
			"description": "Local crafts"
		},
		{
			"name": "Cultural Display",
			"position": Vector3(0, 0, -25),
			"icon_type": MapPinIconClass.IconType.CULTURE,
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
	# Convert 3D world position to 2D radar position
	if not player:
		GameLogger.warning("SimpleRadarSystem: Player not found, cannot convert world position")
		return radar_center
	
	var relative_pos = world_pos - player.global_position
	var radar_pos = Vector2(relative_pos.x, -relative_pos.z) * radar_scale
	return radar_center + radar_pos

func update_poi_positions():
	# Clear existing POI icons
	for child in poi_container.get_children():
		if child.name.begins_with("poi_"):
			child.queue_free()
	
	# Create POI icons
	for poi in poi_list:
		var poi_icon = create_poi_icon(poi)
		var radar_pos = world_to_radar_position(poi.position)
		poi_icon.position = radar_pos - Vector2(12, 12)
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
		if artifact and is_instance_valid(artifact):
			var artifact_icon = create_artifact_icon(artifact)
			var radar_pos = world_to_radar_position(artifact.global_position)
			artifact_icon.position = radar_pos - Vector2(8, 8)
			poi_container.add_child(artifact_icon)

func create_poi_icon(poi: Dictionary) -> Control:
	var icon = MapPinIconClass.new()
	icon.name = "poi_" + poi.name
	icon.custom_minimum_size = Vector2(24, 24)
	icon.size = Vector2(24, 24)
	icon.icon_type = poi.icon_type
	icon.icon_color = poi_icon_color
	icon.tooltip_text = poi.description
	
	return icon

func create_npc_icon(npc: Node) -> Control:
	var icon = MapPinIconClass.new()
	icon.name = "npc_" + npc.name
	icon.custom_minimum_size = Vector2(20, 20)
	icon.size = Vector2(20, 20)
	
	# Determine NPC type based on name
	var icon_type = MapPinIconClass.IconType.GUIDE
	if "Vendor" in npc.name:
		icon_type = MapPinIconClass.IconType.VENDOR
	elif "Historian" in npc.name:
		icon_type = MapPinIconClass.IconType.HISTORIAN
	elif "Guide" in npc.name:
		icon_type = MapPinIconClass.IconType.GUIDE
	
	icon.icon_type = icon_type
	icon.icon_color = npc_icon_color
	icon.tooltip_text = "Talk to " + npc.name
	
	return icon

func create_artifact_icon(artifact: Node) -> Control:
	var icon = MapPinIconClass.new()
	icon.name = "artifact_" + artifact.name
	icon.custom_minimum_size = Vector2(16, 16)
	icon.size = Vector2(16, 16)
	icon.icon_type = MapPinIconClass.IconType.ARTIFACT
	icon.icon_color = artifact_icon_color
	icon.tooltip_text = "Collect " + artifact.name
	
	return icon

func _on_component_unhandled_input(event):
	if event.is_action_pressed("toggle_radar"):
		GameLogger.info("SimpleRadarSystem: R key pressed!")
		toggle_radar()
		safe_set_input_as_handled()
	elif event is InputEventKey and event.pressed:
		GameLogger.debug("SimpleRadarSystem: Key pressed - " + str(event.keycode))

func toggle_radar():
	GameLogger.info("SimpleRadarSystem: toggle_radar() called - current visible: " + str(visible) + ", is_radar_visible: " + str(is_radar_visible))
	is_radar_visible = !is_radar_visible
	visible = is_radar_visible
	
	if is_radar_visible:
		GameLogger.info("SimpleRadarSystem: Radar shown")
		update_radar_display()
	else:
		GameLogger.info("SimpleRadarSystem: Radar hidden")

func update_radar_display():
	if not is_radar_visible:
		return
	
	# Update all radar elements
	update_player_position()
	update_poi_positions()
	update_npc_positions()
	update_artifact_positions()
	update_path_display()

func setup_scene_paths():
	# Clear existing paths
	path_points.clear()
	
	# Add path points based on scene
	var scene_name = get_tree().current_scene.name
	match scene_name:
		"PasarScene":
			path_points = [
				Vector3(25, 0, 20),   # Food Stalls
				Vector3(-20, 0, 15),  # Craft Market
				Vector3(0, 0, -25),   # Cultural Display
				Vector3(25, 0, 20)    # Back to start
			]
		"TamboraScene":
			path_points = [
				Vector3(50, 0, 50),   # Volcano Summit
				Vector3(-30, 0, 20),  # Historical Site
				Vector3(20, 0, -40),  # Geological Point
				Vector3(50, 0, 50)    # Back to start
			]
		"PapuaScene":
			path_points = [
				Vector3(40, 0, 30),   # Ancient Site
				Vector3(-25, 0, 15),  # Cultural Center
				Vector3(10, 0, -35),  # Artifact Location
				Vector3(40, 0, 30)    # Back to start
			]

func update_path_display():
	# Clear existing path lines
	for child in path_container.get_children():
		child.queue_free()
	
	# Draw path lines
	if path_points.size() > 1:
		for i in range(path_points.size() - 1):
			var start_pos = world_to_radar_position(path_points[i])
			var end_pos = world_to_radar_position(path_points[i + 1])
			
			var path_line = PathLineClass.new()
			path_line.start_point = start_pos
			path_line.end_point = end_pos
			path_line.line_color = path_color
			path_line.line_width = 2.0
			path_container.add_child(path_line)

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

func _on_component_cleanup():
	# Hide radar to prevent any UI updates
	visible = false
	is_radar_visible = false
	
	GameLogger.debug("SimpleRadarSystem: Component cleanup complete")




