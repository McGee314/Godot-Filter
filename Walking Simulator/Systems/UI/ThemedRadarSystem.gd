extends BaseUIComponent
class_name ThemedRadarSystem

# Import custom icon classes
const MapPinIconClass = preload("res://Systems/UI/MapPinIcon.gd")
const PathLineClass = preload("res://Systems/UI/PathLine.gd")

# Radar configuration
@export var radar_size: float = 250.0
@export var radar_scale: float = 0.08
@export var background_color: Color = Color(0.95, 0.85, 0.7, 0.9)  # Light desert sand
@export var border_color: Color = Color(0.6, 0.4, 0.2, 0.8)  # Dark brown border
@export var path_color: Color = Color(0.8, 0.6, 0.4, 0.8)  # Desert sand color

# Radar elements
@onready var radar_circle: ColorRect = $RadarCircle
@onready var north_indicator: Label = $NorthIndicator
@onready var player_icon: Control = $PlayerIcon
@onready var poi_container: Control = $POIContainer
@onready var path_container: Control = $PathContainer
@onready var radar_border: ColorRect = $RadarBorder
@onready var environmental_container: Control = $EnvironmentalContainer

# World references
var player: CharacterBody3D
var current_scene: Node3D
var poi_list: Array[Dictionary] = []
var npc_list: Array[Node] = []
var artifact_list: Array[Node] = []
var path_points: Array[Vector3] = []
var environmental_elements: Array[Dictionary] = []

# Radar state
var is_radar_visible: bool = true
var radar_center: Vector2
var player_position: Vector2
var player_rotation: float

func _ready():
	print("ThemedRadarSystem: _ready() called")
	GameLogger.info("ThemedRadarSystem: ===== THEMED RADAR SYSTEM READY =====")
	
	process_mode = Node.PROCESS_MODE_INHERIT
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	setup_radar()
	find_world_objects()
	setup_scene_paths()
	setup_environmental_elements()
	update_radar_display()
	
	visible = false
	is_radar_visible = false
	
	GameLogger.info("ThemedRadarSystem: Themed radar system initialized successfully")

func setup_radar():
	radar_circle.custom_minimum_size = Vector2(radar_size, radar_size)
	radar_circle.size = Vector2(radar_size, radar_size)
	radar_center = Vector2(radar_size / 2, radar_size / 2)
	
	custom_minimum_size = Vector2(radar_size, radar_size)
	size = Vector2(radar_size, radar_size)
	
	radar_circle.color = background_color
	setup_radar_border()
	setup_player_icon()
	setup_legend()
	
	GameLogger.info("ThemedRadarSystem: Themed radar setup complete")

func setup_radar_border():
	radar_border.custom_minimum_size = Vector2(radar_size + 6, radar_size + 6)
	radar_border.size = Vector2(radar_size + 6, radar_size + 6)
	radar_border.position = Vector2(-3, -3)
	radar_border.color = border_color

func setup_player_icon():
	player_icon.custom_minimum_size = Vector2(16, 16)
	player_icon.size = Vector2(16, 16)
	player_icon.position = radar_center - Vector2(8, 8)
	
	var direction_indicator = ColorRect.new()
	direction_indicator.name = "DirectionIndicator"
	direction_indicator.custom_minimum_size = Vector2(2, 10)
	direction_indicator.size = Vector2(2, 10)
	direction_indicator.color = Color.WHITE
	direction_indicator.position = Vector2(7, 3)
	player_icon.add_child(direction_indicator)

func setup_legend():
	var legend = $Legend
	if not legend:
		return
	
	var labels = [$Legend/LegendTitle, $Legend/PlayerLegend/PlayerLabel, 
				  $Legend/NPCLegend/NPCLabel, $Legend/POILegend/POILabel, 
				  $Legend/ArtifactLegend/ArtifactLabel]
	
	for label in labels:
		if label:
			label.add_theme_color_override("font_color", Color.BROWN)
			label.add_theme_font_size_override("font_size", 12)

func find_world_objects():
	player = get_tree().get_first_node_in_group("player")
	if player:
		GameLogger.info("ThemedRadarSystem: Player found at " + str(player.global_position))
	else:
		GameLogger.warning("ThemedRadarSystem: Player not found!")
		return
	
	current_scene = get_tree().current_scene
	GameLogger.info("ThemedRadarSystem: Current scene: " + current_scene.name)
	
	npc_list = get_tree().get_nodes_in_group("npc")
	artifact_list = get_tree().get_nodes_in_group("artifact")
	
	setup_scene_pois()
	
	GameLogger.info("ThemedRadarSystem: World objects found")

