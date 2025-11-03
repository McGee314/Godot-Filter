extends Node

# Direct test of GraphSystemController to bypass any class loading issues

func _ready():
	print("🧪 === DIRECT GRAPH SYSTEM TEST ===")
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	test_direct_graph_creation()

func test_direct_graph_creation():
	print("🧪 Testing direct GraphSystemController creation...")
	
	# Load the class directly
	var GraphSystemControllerClass = preload("res://Systems/Terrain3D/GraphSystem/GraphSystemController.gd")
	var graph_controller = GraphSystemControllerClass.new()
	
	print("🧪 Created controller: %s" % graph_controller.get_class())
	print("🧪 Controller script: %s" % (graph_controller.get_script().resource_path if graph_controller.get_script() else "None"))
	print("🧪 Has generate_wheel_graph: %s" % graph_controller.has_method("generate_wheel_graph"))
	
	# Add to scene tree
	add_child(graph_controller)
	await get_tree().process_frame
	
	print("🧪 After adding to scene tree:")
	print("🧪 Controller class: %s" % graph_controller.get_class())
	
	# Try to call the method
	if graph_controller.has_method("generate_wheel_graph"):
		print("🧪 Calling generate_wheel_graph directly...")
		var result = graph_controller.generate_wheel_graph(5, Vector3(0, 0, 0), 25.0)
		print("🧪 Direct call result: %s" % result)
	else:
		print("🧪 Method not found after adding to scene!")
	
	graph_controller.queue_free()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_8:
		print("🧪 Manual direct test triggered")
		test_direct_graph_creation()
