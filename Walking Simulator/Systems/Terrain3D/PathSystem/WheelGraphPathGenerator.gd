extends RefCounted
class_name WheelGraphPathGenerator

## SOLID-principle based wheel graph path generator
## Generates configurable wheel graphs (W4, W5, W6, etc.) with terrain following

signal path_generation_started(config: WheelGraphPathConfig)
signal path_generation_completed(vertex_count: int, path_count: int)
signal path_generation_failed(error_message: String)

var terrain_height_sampler: TerrainHeightSampler
var path_segment_factory: PathSegmentFactory
var vertex_object_placer: VertexObjectPlacer

func _init():
	"""Initialize the path generator with dependencies"""
	terrain_height_sampler = TerrainHeightSampler.new()
	path_segment_factory = PathSegmentFactory.new()
	vertex_object_placer = VertexObjectPlacer.new()

func generate_wheel_graph(config: WheelGraphPathConfig, parent_node: Node3D) -> bool:
	"""
	Generate a wheel graph path system based on configuration
	
	Args:
		config: WheelGraphPathConfig resource with all settings
		parent_node: Node3D to attach the generated paths to
	
	Returns:
		bool: True if generation successful, False otherwise
	"""
	if not config or not config.validate_configuration():
		var error = "Invalid or missing configuration"
		GameLogger.error("🚫 WheelGraphPathGenerator: %s" % error)
		path_generation_failed.emit(error)
		return false
	
	GameLogger.info("🔷 Generating wheel graph: %s" % config.get_configuration_summary())
	path_generation_started.emit(config)
	
	# Create container for this wheel graph
	var wheel_container = Node3D.new()
	wheel_container.name = "WheelGraph_%s_%s" % [
		WheelGraphPathConfig.WheelType.keys()[config.wheel_type - 4],
		WheelGraphPathConfig.SceneType.keys()[config.scene_type]
	]
	parent_node.add_child(wheel_container)
	
	var path_count = 0
	var vertex_count = config.get_vertex_count()
	
	try:
		# Generate outer vertices and their objects
		var outer_positions = config.get_outer_vertex_positions()
		_place_vertex_objects(outer_positions, config.outer_vertex_config, wheel_container, "Outer")
		
		# Generate inner vertices if configured
		if config.inner_radius > 0:
			var inner_positions = config.get_inner_vertex_positions()
			_place_vertex_objects(inner_positions, config.inner_vertex_config, wheel_container, "Inner")
		
		# Generate hub vertex
		_place_hub_vertex(config.hub_center, config.hub_vertex_config, wheel_container)
		
		# Generate path segments
		if config.create_spokes:
			path_count += _generate_spoke_paths(config, wheel_container, outer_positions)
		
		if config.create_outer_ring:
			path_count += _generate_ring_paths(config, wheel_container, outer_positions)
		
		GameLogger.info("✅ Generated wheel graph: %d vertices, %d paths" % [vertex_count, path_count])
		path_generation_completed.emit(vertex_count, path_count)
		return true
		
	except:
		var error = "Exception during wheel graph generation"
		GameLogger.error("❌ WheelGraphPathGenerator: %s" % error)
		path_generation_failed.emit(error)
		return false

func _place_vertex_objects(positions: Array[Vector3], vertex_config: VertexConfig, parent: Node3D, prefix: String):
	"""Place objects at vertex positions"""
	if not vertex_config or not vertex_config.place_objects:
		return
	
	for i in range(positions.size()):
		var pos = positions[i]
		
		# Sample terrain height if enabled
		if terrain_height_sampler:
			pos.y = terrain_height_sampler.get_terrain_height_at_position(pos)
			pos.y += vertex_config.height_offset
		
		var objects_to_place = vertex_config.get_objects_to_place()
		for j in range(objects_to_place.size()):
			var object_type = objects_to_place[j]
			var scene = vertex_config.get_random_scene_for_type(object_type)
			
			if scene:
				vertex_object_placer.place_object(
					scene, pos, vertex_config, parent, 
					"%s_Vertex_%d_%s_%d" % [prefix, i, WheelGraphPathConfig.ObjectType.keys()[object_type], j]
				)

