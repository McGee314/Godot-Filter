extends Node

# Quick test to verify GraphFactory loading works
# This can be run as a tool script in the editor

@tool

func _ready():
	if not Engine.is_editor_hint():
		return
		
	print("=== Simple GraphFactory Test ===")
	test_factory_loading()

func test_factory_loading():
	var GraphFactory = load("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd")
	
	# Test loading a simple configuration
	print("Testing configuration loading...")
	
	var config = GraphFactory.load_graph_config(GraphFactory.GraphType.CYCLE_TRIANGLE)
	if config:
		print("✓ TriangleCycleConfig loaded successfully")
		print("  - Radius: ", config.radius)
		print("  - Vertex count: ", config.vertex_count)
	else:
		print("✗ Failed to load TriangleCycleConfig")
	
	# Test creating a graph instance
	print("Testing graph instance creation...")
	
	var graph = GraphFactory.create_graph(GraphFactory.GraphType.CYCLE_TRIANGLE)
	if graph:
		print("✓ Triangle cycle graph created successfully")
		print("  - Type: ", graph.get_class())
	else:
		print("✗ Failed to create triangle cycle graph")
	
	print("=== Test Complete ===")
