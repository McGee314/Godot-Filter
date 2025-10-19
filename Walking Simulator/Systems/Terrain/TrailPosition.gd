extends Node3D
class_name TrailPosition

# Trail Position Manager
# Manages individual positions along the hiking trail
# Based on real Tambora hiking trail positions

signal position_activated(position_name: String, elevation: float)

@export var position_name: String = "Position"
@export var elevation: float = 0.0
@export var coordinates: Vector2 = Vector2.ZERO  # Lat/Lon coordinates
@export var has_shelter: bool = false
@export var has_water: bool = false
@export var terrain_type: String = "forest"

# Visual elements
var position_marker: Node3D
var shelter_marker: Node3D
var info_sign: Node3D

func _ready():
	GameLogger.info("Initializing trail position: %s at %dm" % [position_name, elevation])
	
	# Set position based on elevation
	position.y = elevation
	
	# Create visual elements
	create_position_marker()
	create_info_sign()
	
	if has_shelter:
		create_shelter_marker()
	
	# Set terrain-specific properties
	setup_terrain_properties()

func create_position_marker():
	"""Create visual marker for this position"""
	position_marker = Node3D.new()
	position_marker.name = "PositionMarker"
	add_child(position_marker)
	
	# Create a simple marker (can be enhanced with 3D models)
	var marker_mesh = CSGBox3D.new()
	marker_mesh.size = Vector3(0.5, 2.0, 0.5)
	marker_mesh.material = StandardMaterial3D.new()
	marker_mesh.material.albedo_color = Color.RED
	
	position_marker.add_child(marker_mesh)
	position_marker.position.y = 1.0

func create_info_sign():
	"""Create information sign for this position"""
	info_sign = Node3D.new()
	info_sign.name = "InfoSign"
	add_child(info_sign)
	
	# Create sign post
	var sign_post = CSGBox3D.new()
	sign_post.size = Vector3(0.1, 3.0, 0.1)
	sign_post.material = StandardMaterial3D.new()
	sign_post.material.albedo_color = Color.BROWN
	
	info_sign.add_child(sign_post)
	info_sign.position = Vector3(2.0, 1.5, 0.0)
	
	# Create sign board
	var sign_board = CSGBox3D.new()
	sign_board.size = Vector3(1.5, 1.0, 0.05)
	sign_board.material = StandardMaterial3D.new()
	sign_board.material.albedo_color = Color.WHITE
	
	info_sign.add_child(sign_board)
	sign_board.position = Vector3(0.0, 1.0, 0.0)

func create_shelter_marker():
	"""Create shelter marker for positions with shelters"""
	shelter_marker = Node3D.new()
	shelter_marker.name = "ShelterMarker"
	add_child(shelter_marker)
	
	# Create simple shelter representation
	var shelter_roof = CSGBox3D.new()
	shelter_roof.size = Vector3(4.0, 0.2, 3.0)
	shelter_roof.material = StandardMaterial3D.new()
	shelter_roof.material.albedo_color = Color.BLUE
	
	shelter_marker.add_child(shelter_roof)
	shelter_marker.position = Vector3(5.0, 2.5, 0.0)
	
	# Create shelter posts
	for i in range(4):
		var post = CSGBox3D.new()
		post.size = Vector3(0.2, 2.5, 0.2)
		post.material = StandardMaterial3D.new()
		post.material.albedo_color = Color.GREEN
		
		shelter_marker.add_child(post)
		
		var post_x = -1.5 if i % 2 == 0 else 1.5
		var post_z = -1.0 if i < 2 else 1.0
		post.position = Vector3(post_x, 1.25, post_z)

func setup_terrain_properties():
	"""Setup terrain-specific properties for this position"""
	match terrain_type:
		"jungle_base":
			# Dense vegetation, clear path
			pass
		"forest_mid":
			# Mixed forest, some clearings
			pass
		"forest_high":
			# Sparse forest, more rocks
			pass
		"stream_area":
			# Stream crossing, moss-covered rocks
			if has_water:
				create_water_feature()
		"volcanic_mid":
			# Volcanic terrain, sparse vegetation
			pass
		"volcanic_summit":
			# Barren volcanic landscape
			pass

func create_water_feature():
	"""Create water feature for stream areas"""
	var water = CSGBox3D.new()
	water.size = Vector3(3.0, 0.3, 1.0)
	water.material = StandardMaterial3D.new()
	water.material.albedo_color = Color(0.2, 0.4, 0.8, 0.7)
	water.material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	add_child(water)
	water.position = Vector3(0.0, 0.15, 3.0)

func activate_position():
	"""Activate this position (called when player reaches it)"""
	GameLogger.info("Activated position: %s at %dm" % [position_name, elevation])
	
	# Visual feedback
	if position_marker:
		var marker_material = position_marker.get_child(0).material as StandardMaterial3D
		marker_material.albedo_color = Color.GREEN
	
	# Emit signal
	position_activated.emit(position_name, elevation)

func get_position_info() -> Dictionary:
	"""Get information about this position"""
	return {
		"name": position_name,
		"elevation": elevation,
		"coordinates": coordinates,
		"has_shelter": has_shelter,
		"has_water": has_water,
		"terrain_type": terrain_type
	}

func get_elevation_gain_from_start() -> float:
	"""Get elevation gain from start position"""
	return elevation - 690.0  # Start elevation

func get_distance_from_start() -> float:
	"""Get approximate distance from start based on position"""
	var distances = {
		"Start": 0.0,
		"Pos1": 1200.0,
		"Pos2": 2400.0,
		"Pos3": 3200.0,
		"Pos4": 4000.0,
		"Summit": 5000.0
	}
	
	return distances.get(position_name, 0.0)
