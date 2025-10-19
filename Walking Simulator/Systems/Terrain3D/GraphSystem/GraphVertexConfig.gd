extends Resource
class_name GraphVertexConfig

## Configuration for objects placed at graph vertices
## Follows SOLID principles - Single Responsibility for vertex object configuration

@export_group("Object Placement")
@export var place_objects: bool = true
@export var object_types: Array[BaseGraphConfig.ObjectType] = []
@export var spawn_probability: float = 1.0  # 0.0 to 1.0
@export var max_objects_per_vertex: int = 1

@export_group("Object Properties")
@export var object_scale: Vector3 = Vector3.ONE
@export var scale_variation: float = 0.0  # Random scale variation (0.0 to 1.0)
@export var rotation_random: bool = false
@export var rotation_range: float = 360.0  # Degrees
@export var height_offset: float = 0.0

@export_group("Asset References")
@export var npc_scenes: Array[PackedScene] = []
@export var artifact_scenes: Array[PackedScene] = []
@export var item_scenes: Array[PackedScene] = []
@export var marker_scenes: Array[PackedScene] = []
@export var decoration_scenes: Array[PackedScene] = []

@export_group("Cultural Theming")
@export var cultural_filter: Array[String] = []  # e.g., ["Indonesian", "Papuan", "Traditional"]
@export var scene_specific: bool = false  # Use scene-specific assets only

func get_random_scene_for_type(object_type: BaseGraphConfig.ObjectType) -> PackedScene:
	"""Get a random scene for the specified object type (SOLID: Single Responsibility)"""
	var scenes: Array[PackedScene] = []
	
	match object_type:
		BaseGraphConfig.ObjectType.NPC:
			scenes = npc_scenes
		BaseGraphConfig.ObjectType.ARTIFACT:
			scenes = artifact_scenes
		BaseGraphConfig.ObjectType.ITEM:
			scenes = item_scenes
		BaseGraphConfig.ObjectType.MARKER:
			scenes = marker_scenes
		BaseGraphConfig.ObjectType.DECORATION:
			scenes = decoration_scenes
	
	if scenes.is_empty():
		GameLogger.debug("🔍 GraphVertexConfig: No scenes available for object type %d" % object_type)
		return null
	
	return scenes[randi() % scenes.size()]

func should_place_object() -> bool:
	"""Determine if an object should be placed based on probability (SOLID: Single Responsibility)"""
	return randf() < spawn_probability

func get_random_scale() -> Vector3:
	"""Get a random scale with variation (SOLID: Single Responsibility)"""
	if scale_variation <= 0:
		return object_scale
	
	var variation = 1.0 + (randf() - 0.5) * 2.0 * scale_variation
	return object_scale * variation

func get_random_rotation() -> float:
	"""Get a random rotation in radians (SOLID: Single Responsibility)"""
	if not rotation_random:
		return 0.0
	
	return deg_to_rad(randf() * rotation_range - rotation_range / 2.0)

func get_objects_to_place() -> Array[BaseGraphConfig.ObjectType]:
	"""Get list of object types to place at this vertex (SOLID: Single Responsibility)"""
	var objects_to_place: Array[BaseGraphConfig.ObjectType] = []
	
	if not place_objects or object_types.is_empty():
		return objects_to_place
	
	# Shuffle and take up to max_objects_per_vertex
	var shuffled_types = object_types.duplicate()
	shuffled_types.shuffle()
	
	var count = min(max_objects_per_vertex, shuffled_types.size())
	for i in range(count):
		if should_place_object():
			objects_to_place.append(shuffled_types[i])
	
	return objects_to_place

func validate_configuration() -> bool:
	"""Validate the vertex configuration (SOLID: Single Responsibility)"""
	if spawn_probability < 0 or spawn_probability > 1:
		GameLogger.graph_error("❌ GraphVertexConfig: spawn_probability must be between 0 and 1")
		return false
	
	if max_objects_per_vertex < 0:
		GameLogger.graph_error("❌ GraphVertexConfig: max_objects_per_vertex must be non-negative")
		return false
	
	if scale_variation < 0 or scale_variation > 1:
		GameLogger.graph_error("❌ GraphVertexConfig: scale_variation must be between 0 and 1")
		return false
	
	return true
