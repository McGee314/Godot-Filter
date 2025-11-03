extends Node

# Pentagon Wheel Graph Focus Test
# This script tests ONLY Pentagon wheel graph generation

func _ready():
	print("🎯 === PENTAGON FOCUS + TERRAIN FUNCTIONS ===")
	print("🔑 Press KEY_5 to generate Pentagon wheel graph [PRIMARY TEST]")
	print("🪨 Press KEY_6 to place demo rock assets") 
	print("🔄 Press KEY_7 to force reload Terrain3D data")
	print("🏔️ Press KEY_8 to create mountain borders")
	print("📊 Press KEY_9 to show Terrain3D region info")
	print("🧹 Press KEY_C to clear assets")
	print("🎯 ==========================================")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_0:
				# Manual Pentagon test trigger
				print("🔧 Manual Pentagon test - Checking configuration...")
				test_pentagon_config_loading()

func test_pentagon_config_loading():
	print("📁 Testing Pentagon configuration loading...")
	
	var config = load("res://Resources/GraphSystem/PentagonWheelConfig.tres")
	if config:
		print("✅ PentagonWheelConfig loaded successfully!")
		print("  - Vertex count: %d" % config.vertex_count)
		print("  - Radius: %f" % config.radius)
		print("  - Wheel type: %d" % config.wheel_type)
		print("  - Create spokes: %s" % config.create_spokes)
		print("  - Create ring: %s" % config.create_outer_ring)
		
		if config.hub_vertex_config:
			print("  - Hub config: ✅")
		if config.vertex_config:
			print("  - Outer config: ✅")
	else:
		print("❌ Failed to load PentagonWheelConfig")
		
	print("🎯 Pentagon configuration test complete")