func setup_scene_pois():
	poi_list.clear()
	
	var scene_name = get_tree().current_scene.name
	match scene_name:
		"TamboraScene":
			setup_tambora_pois()
		"PapuaScene":
			setup_papua_pois()
		"PasarScene":
			setup_pasar_pois()
		_:
			GameLogger.warning("ThemedRadarSystem: Unknown scene: " + scene_name)

func setup_tambora_pois():
	poi_list = [
		{
			"name": "Volcano Summit",
			"position": Vector3(50, 0, 50),
			"icon_type": MapPinIconClass.IconType.VOLCANO,
			"description": "Mount Tambora summit - Level 1",
			"completed": true,
			"stars": 3
		},
		{
			"name": "Historical Site",
			"position": Vector3(-30, 0, 20),
			"icon_type": MapPinIconClass.IconType.HISTORY,
			"description": "1815 eruption site - Level 2",
			"completed": true,
			"stars": 2
		},
		{
			"name": "Geological Point",
			"position": Vector3(20, 0, -40),
			"icon_type": MapPinIconClass.IconType.GEOLOGY,
			"description": "Rock formations - Level 3",
			"completed": false,
			"stars": 0
		}
	]

func setup_papua_pois():
	poi_list = [
		{
			"name": "Ancient Site",
			"position": Vector3(40, 0, 30),
			"icon_type": MapPinIconClass.IconType.ANCIENT,
			"description": "Megalithic site - Level 1",
			"completed": true,
			"stars": 3
		},
		{
			"name": "Cultural Center",
			"position": Vector3(-25, 0, 15),
			"icon_type": MapPinIconClass.IconType.CULTURE,
			"description": "Traditional village - Level 2",
			"completed": true,
			"stars": 2
		},
		{
			"name": "Artifact Location",
			"position": Vector3(10, 0, -35),
			"icon_type": MapPinIconClass.IconType.ARTIFACT,
			"description": "Ancient artifacts - Level 3",
			"completed": false,
			"stars": 0
		}
	]

func setup_pasar_pois():
	poi_list = [
		{
			"name": "Food Stalls",
			"position": Vector3(25, 0, 20),
			"icon_type": MapPinIconClass.IconType.FOOD,
			"description": "Traditional food - Level 1",
			"completed": true,
			"stars": 3
		},
		{
			"name": "Craft Market",
			"position": Vector3(-20, 0, 15),
			"icon_type": MapPinIconClass.IconType.CRAFT,
			"description": "Local crafts - Level 2",
			"completed": true,
			"stars": 2
		},
		{
			"name": "Cultural Display",
			"position": Vector3(0, 0, -25),
			"icon_type": MapPinIconClass.IconType.CULTURE,
			"description": "Cultural exhibition - Level 3",
			"completed": false,
			"stars": 0
		}
	]

func setup_environmental_elements():
	environmental_elements.clear()
	
	var scene_name = get_tree().current_scene.name
	match scene_name:
		"TamboraScene":
			setup_tambora_environment()
		"PapuaScene":
			setup_papua_environment()
		"PasarScene":
			setup_pasar_environment()

func setup_tambora_environment():
	environmental_elements = [
		{"type": "rock", "position": Vector3(60, 0, 60), "size": Vector2(8, 8)},
		{"type": "rock", "position": Vector3(-40, 0, 30), "size": Vector2(6, 6)},
		{"type": "rock", "position": Vector3(30, 0, -50), "size": Vector2(10, 10)}
	]

func setup_papua_environment():
	environmental_elements = [
		{"type": "seaweed", "position": Vector3(50, 0, 40), "size": Vector2(6, 12)},
		{"type": "bubble", "position": Vector3(-30, 0, 20), "size": Vector2(4, 4)},
		{"type": "rock", "position": Vector3(15, 0, -40), "size": Vector2(8, 8)}
	]

