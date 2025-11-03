class_name ShaderManager
extends Node

## Centralized shader management system following SOLID principles
## Manages creation, loading, and application of shaders across the project

signal shader_loaded(shader_name: String)
signal shader_applied(object: Node3D, shader_name: String)

# Shader cache for performance
var _shader_cache: Dictionary = {}
var _material_cache: Dictionary = {}

# Shader resource paths
const SHADER_PATHS = {
	"ocean_waves": "res://Systems/Shaders/OceanWaveShader.gdshader",
	"terrain_blend": "res://Systems/Shaders/TerrainBlendShader.gdshader",
	"simple_terrain": "res://Systems/Shaders/SimpleTerrainShader.gdshader",
	"psx_terrain_height": "res://Systems/Shaders/PSXTerrainHeightShader.gdshader",
	"interactive_glow": "res://Systems/Shaders/InteractiveGlowShader.gdshader",
	"atmospheric_fog": "res://Systems/Shaders/AtmosphericFogShader.gdshader"
}

func _ready():
	GameLogger.info("🎨 ShaderManager initialized")

## Load a shader by name with caching
func load_shader(shader_name: String) -> Shader:
	if shader_name in _shader_cache:
		GameLogger.info("📦 Using cached shader: " + shader_name)
		return _shader_cache[shader_name]
	
	if shader_name not in SHADER_PATHS:
		GameLogger.error("❌ Unknown shader: " + shader_name)
		return null
	
	var shader_path = SHADER_PATHS[shader_name]
	if not ResourceLoader.exists(shader_path):
		GameLogger.warning("⚠️ Shader file not found: " + shader_path)
		return null
	
	var shader = load(shader_path) as Shader
	if shader:
		_shader_cache[shader_name] = shader
		shader_loaded.emit(shader_name)
		GameLogger.info("✅ Loaded shader: " + shader_name)
	else:
		GameLogger.error("❌ Failed to load shader: " + shader_name)
	
	return shader

## Create a material with shader and parameters
func create_material(shader_name: String, parameters: Dictionary = {}) -> ShaderMaterial:
	var cache_key = shader_name + "_" + str(parameters.hash())
	
	if cache_key in _material_cache:
		GameLogger.info("📦 Using cached material: " + cache_key)
		return _material_cache[cache_key]
	
	var shader = load_shader(shader_name)
	if not shader:
		return null
	
	var material = ShaderMaterial.new()
	material.shader = shader
	
	# Apply parameters
	for param_name in parameters:
		var param_value = parameters[param_name]
		material.set_shader_parameter(param_name, param_value)
		GameLogger.info("🔧 Set shader parameter: " + param_name + " = " + str(param_value))
	
	_material_cache[cache_key] = material
	GameLogger.info("✅ Created material: " + cache_key)
	return material

## Apply shader to a 3D object
func apply_shader_to_object(object: Node3D, shader_name: String, parameters: Dictionary = {}) -> bool:
	if not object:
		GameLogger.error("❌ Cannot apply shader to null object")
		return false
	
	var material = create_material(shader_name, parameters)
	if not material:
		return false
	
	if object is MeshInstance3D:
		var mesh_instance = object as MeshInstance3D
		mesh_instance.material_override = material
	elif object.has_method("set_material_override"):
		object.set_material_override(material)
	else:
		GameLogger.warning("⚠️ Object doesn't support material override: " + object.name)
		return false
	
	shader_applied.emit(object, shader_name)
	GameLogger.info("✅ Applied shader '" + shader_name + "' to: " + object.name)
	return true

## Update shader parameters on existing material
func update_shader_parameters(object: Node3D, parameters: Dictionary):
	if not object:
		return
	
	var material: ShaderMaterial = null
	
	if object is MeshInstance3D:
		material = (object as MeshInstance3D).material_override as ShaderMaterial
	elif object.has_method("get_material_override"):
		material = object.get_material_override() as ShaderMaterial
	
	if not material or not material.shader:
		GameLogger.warning("⚠️ No shader material found on object: " + object.name)
		return
	
	for param_name in parameters:
		var param_value = parameters[param_name]
		material.set_shader_parameter(param_name, param_value)
		GameLogger.info("🔧 Updated parameter: " + param_name + " = " + str(param_value))

## Get available shader names
func get_available_shaders() -> Array[String]:
	return SHADER_PATHS.keys() as Array[String]

## Clear caches (useful for development)
func clear_cache():
	_shader_cache.clear()
	_material_cache.clear()
	GameLogger.info("🧹 Shader caches cleared")

## Preload commonly used shaders
func preload_common_shaders():
	GameLogger.info("⚡ Preloading common shaders...")
	for shader_name in ["ocean_waves", "interactive_glow"]:
		load_shader(shader_name)
	GameLogger.info("✅ Common shaders preloaded")
