extends Node

# Simple test to verify Tambora hiking trail scene loads correctly

func _ready():
	print("=== Simple Tambora Hiking Trail Test ===")
	test_scene_loading()
	print("=== Simple Test Complete ===")

func test_scene_loading():
	"""Test if the Tambora hiking trail scene loads correctly"""
	print("Testing scene loading...")
	
	# Test if the main scene exists
	var scene_path = "res://Scenes/Terrain/Tambora/tambora_hiking_trail.tscn"
	if ResourceLoader.exists(scene_path):
		print("✅ Main scene exists: " + scene_path)
	else:
		print("❌ Main scene missing: " + scene_path)
		return
	
	# Try to load the scene
	var scene = load(scene_path)
	if scene:
		print("✅ Scene loaded successfully")
	else:
		print("❌ Failed to load scene")
		return
	
	# Try to instantiate the scene
	var instance = scene.instantiate()
	if instance:
		print("✅ Scene instantiated successfully")
		print("📊 Instance type: " + instance.get_class())
		print("📊 Instance children: " + str(instance.get_child_count()))
		
		# Check for key components
		var terrain3d = instance.get_node_or_null("Terrain3D")
		if terrain3d:
			print("✅ Terrain3D found")
		else:
			print("❌ Terrain3D missing")
		
		var trail = instance.get_node_or_null("TamboraHikingTrail")
		if trail:
			print("✅ TamboraHikingTrail found")
		else:
			print("❌ TamboraHikingTrail missing")
		
		var asset_placer = instance.get_node_or_null("TamboraHikingTrail/ProceduralAssets")
		if asset_placer:
			print("✅ ProceduralAssets found")
		else:
			print("❌ ProceduralAssets missing")
		
		# Clean up
		instance.queue_free()
	else:
		print("❌ Failed to instantiate scene")

func _input(event):
	"""Handle input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				print("Exiting test...")
				get_tree().quit()