func setup_pasar_environment():
	environmental_elements = [
		{"type": "stall", "position": Vector3(30, 0, 25), "size": Vector2(10, 8)},
		{"type": "stall", "position": Vector3(-25, 0, 20), "size": Vector2(8, 10)},
		{"type": "decoration", "position": Vector3(5, 0, -30), "size": Vector2(6, 6)}
	]

func _process(_delta):
	if not is_radar_visible or not player:
		return
	
	update_player_position()
	update_poi_positions()
	update_npc_positions()
	update_artifact_positions()
	update_environmental_elements()
	update_path_display()

func update_player_position():
	if not player:
		return
	
	var world_pos = player.global_position
	player_position = world_to_radar_position(world_pos)
	player_icon.position = player_position - Vector2(8, 8)
	
	player_rotation = player.rotation.y
	player_icon.rotation = player_rotation

func world_to_radar_position(world_pos: Vector3) -> Vector2:
	var relative_pos = world_pos - player.global_position
	var radar_pos = Vector2(relative_pos.x, -relative_pos.z) * radar_scale
	return radar_center + radar_pos

func update_poi_positions():
	for child in poi_container.get_children():
		if child.name.begins_with("poi_"):
			child.queue_free()
	
	for poi in poi_list:
		var poi_icon = create_progression_poi_icon(poi)
		var radar_pos = world_to_radar_position(poi.position)
		poi_icon.position = radar_pos - Vector2(16, 16)
		poi_container.add_child(poi_icon)

func create_progression_poi_icon(poi: Dictionary) -> Control:
	var icon = Control.new()
	icon.name = "poi_" + poi.name
	icon.custom_minimum_size = Vector2(32, 32)
	icon.size = Vector2(32, 32)
	icon.tooltip_text = poi.description
	
	var background = ColorRect.new()
	background.name = "Background"
	background.custom_minimum_size = Vector2(32, 32)
	background.size = Vector2(32, 32)
	background.color = Color.DARK_GRAY
	icon.add_child(background)
	
	if poi.completed:
		var number_label = Label.new()
		number_label.name = "Number"
		number_label.text = str(poi_list.find(poi) + 1)
		number_label.add_theme_color_override("font_color", Color.WHITE)
		number_label.add_theme_font_size_override("font_size", 14)
		number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		number_label.custom_minimum_size = Vector2(32, 32)
		number_label.size = Vector2(32, 32)
		icon.add_child(number_label)
		
		if poi.stars > 0:
			var star_container = Control.new()
			star_container.name = "Stars"
			star_container.custom_minimum_size = Vector2(32, 16)
			star_container.size = Vector2(32, 16)
			star_container.position = Vector2(0, -20)
			icon.add_child(star_container)
			
			for i in range(poi.stars):
				var star = Label.new()
				star.text = "★"
				star.add_theme_color_override("font_color", Color.YELLOW)
				star.add_theme_font_size_override("font_size", 12)
				star.position = Vector2(i * 8, 0)
				star_container.add_child(star)
	else:
		var lock_label = Label.new()
		lock_label.name = "Lock"
		lock_label.text = "🔒"
		lock_label.add_theme_font_size_override("font_size", 16)
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_label.custom_minimum_size = Vector2(32, 32)
		lock_label.size = Vector2(32, 32)
		icon.add_child(lock_label)
	
	return icon

func update_npc_positions():
	for child in poi_container.get_children():
		if child.name.begins_with("npc_"):
			child.queue_free()
	
	for npc in npc_list:
		if npc and is_instance_valid(npc):
			var npc_icon = create_npc_icon(npc)
			var radar_pos = world_to_radar_position(npc.global_position)
			npc_icon.position = radar_pos - Vector2(8, 8)
			poi_container.add_child(npc_icon)

func update_artifact_positions():
	for child in poi_container.get_children():
		if child.name.begins_with("artifact_"):
			child.queue_free()
	
	for artifact in artifact_list:
		if artifact and is_instance_valid(artifact):
			var artifact_icon = create_artifact_icon(artifact)
			var radar_pos = world_to_radar_position(artifact.global_position)
			artifact_icon.position = radar_pos - Vector2(8, 8)
			poi_container.add_child(artifact_icon)

func update_environmental_elements():
	for child in environmental_container.get_children():
		child.queue_free()
	
	for element in environmental_elements:
		var env_icon = create_environmental_icon(element)
		var radar_pos = world_to_radar_position(element.position)
		env_icon.position = radar_pos - Vector2(element.size.x / 2, element.size.y / 2)
		environmental_container.add_child(env_icon)

