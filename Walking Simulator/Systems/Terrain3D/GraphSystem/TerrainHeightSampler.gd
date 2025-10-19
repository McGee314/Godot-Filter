extends RefCounted
class_name GraphTerrainHeightSampler

## SOLID: Single Responsibility - Handles terrain height sampling
## Used by graph system to position vertices and paths on terrain

var terrain_node: Terrain3D
var fallback_height: float = 0.0

func _init():
	"""Initialize terrain height sampler"""
	GameLogger.info("🔧 TerrainHeightSampler: Initializing...")
	_find_terrain_node()

func _find_terrain_node():
	"""Find the Terrain3D node in the scene"""
	GameLogger.info("🔍 TerrainHeightSampler: Searching for Terrain3D node...")
	
	# Try to find terrain through common paths
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree:
		GameLogger.warning("⚠️ TerrainHeightSampler: No scene tree available")
		return
	
	var current_scene = scene_tree.current_scene
	if not current_scene:
		GameLogger.warning("⚠️ TerrainHeightSampler: No current scene")
		return
	
	# Search for Terrain3D node
	terrain_node = _find_terrain_recursive(current_scene)
	
	if terrain_node:
		GameLogger.info("✅ TerrainHeightSampler: Found Terrain3D at %s" % terrain_node.get_path())
	else:
		GameLogger.warning("⚠️ TerrainHeightSampler: Terrain3D not found, using fallback height")

func _find_terrain_recursive(node: Node) -> Terrain3D:
	"""Recursively search for Terrain3D node"""
	if node is Terrain3D:
		GameLogger.debug("🎯 TerrainHeightSampler: Found Terrain3D node: %s" % node.name)
		return node as Terrain3D
	
	for child in node.get_children():
		var result = _find_terrain_recursive(child)
		if result:
			return result
	
	return null

func sample_height_at_position(world_pos: Vector3) -> float:
	"""
	Sample terrain height at world position with proper error handling
	
	Args:
		world_pos: World position to sample
		
	Returns:
		float: Terrain height at position, or fallback_height if unavailable
	"""
	GameLogger.debug("📏 TerrainHeightSampler: Sampling height at %s" % world_pos)
	
	if not terrain_node:
		GameLogger.debug("⚠️ TerrainHeightSampler: No terrain node, using fallback height %.2f" % fallback_height)
		return fallback_height
	
	# Use Terrain3D's built-in height sampling through terrain data
	var terrain_data = terrain_node.get_data()
	if not terrain_data:
		GameLogger.debug("⚠️ TerrainHeightSampler: No terrain data available, using fallback height %.2f" % fallback_height)
		return fallback_height
	
	var height = terrain_data.get_height(world_pos)
	
	# Terrain3D returns NaN for invalid positions
	if is_nan(height):
		GameLogger.debug("🔍 TerrainHeightSampler: Invalid height at %s, using fallback %.2f" % [world_pos, fallback_height])
		return fallback_height
	
	GameLogger.debug("✅ TerrainHeightSampler: Height at %s = %.2f" % [world_pos, height])
	return height

func get_terrain_normal_at_position(world_pos: Vector3) -> Vector3:
	"""
	Get terrain normal at world position
	
	Args:
		world_pos: World position to sample
		
	Returns:
		Vector3: Terrain normal at position, or Vector3.UP if unavailable
	"""
	if not terrain_node:
		return Vector3.UP
	
	var terrain_data = terrain_node.get_data()
	if not terrain_data:
		return Vector3.UP
	
	var normal = terrain_data.get_normal(world_pos)
	
	if normal == Vector3.ZERO:
		return Vector3.UP
	
	return normal.normalized()

func is_terrain_available() -> bool:
	"""Check if terrain is available for height sampling"""
	var available = terrain_node != null
	GameLogger.debug("🔍 TerrainHeightSampler: Terrain available: %s" % available)
	return available

func set_fallback_height(height: float):
	"""Set fallback height when terrain is unavailable"""
	fallback_height = height
	GameLogger.info("🔧 TerrainHeightSampler: Set fallback height to %.2f" % height)

func refresh_terrain_reference():
	"""Refresh the terrain node reference"""
	GameLogger.info("🔄 TerrainHeightSampler: Refreshing terrain reference...")
	_find_terrain_node()
