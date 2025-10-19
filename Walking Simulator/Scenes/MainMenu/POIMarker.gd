class_name POIMarker
extends Node3D

# POI (Point of Interest) Marker for 3D Indonesia Map
# Represents a location on the map with interactive capabilities

# POI data
@export var poi_id: String = ""
@export var poi_name: String = ""
@export var poi_description: String = ""
@export var poi_region: String = ""
@export var poi_recipe: String = ""
@export var poi_unlocked: bool = true

# Visual properties
@export var marker_color: Color = Color.WHITE
@export var marker_emission: Color = Color.WHITE
@export var marker_scale: Vector3 = Vector3.ONE
@export var label_text: String = ""

# Interaction properties
@export var interaction_radius: float = 0.5
@export var clickable: bool = true
@export var hoverable: bool = true

# Animation properties
@export var hover_scale: Vector3 = Vector3(1.2, 1.2, 1.2)
@export var animation_speed: float = 2.0

# Node references
@onready var marker_mesh: MeshInstance3D = $MarkerMesh
@onready var interaction_area: Area3D = $InteractionArea
@onready var label_3d: Label3D = $Label3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# State
var is_hovered: bool = false
var is_selected: bool = false
var original_scale: Vector3
var original_emission: Color

# Signals
signal poi_clicked(poi_data: Dictionary)
signal poi_hovered(poi_data: Dictionary)
signal poi_unhovered(poi_data: Dictionary)

func _ready():
	setup_marker()
	setup_interaction()
	setup_animation()
	connect_signals()

func setup_marker():
	"""Setup the visual marker"""
	# Create marker mesh if not already present
	if not marker_mesh:
		marker_mesh = MeshInstance3D.new()
		marker_mesh.name = "MarkerMesh"
		add_child(marker_mesh)
	
	# Create sphere mesh
	var sphere_mesh = SphereMesh.new()
	# Make markers larger and more visible on the map
	sphere_mesh.radius = 0.25
	sphere_mesh.height = 0.3
	marker_mesh.mesh = sphere_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = marker_color
	material.emission = marker_emission
	material.emission_enabled = true
	material.roughness = 0.3
	material.metallic = 0.1
	marker_mesh.material_override = material
	
	# Store original values
	original_scale = marker_scale
	original_emission = marker_emission
	
	# Apply initial scale
	scale = marker_scale
	# Lift marker slightly above surface so it's not embedded
	position.y += 0.2

func setup_interaction():
	"""Setup interaction area"""
	if not interaction_area:
		interaction_area = Area3D.new()
		interaction_area.name = "InteractionArea"
		add_child(interaction_area)
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = interaction_radius
	collision_shape.shape = sphere_shape
	interaction_area.add_child(collision_shape)

func setup_animation():
	"""Setup animation system"""
	if not animation_player:
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		add_child(animation_player)
	
	# Create hover animation
	var hover_animation = Animation.new()
	hover_animation.length = 1.0 / animation_speed
	hover_animation.loop_mode = Animation.LOOP_LINEAR
	
	# Create track for scale
	var scale_track = hover_animation.add_track(Animation.TYPE_POSITION_3D)
	hover_animation.track_set_path(scale_track, NodePath("."))
	hover_animation.track_insert_key(scale_track, 0.0, original_scale)
	hover_animation.track_insert_key(scale_track, 0.5, hover_scale)
	hover_animation.track_insert_key(scale_track, 1.0, original_scale)
	
	# Create track for emission - call helper on this node
	var emission_track = hover_animation.add_track(Animation.TYPE_METHOD)
	hover_animation.track_set_path(emission_track, NodePath("."))
	hover_animation.track_insert_key(emission_track, 0.0, {"method": "_set_marker_emission", "args": [original_emission]})
	hover_animation.track_insert_key(emission_track, 0.5, {"method": "_set_marker_emission", "args": [marker_emission * 2.0]})
	hover_animation.track_insert_key(emission_track, 1.0, {"method": "_set_marker_emission", "args": [original_emission]})
	
	# Add animation to player using Godot 4 AnimationLibrary
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("hover", hover_animation)
	animation_player.add_animation_library("default", animation_library)

func setup_label():
	"""Setup 3D label"""
	if not label_3d:
		label_3d = Label3D.new()
		label_3d.name = "Label3D"
		label_3d.position = Vector3(0, 0.5, 0)
		label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label_3d.font_size = 16
		label_3d.outline_size = 4
		label_3d.outline_color = Color.BLACK
		add_child(label_3d)
	
	# Set label text
	if label_text.is_empty():
		label_text = poi_name
	label_3d.text = label_text

func connect_signals():
	"""Connect interaction signals"""
	if interaction_area:
		interaction_area.input_event.connect(_on_input_event)
		interaction_area.mouse_entered.connect(_on_mouse_entered)
		interaction_area.mouse_exited.connect(_on_mouse_exited)

