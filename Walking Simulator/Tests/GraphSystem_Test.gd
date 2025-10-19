extends Node

# Simple test script to verify GraphFactory functionality
# Place this in the main scene and run to test graph generation

func _ready():
	print("=== GraphSystem Test Starting ===")
	test_graph_factory_creation()

func test_graph_factory_creation():
	# Test if GraphFactory can load configurations
	print("Testing GraphFactory configuration loading...")
	
	var factory = preload("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd")
	
	# Test each graph type
	var test_types = [
		factory.GraphType.CYCLE_TRIANGLE,
		factory.GraphType.CYCLE_SQUARE, 
		factory.GraphType.CYCLE_PENTAGON,
		factory.GraphType.CYCLE_HEXAGON,
		factory.GraphType.CYCLE_HEPTAGON,
		factory.GraphType.CYCLE_OCTAGON,
		factory.GraphType.WHEEL_TRIANGLE,
		factory.GraphType.WHEEL_SQUARE,
		factory.GraphType.WHEEL_PENTAGON,
		factory.GraphType.WHEEL_HEXAGON,
		factory.GraphType.WHEEL_HEPTAGON,
		factory.GraphType.WHEEL_OCTAGON
	]
	
	for graph_type in test_types:
		print("Testing graph type: ", graph_type)
		
		# Try to load the configuration
		var config = factory.load_graph_config(graph_type)
		if config:
			print("  ✓ Configuration loaded successfully")
			print("  - Radius: ", config.radius)
			print("  - Vertex count: ", config.vertex_count)
			print("  - Path width: ", config.path_width)
		else:
			print("  ✗ Failed to load configuration")
			continue
		
		# Try to create the graph
		var graph = factory.create_graph(graph_type)
		if graph:
			print("  ✓ Graph instance created successfully")
			print("  - Graph class: ", graph.get_class())
		else:
			print("  ✗ Failed to create graph instance")
		
		print("  ---")
	
	print("=== GraphSystem Test Complete ===")
