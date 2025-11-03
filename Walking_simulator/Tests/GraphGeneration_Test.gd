extends Node3D

# Test script to generate and visualize graphs in a 3D scene

var GraphFactory = preload("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd")

func _ready():
	print("=== Graph Generation Test Starting ===")
	test_graph_generation()

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space key
		clear_graphs()
		test_graph_generation()
	elif event.is_action_pressed("ui_cancel"):  # Escape key
		get_tree().quit()

func clear_graphs():
	# Remove any existing graph nodes
	for child in get_children():
		if child.name.begins_with("Graph_"):
			child.queue_free()

func test_graph_generation():
	print("Testing graph generation and visualization...")
	
	# Test different graph types at different positions
	var test_configs = [
		{"type": GraphFactory.GraphType.CYCLE_TRIANGLE, "position": Vector3(-20, 0, -20), "name": "Triangle_Cycle"},
		{"type": GraphFactory.GraphType.CYCLE_SQUARE, "position": Vector3(0, 0, -20), "name": "Square_Cycle"},
		{"type": GraphFactory.GraphType.CYCLE_HEXAGON, "position": Vector3(20, 0, -20), "name": "Hexagon_Cycle"},
		{"type": GraphFactory.GraphType.WHEEL_TRIANGLE, "position": Vector3(-20, 0, 0), "name": "Triangle_Wheel"},
		{"type": GraphFactory.GraphType.WHEEL_SQUARE, "position": Vector3(0, 0, 0), "name": "Square_Wheel"},
		{"type": GraphFactory.GraphType.WHEEL_HEXAGON, "position": Vector3(20, 0, 0), "name": "Hexagon_Wheel"}
	]
	
	for config in test_configs:
		await create_test_graph(config.type, config.position, config.name)
		await get_tree().process_frame  # Wait a frame between generations

func create_test_graph(graph_type: GraphFactory.GraphType, position: Vector3, graph_name: String):
	print("Creating graph: ", graph_name, " at position: ", position)
	
	try:
		# Create the graph using GraphFactory
		var graph = GraphFactory.create_graph(graph_type)
		if not graph:
			print("  ✗ Failed to create graph instance")
			return
		
		# Create a container node for the graph
		var graph_container = Node3D.new()
		graph_container.name = "Graph_" + graph_name
		graph_container.position = position
		add_child(graph_container)
		
		# Initialize the graph (this should set up internal state)
		var success = await graph.initialize()
		if not success:
			print("  ✗ Failed to initialize graph")
			graph_container.queue_free()
			return
		
		# Generate the graph (this should create vertices and edges)
		success = await graph.generate_graph()
		if not success:
			print("  ✗ Failed to generate graph")
			graph_container.queue_free()
			return
		
		print("  ✓ Graph generated successfully")
		print("    - Vertices: ", graph.vertices.size())
		print("    - Edges: ", graph.edges.size())
		
		# Try to create visual representation
		if graph.has_method("_create_visual_graph"):
			graph._create_visual_graph()
			print("  ✓ Visual representation created")
		
		# Add the graph node to our container
		graph_container.add_child(graph)
		
	except:
		print("  ✗ Exception occurred during graph creation for: ", graph_name)

func _on_ready_complete():
	print("=== Graph Generation Test Complete ===")
	print("Press SPACE to regenerate graphs")
	print("Press ESCAPE to quit")
