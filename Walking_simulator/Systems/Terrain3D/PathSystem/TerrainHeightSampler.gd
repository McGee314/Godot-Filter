extends RefCounted
class_name TerrainHeightSampler

## SOLID: Single Responsibility - Handles terrain height sampling
## Used by wheel graph path generator to position paths on terrain

var terrain_node: Terrain3D
var fallback_height: float = 0.0

func _init():
	"""Initialize terrain height sampler"""
	_find_terrain_node()

func _find_terrain_node():
	"""Find the Terrain3D node in the scene"""
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
		return node as Terrain3D
	
	for child in node.get_children():
		var result = _find_terrain_recursive(child)
		if result:
			return result
	
	return null

func get_terrain_height_at_position(world_pos: Vector3) -> float:
	"""
	Get terrain height at world position
	
	Args:
		world_pos: World position to sample
		
	Returns:
		float: Terrain height at position, or fallback_height if unavailable
	"""
	if not terrain_node:
		return fallback_height
	
	# Use Terrain3D's built-in height sampling
	var height = terrain_node.get_height(world_pos)
	
	# Terrain3D returns NaN for invalid positions
	if is_nan(height):
		GameLogger.debug("🔍 TerrainHeightSampler: Invalid height at %s, using fallback" % world_pos)
		return fallback_height
	
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
	
	var normal = terrain_node.get_normal(world_pos)
	
	if normal == Vector3.ZERO:
		return Vector3.UP
	
	return normal.normalized()

func sample_height_along_path(start_pos: Vector3, end_pos: Vector3, sample_count: int = 10) -> Array[float]:
	"""
	Sample terrain heights along a path between two points
	
	Args:
		start_pos: Starting position
		end_pos: Ending position
		sample_count: Number of height samples to take
		
	Returns:
		Array[float]: Array of height values along the path
	"""
	var heights: Array[float] = []
	
	if sample_count <= 0:
		return heights
	
	for i in range(sample_count):
		var t = float(i) / float(sample_count - 1) if sample_count > 1 else 0.0
		var sample_pos = start_pos.lerp(end_pos, t)
		heights.append(get_terrain_height_at_position(sample_pos))
	
	return heights

func is_terrain_available() -> bool:
	"""Check if terrain is available for height sampling"""
	return terrain_node != null

func set_fallback_height(height: float):
	"""Set fallback height when terrain is unavailable"""
	fallback_height = height
	GameLogger.debug("🔧 TerrainHeightSampler: Set fallback height to %.2f" % height)

func refresh_terrain_reference():
	"""Refresh the terrain node reference"""
	_find_terrain_node()

func get_terrain_bounds() -> AABB:
	"""Get terrain bounds if available"""
	if not terrain_node:
		return AABB()
	
	# Terrain3D doesn't expose bounds directly, so we estimate
	# This is a reasonable default for most terrains
	var size = Vector3(1000, 100, 1000)  # 1km x 1km terrain, 100m height
	var center = Vector3.ZERO
	
	return AABB(center - size/2, size)
