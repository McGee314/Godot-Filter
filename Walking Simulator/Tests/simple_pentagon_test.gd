extends Node3D

# Simple direct Pentagon test - should definitely work
# Add this as a child node to test Pentagon generation

func _ready():
	print("🧪 === SIMPLE PENTAGON TEST ===")
	await get_tree().process_frame
	await get_tree().create_timer(2.0).timeout
	print("🧪 Starting Pentagon test after 2 second delay...")
	test_pentagon_generation()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_0:
		print("🧪 Manual Pentagon test triggered")
		test_pentagon_generation()

func test_pentagon_generation():
	print("🧪 Testing direct Pentagon wheel graph generation...")
	
	# Load GraphFactory
	var GraphFactory = preload("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd")
	print("🧪 GraphFactory loaded")
	
	# Test configuration loading first
	print("🧪 Testing Pentagon configuration loading...")
	var config = GraphFactory.load_graph_config(GraphFactory.GraphType.WHEEL_PENTAGON)
	if config:
		print("🧪 ✅ Pentagon config loaded: %s" % config.get_class())
		print("🧪   - Vertex count: %d" % config.vertex_count)
		print("🧪   - Radius: %f" % config.radius)
	else:
		print("🧪 ❌ Failed to load Pentagon config")
		return
	
	# Create Pentagon wheel graph
	var center_pos = Vector3(0, 0, 0)
	print("🧪 Creating Pentagon wheel graph at %s..." % center_pos)
	var pentagon_graph = GraphFactory.create_wheel_graph(5, center_pos, 25.0)
	
	if pentagon_graph:
		print("🧪 ✅ Pentagon graph created: %s" % pentagon_graph.get_class())
		
		# Generate in scene
		print("🧪 Generating Pentagon graph in scene...")
		var success = pentagon_graph.generate_graph(self)
		
		if success:
			print("🧪 🎉 Pentagon wheel graph generated successfully!")
			print("🧪 Check scene for Pentagon paths around position %s" % center_pos)
		else:
			print("🧪 ❌ Pentagon graph generation failed")
	else:
		print("🧪 ❌ Failed to create Pentagon graph")