func create_environmental_icon(element: Dictionary) -> Control:
	var icon = Control.new()
	icon.name = "env_" + element.type
	icon.custom_minimum_size = element.size
	icon.size = element.size
	
	var element_rect = ColorRect.new()
	element_rect.custom_minimum_size = element.size
	element_rect.size = element.size
	
	match element.type:
		"rock":
			element_rect.color = Color(0.6, 0.4, 0.2, 0.8)
		"seaweed":
			element_rect.color = Color(0.2, 0.8, 0.2, 0.6)
		"bubble":
			element_rect.color = Color(1, 1, 1, 0.4)
		"stall":
			element_rect.color = Color(0.8, 0.6, 0.4, 0.7)
		"decoration":
			element_rect.color = Color(0.9, 0.7, 0.5, 0.6)
	
	icon.add_child(element_rect)
	return icon

func create_npc_icon(npc: Node) -> Control:
	var icon = MapPinIconClass.new()
	icon.name = "npc_" + npc.name
	icon.custom_minimum_size = Vector2(20, 20)
	icon.size = Vector2(20, 20)
	
	var icon_type = MapPinIconClass.IconType.GUIDE
	if "Vendor" in npc.name:
		icon_type = MapPinIconClass.IconType.VENDOR
	elif "Historian" in npc.name:
		icon_type = MapPinIconClass.IconType.HISTORIAN
	elif "Guide" in npc.name:
		icon_type = MapPinIconClass.IconType.GUIDE
	
	icon.icon_type = icon_type
	icon.icon_color = Color.BLUE
	icon.tooltip_text = "Talk to " + npc.name
	
	return icon

func create_artifact_icon(artifact: Node) -> Control:
	var icon = MapPinIconClass.new()
	icon.name = "artifact_" + artifact.name
	icon.custom_minimum_size = Vector2(16, 16)
	icon.size = Vector2(16, 16)
	icon.icon_type = MapPinIconClass.IconType.ARTIFACT
	icon.icon_color = Color.GREEN
	icon.tooltip_text = "Collect " + artifact.name
	
	return icon

func _on_component_unhandled_input(event):
	if event.is_action_pressed("toggle_radar"):
		print("ThemedRadarSystem: R key pressed!")
		GameLogger.info("ThemedRadarSystem: R key pressed!")
		toggle_radar()
		safe_set_input_as_handled()

func toggle_radar():
	GameLogger.info("ThemedRadarSystem: toggle_radar() called")
	is_radar_visible = !is_radar_visible
	visible = is_radar_visible
	
	if is_radar_visible:
		GameLogger.info("ThemedRadarSystem: Themed radar shown")
		update_radar_display()
	else:
		GameLogger.info("ThemedRadarSystem: Themed radar hidden")

func update_radar_display():
	if not is_radar_visible:
		return
	
	update_player_position()
	update_poi_positions()
	update_npc_positions()
	update_artifact_positions()
	update_environmental_elements()
	update_path_display()

func setup_scene_paths():
	path_points.clear()
	
	var scene_name = get_tree().current_scene.name
	match scene_name:
		"PasarScene":
			path_points = [
				Vector3(25, 0, 20), Vector3(-20, 0, 15), Vector3(0, 0, -25), Vector3(25, 0, 20)
			]
		"TamboraScene":
			path_points = [
				Vector3(50, 0, 50), Vector3(-30, 0, 20), Vector3(20, 0, -40), Vector3(50, 0, 50)
			]
		"PapuaScene":
			path_points = [
				Vector3(40, 0, 30), Vector3(-25, 0, 15), Vector3(10, 0, -35), Vector3(40, 0, 30)
			]

func update_path_display():
	for child in path_container.get_children():
		child.queue_free()
	
	if path_points.size() > 1:
		for i in range(path_points.size() - 1):
			var start_pos = world_to_radar_position(path_points[i])
			var end_pos = world_to_radar_position(path_points[i + 1])
			
			var path_line = PathLineClass.new()
			path_line.start_point = start_pos
			path_line.end_point = end_pos
			path_line.line_color = path_color
			path_line.line_width = 3.0
			path_container.add_child(path_line)

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
	setup_environmental_elements()
	update_radar_display()

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
