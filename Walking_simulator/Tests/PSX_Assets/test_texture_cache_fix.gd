extends Node

# Test to verify texture cache fix

func _ready():
	print("=== Testing Texture Cache Fix ===")
	test_texture_cache()
	print("=== Texture Cache Test Complete ===")

func test_texture_cache():
	print("\nTesting Texture Cache Initialization...")
	
	# Create a test instance to access the texture system
	var test_instance = preload("res://Tests/PSX_Assets/test_psx_assets.tscn").instantiate()
	
	# Call the texture system initialization
	test_instance.initialize_texture_system()
	
	# Check the cache contents
	var cache = test_instance.available_textures_cache
	print("  📊 Cache contents:")
	
	for category in cache:
		var resources = cache[category]
		print("    " + category + ": " + str(resources.size()) + " resources")
		
		for i in range(min(resources.size(), 3)):  # Show first 3 resources
			var resource = resources[i]
			if resource is Texture2D:
				print("      - Texture2D: " + resource.resource_path.get_file())
			elif resource is StandardMaterial3D:
				print("      - StandardMaterial3D: " + str(resource.albedo_color))
			else:
				print("      - Unknown type: " + str(resource.get_class()))
		
		if resources.size() > 3:
			print("      ... and " + str(resources.size() - 3) + " more")
	
	# Clean up
	test_instance.queue_free()
	
	print("  ✅ Texture cache test completed")
