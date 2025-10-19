extends Node

# Test script to verify the fixed configuration loading
@tool

func _ready():
	if not Engine.is_editor_hint():
		return
		
	print("=== Testing Fixed Configuration Loading ===")
	test_pentagon_wheel_config()
	test_hexagon_wheel_config() 
	test_pentagon_cycle_config()

func test_pentagon_wheel_config():
	print("🔄 Testing PentagonWheelConfig loading...")
	var config = load("res://Resources/GraphSystem/PentagonWheelConfig.tres")
	if config:
		print("✅ PentagonWheelConfig loaded successfully!")
		print("  - Type: %s" % config.get_class())
		print("  - Script: %s" % (config.get_script().get_global_name() if config.get_script() else "None"))
		print("  - Radius: %s" % config.radius)
		print("  - Vertex count: %s" % config.vertex_count)
		print("  - Wheel type: %s" % config.wheel_type)
		if config.hub_vertex_config:
			print("  - Hub config loaded: ✅")
		if config.vertex_config:
			print("  - Outer config loaded: ✅")
	else:
		print("❌ Failed to load PentagonWheelConfig")

func test_hexagon_wheel_config():
	print("🔄 Testing HexagonWheelConfig loading...")
	var config = load("res://Resources/GraphSystem/HexagonWheelConfig.tres")
	if config:
		print("✅ HexagonWheelConfig loaded successfully!")
		print("  - Radius: %s" % config.radius)
		print("  - Vertex count: %s" % config.vertex_count)
		print("  - Wheel type: %s" % config.wheel_type)
	else:
		print("❌ Failed to load HexagonWheelConfig")

func test_pentagon_cycle_config():
	print("🔄 Testing PentagonCycleConfig loading...")
	var config = load("res://Resources/GraphSystem/PentagonCycleConfig.tres")
	if config:
		print("✅ PentagonCycleConfig loaded successfully!")
		print("  - Radius: %s" % config.radius)
		print("  - Vertex count: %s" % config.vertex_count)
		if config.vertex_config:
			print("  - Vertex config loaded: ✅")
	else:
		print("❌ Failed to load PentagonCycleConfig")

	print("=== Configuration Loading Test Complete ===")
