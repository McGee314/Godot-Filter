class_name CameraSceneConfig
extends Resource

## Camera Scene Configuration Resource
## Defines all camera views available for a specific scene

@export_group("Scene Information")
@export var scene_name: String = "Default Scene"
@export var scene_description: String = "Default camera configuration for scene"

@export_group("Camera Views")
@export var player_view: CameraViewConfig
@export var far_side_view: CameraViewConfig
@export var canopy_view: CameraViewConfig
@export var custom_views: Array[CameraViewConfig] = []

@export_group("Default Settings")
@export var default_view_mode: int = 0  # 0 = Player, 1 = Far Side, 2 = Canopy
@export var enable_mouse_look: bool = true
@export var mouse_sensitivity: float = 0.002

func _init():
	resource_name = "Camera Scene Config"
	
	# Create default views if not set
	if not player_view:
		player_view = create_default_player_view()
	if not far_side_view:
		far_side_view = create_default_far_side_view()
	if not canopy_view:
		canopy_view = create_default_canopy_view()

func create_default_player_view() -> CameraViewConfig:
	"""Create default player view configuration"""
	var config = CameraViewConfig.new()
	config.view_name = "Player View"
	config.view_description = "Normal Player View"
	config.spring_length = 7.0
	config.pivot_offset = Vector3(0, 2.5, 0)
	config.pivot_rotation = Vector3(deg_to_rad(-15), 0, 0)
	config.key_binding = KEY_1
	return config

func create_default_far_side_view() -> CameraViewConfig:
	"""Create default far side view configuration"""
	var config = CameraViewConfig.new()
	config.view_name = "Far Side View"
	config.view_description = "Far Side Overview"
	config.spring_length = 50.0
	config.pivot_offset = Vector3(0, 30.0, 0)
	config.pivot_rotation = Vector3(deg_to_rad(-45), deg_to_rad(45), 0)
	config.key_binding = KEY_2
	return config

func create_default_canopy_view() -> CameraViewConfig:
	"""Create default canopy view configuration"""
	var config = CameraViewConfig.new()
	config.view_name = "Canopy View"
	config.view_description = "Canopy Level View"
	config.spring_length = 15.0
	config.pivot_offset = Vector3(0, 20.0, 0)
	config.pivot_rotation = Vector3(deg_to_rad(-60), 0, 0)
	config.key_binding = KEY_3
	return config

func get_all_views() -> Array[CameraViewConfig]:
	"""Get all camera views in this scene configuration"""
	var views: Array[CameraViewConfig] = []
	
	if player_view:
		views.append(player_view)
	if far_side_view:
		views.append(far_side_view)
	if canopy_view:
		views.append(canopy_view)
	
	# Add custom views
	for custom_view in custom_views:
		if custom_view:
			views.append(custom_view)
	
	return views

func get_view_by_key(key: Key) -> CameraViewConfig:
	"""Get camera view configuration by key binding"""
	var all_views = get_all_views()
	for view in all_views:
		if view.key_binding == key:
			return view
	return null

func get_view_by_index(index: int) -> CameraViewConfig:
	"""Get camera view by index (0=Player, 1=Far Side, 2=Canopy, 3+=Custom)"""
	match index:
		0:
			return player_view
		1:
			return far_side_view
		2:
			return canopy_view
		_:
			var custom_index = index - 3
			if custom_index >= 0 and custom_index < custom_views.size():
				return custom_views[custom_index]
	return null

func get_default_view() -> CameraViewConfig:
	"""Get the default camera view for this scene"""
	return get_view_by_index(default_view_mode)

func get_debug_info() -> String:
	"""Get debug information about this scene configuration"""
	var info = "CameraSceneConfig[%s]:\n" % scene_name
	var all_views = get_all_views()
	for i in range(all_views.size()):
		info += "  %d. %s\n" % [i, all_views[i].get_debug_info()]
	return info