func _place_hub_vertex(hub_pos: Vector3, vertex_config: VertexConfig, parent: Node3D):
	"""Place objects at the hub (center) vertex"""
	if not vertex_config or not vertex_config.place_objects:
		return
	
	# Sample terrain height if enabled
	if terrain_height_sampler:
		hub_pos.y = terrain_height_sampler.get_terrain_height_at_position(hub_pos)
		hub_pos.y += vertex_config.height_offset
	
	var objects_to_place = vertex_config.get_objects_to_place()
	for i in range(objects_to_place.size()):
		var object_type = objects_to_place[i]
		var scene = vertex_config.get_random_scene_for_type(object_type)
		
		if scene:
			vertex_object_placer.place_object(
				scene, hub_pos, vertex_config, parent,
				"Hub_Vertex_%s_%d" % [WheelGraphPathConfig.ObjectType.keys()[object_type], i]
			)

func _generate_spoke_paths(config: WheelGraphPathConfig, parent: Node3D, outer_positions: Array[Vector3]) -> int:
	"""Generate spoke paths from hub to outer vertices"""
	var path_count = 0
	var hub_pos = config.hub_center
	
	# Sample terrain height for hub
	if terrain_height_sampler:
		hub_pos.y = terrain_height_sampler.get_terrain_height_at_position(hub_pos)
	
	for i in range(outer_positions.size()):
		var outer_pos = outer_positions[i]
		
		# Sample terrain height for outer position
		if terrain_height_sampler:
			outer_pos.y = terrain_height_sampler.get_terrain_height_at_position(outer_pos)
		
		# Create spoke path
		var spoke_container = Node3D.new()
		spoke_container.name = "Spoke_%d" % i
		parent.add_child(spoke_container)
		
		path_segment_factory.create_path_segment(
			hub_pos, outer_pos, config, spoke_container, "Spoke_%d" % i
		)
		
		# Place objects at spoke midpoint if configured
		if config.spoke_midpoint_config and config.spoke_midpoint_config.place_objects:
			var midpoint = (hub_pos + outer_pos) / 2.0
			if terrain_height_sampler:
				midpoint.y = terrain_height_sampler.get_terrain_height_at_position(midpoint)
				midpoint.y += config.spoke_midpoint_config.height_offset
			
			_place_vertex_objects([midpoint], config.spoke_midpoint_config, spoke_container, "SpokeMid")
		
		path_count += 1
	
	return path_count

func _generate_ring_paths(config: WheelGraphPathConfig, parent: Node3D, outer_positions: Array[Vector3]) -> int:
	"""Generate ring paths connecting outer vertices"""
	var path_count = 0
	var ring_container = Node3D.new()
	ring_container.name = "OuterRing"
	parent.add_child(ring_container)
	
	for i in range(outer_positions.size()):
		var start_pos = outer_positions[i]
		var end_pos = outer_positions[(i + 1) % outer_positions.size()]  # Wrap around
		
		# Sample terrain heights
		if terrain_height_sampler:
			start_pos.y = terrain_height_sampler.get_terrain_height_at_position(start_pos)
			end_pos.y = terrain_height_sampler.get_terrain_height_at_position(end_pos)
		
		path_segment_factory.create_path_segment(
			start_pos, end_pos, config, ring_container, "Ring_%d_%d" % [i, (i + 1) % outer_positions.size()]
		)
		
		path_count += 1
	
	return path_count

func set_terrain_height_sampler(sampler: TerrainHeightSampler):
	"""Inject terrain height sampler dependency"""
	terrain_height_sampler = sampler

func set_path_segment_factory(factory: PathSegmentFactory):
	"""Inject path segment factory dependency"""
	path_segment_factory = factory

func set_vertex_object_placer(placer: VertexObjectPlacer):
	"""Inject vertex object placer dependency"""
	vertex_object_placer = placer
