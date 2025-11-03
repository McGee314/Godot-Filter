extends Terrain3DBaseController
class_name Terrain3DPapuaController

## Papua-specific Terrain3D Controller
## Implements the base controller for Papua region terrain

var papua_asset_pack: Resource
var asset_placer: Node3D

func _get_terrain_type() -> String:
	return "Papua"

func _get_asset_pack_path() -> String:
	return "res://Assets/Terrain/Papua/psx_assets.tres"

func _load_asset_pack() -> bool:
	"""Load Papua-specific asset pack"""
	papua_asset_pack = load(_get_asset_pack_path())
	if not papua_asset_pack:
		GameLogger.error("❌ Failed to load Papua asset pack")
		return false
	
	if is_debug_enabled("terrain"):
		GameLogger.info("✅ Loaded Papua asset pack: " + papua_asset_pack.region_name)
		GameLogger.info("🌿 Environment type: " + papua_asset_pack.environment_type)
	
	return true

func _setup_terrain_system():
	"""Setup Papua-specific terrain systems"""
	# Create asset placer
	asset_placer = Node3D.new()
	asset_placer.name = "PapuaAssetPlacer"
	add_child(asset_placer)
	
	# Store reference to asset pack
	asset_placer.set_meta("asset_pack", papua_asset_pack)
	
	# Setup Terrain3D with demo assets
	_setup_terrain3d_with_demo_assets()

func _place_assets_around_position(center: Vector3, radius: float) -> int:
	"""Place Papua-specific assets around position"""
	if not papua_asset_pack:
		GameLogger.error("❌ No Papua asset pack loaded")
		return 0
	
	var count = 0
	
	# Place different types of assets
	count += _place_tropical_vegetation(center, radius)
	count += _place_tropical_trees(center, radius)
	count += _place_forest_floor_assets(center, radius)
	
	return count

func _place_tropical_vegetation(center: Vector3, radius: float) -> int:
	"""Place tropical vegetation"""
	GameLogger.info("🌿 Placing tropical vegetation at %s (radius: %.1f)" % [center, radius])
	
	var vegetation = _filter_glb(papua_asset_pack.vegetation)
	if vegetation.size() == 0:
		GameLogger.warning("⚠️ No vegetation assets available")
		return 0
	
	var container = Node3D.new()
	container.name = "TropicalVegetation"
	asset_placer.add_child(container)
	
	var count = 0
	for i in range(30):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		if _is_position_on_path(pos):
			continue
		
		var terrain_height = get_terrain_height_at_position(pos)
		
		if vegetation.size() > 0:
			var vegetation_path = vegetation[randi() % vegetation.size()]
			var instance = _instantiate_glb(vegetation_path)
			if instance != null:
				container.add_child(instance)
				instance.global_position = Vector3(pos.x, terrain_height, pos.z)
				instance.rotation.y = randf() * TAU
				instance.scale = Vector3(randf_range(0.6, 1.2), randf_range(0.6, 1.2), randf_range(0.6, 1.2))
				count += 1
				terrain_stats["vegetation"] += 1
	
	GameLogger.info("✅ Placed %d tropical vegetation" % count)
	return count

func _place_tropical_trees(center: Vector3, radius: float) -> int:
	"""Place tropical trees"""
	GameLogger.info("🌴 Placing tropical trees at %s (radius: %.1f)" % [center, radius])
	
	var trees = _filter_glb(papua_asset_pack.trees)
	if trees.size() == 0:
		GameLogger.warning("⚠️ No tree assets available")
		return 0
	
	var container = Node3D.new()
	container.name = "TropicalTrees"
	asset_placer.add_child(container)
	
	var count = 0
	for i in range(25):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		if _is_position_on_path(pos):
			continue
		
		var terrain_height = get_terrain_height_at_position(pos)
		
		if trees.size() > 0:
			var tree_path = trees[randi() % trees.size()]
			var instance = _instantiate_glb(tree_path)
			if instance != null:
				container.add_child(instance)
				instance.global_position = Vector3(pos.x, terrain_height, pos.z)
				instance.rotation.y = randf() * TAU
				instance.scale = Vector3(randf_range(0.8, 1.3), randf_range(0.8, 1.3), randf_range(0.8, 1.3))
				count += 1
				terrain_stats["trees"] += 1
	
	GameLogger.info("✅ Placed %d tropical trees" % count)
	return count

