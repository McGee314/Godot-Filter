extends Node

# Test GraphFactory directly to see what's wrong

func _ready():
	print("🔬 === GRAPHFACTORY DIRECT TEST ===")
	await get_tree().process_frame
	test_graphfactory_loading()

func test_graphfactory_loading():
	print("🔬 Testing GraphFactory loading...")
	
	# Load GraphFactory
	var GraphFactory = preload("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd")
	print("🔬 GraphFactory loaded: %s" % GraphFactory)
	
	# Test enum values
	print("🔬 Testing GraphType enum...")
	print("🔬 WHEEL_PENTAGON value: %s" % GraphFactory.GraphType.WHEEL_PENTAGON)
	
	# Test configuration loading
	print("🔬 Testing configuration loading...")
	var config = GraphFactory.load_graph_config(GraphFactory.GraphType.WHEEL_PENTAGON)
	if config:
		print("🔬 ✅ Config loaded: %s" % config.get_class())
		print("🔬   - Script: %s" % (config.get_script().resource_path if config.get_script() else "None"))
	else:
		print("🔬 ❌ Config loading failed")
		return
	
	# Test wheel graph creation
	print("🔬 Testing create_wheel_graph...")
	var wheel_graph = GraphFactory.create_wheel_graph(5, Vector3.ZERO, 25.0)
	if wheel_graph:
		print("🔬 ✅ Wheel graph created: %s" % wheel_graph.get_class())
		print("🔬   - Script: %s" % (wheel_graph.get_script().resource_path if wheel_graph.get_script() else "None"))
		print("🔬   - Has generate_graph method: %s" % wheel_graph.has_method("generate_graph"))
	else:
		print("🔬 ❌ Wheel graph creation failed")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_8:
		print("🔬 Manual GraphFactory test")
		test_graphfactory_loading()
