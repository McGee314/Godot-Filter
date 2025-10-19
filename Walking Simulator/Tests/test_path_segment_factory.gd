extends Node

# Test to verify PathSegmentFactory class name resolution

func _ready():
	print("=== PathSegmentFactory Class Resolution Test ===")
	test_class_resolution()

func test_class_resolution():
	print("Testing GraphPathSegmentFactory instantiation...")
	
	# Try to create the GraphSystem version
	var graph_factory = GraphPathSegmentFactory.new()
	if graph_factory:
		print("✓ GraphPathSegmentFactory created successfully")
		print("  - Class: ", graph_factory.get_class())
	else:
		print("✗ Failed to create GraphPathSegmentFactory")
	
	# Test if we can call the function with correct parameters
	print("Testing function signature...")
	var config = BaseGraphConfig.new()
	config.path_width = 2.0
	config.path_height = 0.2
	config.path_color = Color.BROWN
	
	var test_node = Node3D.new()
	add_child(test_node)
	
	var result = graph_factory.create_path_segment(
		Vector3.ZERO, 
		Vector3(10, 0, 0), 
		config, 
		test_node, 
		"test_segment"
	)
	
	if result:
		print("✓ create_path_segment function works correctly")
	else:
		print("✗ create_path_segment function failed")
	
	print("=== Test Complete ===")