func _place_forest_floor_assets(center: Vector3, radius: float) -> int:
	"""Place forest floor assets"""
	GameLogger.info("🪨 Placing forest floor assets at %s (radius: %.1f)" % [center, radius])
	
	var rocks = _filter_glb(papua_asset_pack.stones)
	var debris = _filter_glb(papua_asset_pack.debris)
	
	var container = Node3D.new()
	container.name = "ForestFloorAssets"
	asset_placer.add_child(container)
	
	var count = 0
	for i in range(20):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		if _is_position_on_path(pos):
			continue
		
		var terrain_height = get_terrain_height_at_position(pos)
		
		if randf() < 0.7 and rocks.size() > 0:
			var rock_path = rocks[randi() % rocks.size()]
			var instance = _instantiate_glb(rock_path)
			if instance != null:
				container.add_child(instance)
				instance.global_position = Vector3(pos.x, terrain_height, pos.z)
				instance.rotation.y = randf() * TAU
				instance.scale = Vector3(randf_range(0.7, 1.1), randf_range(0.7, 1.1), randf_range(0.7, 1.1))
				count += 1
				terrain_stats["stones"] += 1
		elif debris.size() > 0:
			var debris_path = debris[randi() % debris.size()]
			var instance = _instantiate_glb(debris_path)
			if instance != null:
				container.add_child(instance)
				instance.global_position = Vector3(pos.x, terrain_height, pos.z)
				instance.rotation.y = randf() * TAU
				instance.scale = Vector3(randf_range(0.5, 0.9), randf_range(0.5, 0.9), randf_range(0.5, 0.9))
				count += 1
				terrain_stats["debris"] += 1
	
	GameLogger.info("✅ Placed %d forest floor assets" % count)
	return count

func _clear_asset_containers() -> int:
	"""Clear all Papua asset containers"""
	if not asset_placer:
		return 0
	
	var count = 0
	var to_remove: Array[Node] = []
	for child in asset_placer.get_children():
		to_remove.append(child)
	
	for node in to_remove:
		if node.get_parent():
			node.get_parent().remove_child(node)
			node.queue_free()
			count += 1
	
	GameLogger.info("✅ Cleared %d Papua assets" % count)
	return count

# Helper methods
func _filter_glb(paths: Array) -> Array[String]:
	"""Filter array to only include GLB files from Shared directory"""
	var out: Array[String] = []
	for p in paths:
		if typeof(p) == TYPE_STRING:
			var sp: String = p
			sp = sp.replace("\\", "/")
			if sp.to_lower().ends_with(".glb") and sp.begins_with(_get_shared_assets_root()):
				out.append(sp)
	return out

func _instantiate_glb(path: String) -> Node3D:
	"""Instantiate a GLB file"""
	var file_check = FileAccess.open(path, FileAccess.READ)
	if not file_check:
		GameLogger.error("❌ File not found: %s" % path)
		return null
	file_check.close()
	
	var scene := load(path)
	if scene == null:
		GameLogger.error("❌ Failed to load GLB: %s" % path)
		return null
	
	var node: Node = scene.instantiate()
	if node is Node3D:
		return node as Node3D
	return null

func _is_position_on_path(world_pos: Vector3, _path_width: float = 8.0) -> bool:
	"""Check if position is on any paths"""
	var path_container = get_node_or_null("HexagonPaths")
	if not path_container:
		return false
	
	for i in range(path_container.get_child_count()):
		var path_segment = path_container.get_child(i)
		if not path_segment is MeshInstance3D:
			continue
		
		var path_pos = path_segment.global_position
		var path_rotation = path_segment.global_rotation
		
		var path_mesh = path_segment.mesh as BoxMesh
		if not path_mesh:
			continue
		
		var path_size = path_mesh.size
		var half_width = path_size.x / 2.0
		var half_length = path_size.z / 2.0
		
		var local_pos = world_pos - path_pos
		local_pos = local_pos.rotated(Vector3.UP, -path_rotation.y)
		
		if abs(local_pos.x) <= half_width and abs(local_pos.z) <= half_length:
			return true
	
	return false

func _setup_terrain3d_with_demo_assets():
	"""Setup Terrain3D with demo assets"""
	GameLogger.info("🏔️ Setting up Terrain3D with demo assets...")
	
	if not terrain3d_node:
		GameLogger.error("❌ Terrain3D node not found")
		return
	
	GameLogger.info("✅ Found Terrain3D node: %s" % terrain3d_node.name)
	
	if terrain3d_node.data_directory == "res://demo/data":
		GameLogger.info("✅ Terrain3D using demo data - terrain should be visible!")
	
	if terrain3d_node.has_method("reload"):
		GameLogger.info("🔄 Reloading Terrain3D data...")
		terrain3d_node.reload()
	
	await get_tree().process_frame
	GameLogger.info("✅ Terrain3D setup complete")
