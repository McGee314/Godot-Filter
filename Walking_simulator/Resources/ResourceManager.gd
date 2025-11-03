class_name ResourceManager
extends RefCounted

## Central Resource Manager
## Provides easy access to organized resource files with consistent paths

# Resource path constants
const CAMERA_SCENES = "res://Resources/Camera/Scenes/"
const CAMERA_PRESETS = "res://Resources/Camera/Presets/"
const ITEMS_CULTURAL = "res://Resources/Items/Cultural/"
const ITEMS_GEOLOGICAL = "res://Resources/Items/Geological/"
const ITEMS_RECIPES = "res://Resources/Items/Recipes/"
const ITEMS_TOOLS = "res://Resources/Items/Tools/"
const MATERIALS_TERRAIN = "res://Resources/Materials/Terrain/"
const MATERIALS_OBJECTS = "res://Resources/Materials/Objects/"
const MATERIALS_UI = "res://Resources/Materials/UI/"
const THEMES = "res://Resources/Themes/"
const TERRAIN_PAPUA = "res://Resources/Terrain/Papua/"
const TERRAIN_TAMBORA = "res://Resources/Terrain/Tambora/"
const TERRAIN_SHARED = "res://Resources/Terrain/Shared/"
const SCENES = "res://Resources/Scenes/"
const NPCS = "res://Resources/NPCs/"
const INPUT = "res://Resources/Input/"
const SETTINGS = "res://Resources/Settings/"
const AUDIO = "res://Resources/Audio/"

# Camera resource loading
static func load_camera_config(scene_name: String) -> CameraSceneConfig:
	"""Load camera configuration for a specific scene"""
	var path = CAMERA_SCENES + scene_name + "CameraConfig.tres"
	if ResourceLoader.exists(path):
		return load(path) as CameraSceneConfig
	else:
		GameLogger.warning("Camera config not found: %s" % path)
		return null

static func load_camera_preset(preset_name: String) -> CameraSceneConfig:
	"""Load camera preset configuration"""
	var path = CAMERA_PRESETS + preset_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path) as CameraSceneConfig
	else:
		GameLogger.warning("Camera preset not found: %s" % path)
		return null

# Item resource loading
static func load_cultural_item(item_name: String) -> Resource:
	"""Load cultural item data"""
	var path = ITEMS_CULTURAL + item_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		GameLogger.warning("Cultural item not found: %s" % path)
		return null

static func load_geological_item(item_name: String) -> Resource:
	"""Load geological item data"""
	var path = ITEMS_GEOLOGICAL + item_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		GameLogger.warning("Geological item not found: %s" % path)
		return null

static func load_recipe(recipe_name: String) -> Resource:
	"""Load recipe data"""
	var path = ITEMS_RECIPES + recipe_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		GameLogger.warning("Recipe not found: %s" % path)
		return null

static func load_tool(tool_name: String) -> Resource:
	"""Load tool data"""
	var path = ITEMS_TOOLS + tool_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		GameLogger.warning("Tool not found: %s" % path)
		return null

# Material resource loading
static func load_terrain_material(material_name: String) -> Material:
	"""Load terrain material"""
	var path = MATERIALS_TERRAIN + material_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path) as Material
	else:
		GameLogger.warning("Terrain material not found: %s" % path)
		return null

static func load_object_material(material_name: String) -> Material:
	"""Load object material"""
	var path = MATERIALS_OBJECTS + material_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path) as Material
	else:
		GameLogger.warning("Object material not found: %s" % path)
		return null

static func load_ui_material(material_name: String) -> Material:
	"""Load UI material"""
	var path = MATERIALS_UI + material_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path) as Material
	else:
		GameLogger.warning("UI material not found: %s" % path)
		return null

# Theme resource loading
static func load_theme(theme_name: String) -> Theme:
	"""Load UI theme"""
	var path = THEMES + theme_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path) as Theme
	else:
		GameLogger.warning("Theme not found: %s" % path)
		return null

# Terrain resource loading
static func load_papua_terrain(file_name: String) -> Resource:
	"""Load Papua terrain data"""
	var path = TERRAIN_PAPUA + file_name + ".res"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		GameLogger.warning("Papua terrain file not found: %s" % path)
		return null

# Utility functions
static func get_all_camera_configs() -> Array[String]:
	"""Get list of all available camera configuration names"""
	var configs: Array[String] = []
	var dir = DirAccess.open(CAMERA_SCENES)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with("CameraConfig.tres"):
				var config_name = file_name.replace("CameraConfig.tres", "")
				configs.append(config_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return configs

static func get_all_themes() -> Array[String]:
	"""Get list of all available themes"""
	var themes: Array[String] = []
	var dir = DirAccess.open(THEMES)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var theme_name = file_name.replace(".tres", "")
				themes.append(theme_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return themes

static func resource_exists(category: String, resource_name: String) -> bool:
	"""Check if a resource exists in a specific category"""
	var path = ""
	match category.to_lower():
		"camera":
			path = CAMERA_SCENES + resource_name + "CameraConfig.tres"
		"theme":
			path = THEMES + resource_name + ".tres"
		"material":
			path = MATERIALS_OBJECTS + resource_name + ".tres"
		"cultural":
			path = ITEMS_CULTURAL + resource_name + ".tres"
		"geological":
			path = ITEMS_GEOLOGICAL + resource_name + ".tres"
		"recipe":
			path = ITEMS_RECIPES + resource_name + ".tres"
		"tool":
			path = ITEMS_TOOLS + resource_name + ".tres"
	
	return ResourceLoader.exists(path)

static func get_resource_info() -> Dictionary:
	"""Get information about the resource organization"""
	return {
		"camera_configs": get_all_camera_configs(),
		"themes": get_all_themes(),
		"base_paths": {
			"camera_scenes": CAMERA_SCENES,
			"items_cultural": ITEMS_CULTURAL,
			"items_geological": ITEMS_GEOLOGICAL,
			"items_recipes": ITEMS_RECIPES,
			"items_tools": ITEMS_TOOLS,
			"materials_terrain": MATERIALS_TERRAIN,
			"materials_objects": MATERIALS_OBJECTS,
			"themes": THEMES,
			"terrain_papua": TERRAIN_PAPUA
		}
	}