func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	"""Handle input events on the POI marker"""
	if not clickable:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select_poi()

func _on_mouse_entered():
	"""Handle mouse entering the POI marker"""
	if not hoverable:
		return
	
	is_hovered = true
	start_hover_animation()
	poi_hovered.emit(get_poi_data())

func _on_mouse_exited():
	"""Handle mouse exiting the POI marker"""
	if not hoverable:
		return
	
	is_hovered = false
	stop_hover_animation()
	poi_unhovered.emit(get_poi_data())

func select_poi():
	"""Select this POI marker"""
	if not poi_unlocked:
		GameLogger.warning("POI is locked: " + poi_name)
		return
	
	is_selected = true
	GameLogger.info("Selected POI: " + poi_name)
	poi_clicked.emit(get_poi_data())

func start_hover_animation():
	"""Start hover animation"""
	if animation_player and animation_player.has_animation_library("default") and animation_player.get_animation_library("default").has_animation("hover"):
		animation_player.play("default/hover")

func stop_hover_animation():
	"""Stop hover animation"""
	if animation_player:
		animation_player.stop()
		# Reset to original state
		scale = original_scale
		if marker_mesh and marker_mesh.material_override:
			var material = marker_mesh.material_override as StandardMaterial3D
			if material:
				material.emission = original_emission

func _set_marker_emission(color: Color) -> void:
	# Safely set emission on marker material
	if marker_mesh and marker_mesh.material_override:
		var material := marker_mesh.material_override as StandardMaterial3D
		if material:
			material.emission_enabled = true
			material.emission = color

func set_poi_data(data: Dictionary):
	"""Set POI data from dictionary"""
	poi_id = data.get("id", "")
	poi_name = data.get("name", "")
	poi_description = data.get("description", "")
	poi_region = data.get("region", "")
	poi_recipe = data.get("cooking_recipe", "")
	poi_unlocked = data.get("unlocked", true)
	
	# Update visual properties based on region
	update_visual_properties()
	
	# Update label
	if label_3d:
		label_3d.text = poi_name

func get_poi_data() -> Dictionary:
	"""Get POI data as dictionary"""
	return {
		"id": poi_id,
		"name": poi_name,
		"description": poi_description,
		"region": poi_region,
		"cooking_recipe": poi_recipe,
		"unlocked": poi_unlocked,
		"position": global_position
	}

func update_visual_properties():
	"""Update visual properties based on POI data"""
	# Set color based on region
	match poi_region:
		"Sumatera Selatan", "Kepulauan Bangka Belitung", "DKI Jakarta":
			marker_color = Color.RED  # Indonesia Barat
		"DI Yogyakarta", "Bali":
			marker_color = Color.YELLOW  # Indonesia Tengah
		"Sulawesi Selatan", "Papua":
			marker_color = Color.BLUE  # Indonesia Timur
		_:
			marker_color = Color.WHITE
	
	# Set emission color
	marker_emission = marker_color * 0.3
	
	# Update material if it exists
	if marker_mesh and marker_mesh.material_override:
		var material = marker_mesh.material_override as StandardMaterial3D
		if material:
			material.albedo_color = marker_color
			material.emission = marker_emission
			original_emission = marker_emission

func set_unlocked(unlocked: bool):
	"""Set POI unlocked state"""
	poi_unlocked = unlocked
	
	# Update visual appearance based on locked state
	if marker_mesh and marker_mesh.material_override:
		var material = marker_mesh.material_override as StandardMaterial3D
		if material:
			if unlocked:
				material.albedo_color = marker_color
				material.emission = marker_emission
			else:
				material.albedo_color = Color.GRAY
				material.emission = Color.BLACK

func set_selected(selected: bool):
	"""Set POI selected state"""
	is_selected = selected
	
	if selected:
		# Highlight selected POI
		if marker_mesh and marker_mesh.material_override:
			var material = marker_mesh.material_override as StandardMaterial3D
			if material:
				material.emission = marker_color * 0.8
	else:
		# Reset to normal state
		if marker_mesh and marker_mesh.material_override:
			var material = marker_mesh.material_override as StandardMaterial3D
			if material:
				material.emission = original_emission

func get_distance_to_camera(camera: Camera3D) -> float:
	"""Get distance from POI to camera"""
	if camera:
		return global_position.distance_to(camera.global_position)
	return 0.0

func is_visible_to_camera(camera: Camera3D) -> bool:
	"""Check if POI is visible to camera"""
	if not camera:
		return false
	
	var screen_pos = camera.unproject_position(global_position)
	var viewport_size = get_viewport().size
	
	return screen_pos.x >= 0 and screen_pos.x <= viewport_size.x and \
		   screen_pos.y >= 0 and screen_pos.y <= viewport_size.y
