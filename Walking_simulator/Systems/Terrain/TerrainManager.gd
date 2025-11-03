extends Node

# TerrainManager is responsible for preparing and managing terrain-related resources.
# Phase 1: Basic terrain setup with PSX asset integration

class_name TerrainManager

var heightmap_path: String = ""
var terrain_material: Material
var psx_asset_pack: PSXAssetPack
var terrain_node: Node3D

func _ready():
	# Initialize terrain manager
	GameLogger.info("Initializing terrain system")
	pass

func configure_heightmap(path: String) -> void:
	heightmap_path = path
	GameLogger.info("Heightmap configured: " + path)

func set_material(material: Material) -> void:
	terrain_material = material
	GameLogger.info("Terrain material set")

func set_psx_asset_pack(asset_pack: PSXAssetPack) -> void:
	psx_asset_pack = asset_pack
	GameLogger.info("PSX asset pack set for region: " + asset_pack.region_name)

func build_terrain() -> bool:
	# Phase 1: Basic terrain validation
	if heightmap_path == "":
		GameLogger.warning("No heightmap configured")
		return false
	
	if not psx_asset_pack:
		GameLogger.warning("No PSX asset pack configured")
		return false
	
	# Validate PSX assets
	var validation = psx_asset_pack.validate_assets()
	if not validation.valid:
		GameLogger.error("PSX asset validation failed: " + str(validation.missing))
		return false
	
	GameLogger.info("Terrain build validation passed")
	return true

func get_status() -> Dictionary:
	var status = {
		"heightmap_path": heightmap_path,
		"has_material": terrain_material != null,
		"has_psx_pack": psx_asset_pack != null
	}
	
	if psx_asset_pack:
		status["psx_pack_info"] = psx_asset_pack.get_pack_info()
	
	return status

func get_psx_assets_by_category(category: String) -> Array[String]:
	"""Get PSX assets for a specific category"""
	if psx_asset_pack:
		return psx_asset_pack.get_assets_by_category(category)
	return []

func get_random_psx_asset(category: String) -> String:
	"""Get a random PSX asset from the specified category"""
	if psx_asset_pack:
		return psx_asset_pack.get_random_asset(category)
	return ""
