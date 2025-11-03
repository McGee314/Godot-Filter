extends Resource
class_name PSXAssetPack

# PSXAssetPack manages collections of PSX-style assets for different regions
# This follows SOLID principles by having a single responsibility for asset organization

@export var region_name: String = ""
@export var environment_type: String = ""

# Asset categories for different types of PSX models
@export var trees: Array[String] = []
@export var vegetation: Array[String] = []
@export var stones: Array[String] = []
@export var debris: Array[String] = []
@export var mushrooms: Array[String] = []

func _init():
	# Initialize with default values
	pass

func get_all_assets() -> Array[String]:
	"""Returns all assets in this pack as a flat array"""
	var all_assets: Array[String] = []
	all_assets.append_array(trees)
	all_assets.append_array(vegetation)
	all_assets.append_array(stones)
	all_assets.append_array(debris)
	all_assets.append_array(mushrooms)
	return all_assets

func get_assets_by_category(category: String) -> Array[String]:
	"""Returns assets for a specific category"""
	match category.to_lower():
		"trees":
			return trees
		"vegetation":
			return vegetation
		"stones":
			return stones
		"debris":
			return debris
		"mushrooms":
			return mushrooms
		_:
			return []

func get_random_asset(category: String) -> String:
	"""Returns a random asset from the specified category"""
	var assets = get_assets_by_category(category)
	if assets.size() > 0:
		return assets[randi() % assets.size()]
	return ""

func validate_assets() -> Dictionary:
	"""Validates that all referenced assets exist"""
	var results = {
		"valid": true,
		"missing": [],
		"total_assets": 0,
		"valid_assets": 0
	}
	
	var all_assets = get_all_assets()
	results.total_assets = all_assets.size()
	
	for asset_path in all_assets:
		# Try to load the asset as a scene
		var scene = load(asset_path)
		if scene:
			results.valid_assets += 1
		else:
			results.missing.append(asset_path)
			results.valid = false
	
	return results

func get_pack_info() -> Dictionary:
	"""Returns information about this asset pack"""
	return {
		"region_name": region_name,
		"environment_type": environment_type,
		"total_trees": trees.size(),
		"total_vegetation": vegetation.size(),
		"total_stones": stones.size(),
		"total_debris": debris.size(),
		"total_mushrooms": mushrooms.size(),
		"total_assets": get_all_assets().size()
	}
