extends RefCounted
class_name WheelGraphConfigSelector

## Helper class to select and load different wheel graph configurations
## Provides easy access to W4, W5, W6, W7, W8, W9 patterns

enum PresetType {
	SQUARE_BASIC,      # W4 - Basic square
	PENTAGON_PAPUA,    # W5 - Papua style pentagon
	HEXAGON_CLASSIC,   # W6 - Classic hexagon
	HEPTAGON_SACRED,   # W7 - Sacred heptagon
	OCTAGON_CEREMONY,  # W8 - Ceremonial octagon
	ENNEAGON_ROYAL     # W9 - Royal enneagon
}

static var config_paths = {
	PresetType.SQUARE_BASIC: "res://Resources/PathSystem/SquareWheelGraphConfig.tres",
	PresetType.PENTAGON_PAPUA: "res://Resources/PathSystem/PapuaWheelGraphConfig.tres",
	PresetType.HEXAGON_CLASSIC: "res://Resources/PathSystem/HexagonWheelGraphConfig.tres",
	PresetType.HEPTAGON_SACRED: "res://Resources/PathSystem/HeptagonWheelGraphConfig.tres",
	PresetType.OCTAGON_CEREMONY: "res://Resources/PathSystem/OctagonWheelGraphConfig.tres",
	PresetType.ENNEAGON_ROYAL: "res://Resources/PathSystem/EnneagonWheelGraphConfig.tres"
}

static func load_config(preset: PresetType) -> WheelGraphPathConfig:
	"""Load a wheel graph configuration by preset type"""
	var path = config_paths.get(preset)
	if not path:
		GameLogger.error("❌ Unknown preset type: %s" % preset)
		return null
	
	var config = load(path) as WheelGraphPathConfig
	if not config:
		GameLogger.error("❌ Failed to load config from: %s" % path)
		return null
	
	GameLogger.info("✅ Loaded wheel graph config: %s (%s vertices)" % [
		PresetType.keys()[preset], 
		config.get_vertex_count()
	])
	
	return config

static func get_config_by_wheel_type(wheel_type: WheelGraphPathConfig.WheelType) -> WheelGraphPathConfig:
	"""Get configuration by wheel type (W4, W5, W6, etc.)"""
	var preset: PresetType
	
	match wheel_type:
		WheelGraphPathConfig.WheelType.W4:
			preset = PresetType.SQUARE_BASIC
		WheelGraphPathConfig.WheelType.W5:
			preset = PresetType.PENTAGON_PAPUA
		WheelGraphPathConfig.WheelType.W6:
			preset = PresetType.HEXAGON_CLASSIC
		WheelGraphPathConfig.WheelType.W7:
			preset = PresetType.HEPTAGON_SACRED
		WheelGraphPathConfig.WheelType.W8:
			preset = PresetType.OCTAGON_CEREMONY
		WheelGraphPathConfig.WheelType.W9:
			preset = PresetType.ENNEAGON_ROYAL
		_:
			GameLogger.error("❌ Unsupported wheel type: %s" % wheel_type)
			return null
	
	return load_config(preset)

static func create_custom_config(wheel_type: WheelGraphPathConfig.WheelType, radius: float, scene_type: WheelGraphPathConfig.SceneType) -> WheelGraphPathConfig:
	"""Create a custom configuration with specified parameters"""
	# Start with a base config
	var base_config = get_config_by_wheel_type(wheel_type)
	if not base_config:
		return null
	
	# Duplicate to avoid modifying the original
	var custom_config = base_config.duplicate() as WheelGraphPathConfig
	
	# Apply customizations
	custom_config.outer_radius = radius
	custom_config.scene_type = scene_type
	
	# Adjust inner radius proportionally for complex patterns
	if wheel_type >= WheelGraphPathConfig.WheelType.W7:
		custom_config.inner_radius = radius * 0.4  # 40% of outer radius
	elif wheel_type >= WheelGraphPathConfig.WheelType.W6:
		custom_config.inner_radius = radius * 0.3  # 30% of outer radius
	else:
		custom_config.inner_radius = 0  # No inner ring for simple patterns
	
	GameLogger.info("🎨 Created custom %s config: radius=%.1f, scene=%s" % [
		WheelGraphPathConfig.WheelType.keys()[wheel_type - 4],
		radius,
		WheelGraphPathConfig.SceneType.keys()[scene_type]
	])
	
	return custom_config

static func get_all_available_patterns() -> Array[String]:
	"""Get list of all available wheel patterns"""
	return [
		"W4 - Square (Persegi)",
		"W5 - Pentagon", 
		"W6 - Hexagon",
		"W7 - Heptagon (Sacred)",
		"W8 - Octagon (Ceremonial)", 
		"W9 - Enneagon (Royal)"
	]

static func get_pattern_description(wheel_type: WheelGraphPathConfig.WheelType) -> String:
	"""Get description of a wheel pattern"""
	match wheel_type:
		WheelGraphPathConfig.WheelType.W4:
			return "Square pattern - Simple and structured, good for markets and organized areas"
		WheelGraphPathConfig.WheelType.W5:
			return "Pentagon pattern - Balanced design, suitable for general exploration"
		WheelGraphPathConfig.WheelType.W6:
			return "Hexagon pattern - Classic balanced layout with good coverage"
		WheelGraphPathConfig.WheelType.W7:
			return "Heptagon pattern - Sacred geometry, suitable for spiritual or important sites"
		WheelGraphPathConfig.WheelType.W8:
			return "Octagon pattern - Ceremonial layout with rich object placement"
		WheelGraphPathConfig.WheelType.W9:
			return "Enneagon pattern - Royal/complex layout with inner rings and spoke objects"
		_:
			return "Unknown pattern"

static func get_recommended_radius(wheel_type: WheelGraphPathConfig.WheelType) -> float:
	"""Get recommended radius for each wheel type"""
	match wheel_type:
		WheelGraphPathConfig.WheelType.W4:
			return 20.0
		WheelGraphPathConfig.WheelType.W5:
			return 25.0
		WheelGraphPathConfig.WheelType.W6:
			return 30.0
		WheelGraphPathConfig.WheelType.W7:
			return 35.0
		WheelGraphPathConfig.WheelType.W8:
			return 40.0
		WheelGraphPathConfig.WheelType.W9:
			return 45.0
		_:
			return 25.0

