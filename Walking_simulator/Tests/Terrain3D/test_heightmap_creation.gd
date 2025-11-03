extends Node

# Script to create a simple test heightmap for terrain testing

func _ready():
	print("=== Creating Test Heightmap ===")
	create_test_heightmap()
	print("=== Test Heightmap Creation Complete ===")

func create_test_heightmap():
	print("\n🎨 Creating test heightmap...")
	
	# Create a simple 256x256 heightmap
	var image = Image.new()
	image.create(256, 256, false, Image.FORMAT_R8)
	
	# Fill with a simple gradient pattern
	for x in range(256):
		for y in range(256):
			# Create a simple height pattern
			var height = 0.0
			
			# Center-based height (higher in center, lower at edges)
			var center_x = 128.0
			var center_y = 128.0
			var distance = sqrt((x - center_x) * (x - center_x) + (y - center_y) * (y - center_y))
			var max_distance = sqrt(center_x * center_x + center_y * center_y)
			
			# Normalize distance and create height
			var normalized_distance = distance / max_distance
			height = (1.0 - normalized_distance) * 255.0
			
			# Add some noise for realism
			height += randf_range(-20.0, 20.0)
			height = clamp(height, 0.0, 255.0)
			
			# Set the pixel
			image.set_pixel(x, y, Color(height / 255.0, height / 255.0, height / 255.0, 1.0))
	
	# Save the heightmap
	var save_path = "res://Assets/Terrain/Papua/heightmaps/papua_test_heightmap.png"
	
	# Ensure directory exists
	var dir = DirAccess.open("res://Assets/Terrain/Papua/heightmaps")
	if not dir:
		dir = DirAccess.open("res://Assets/Terrain/Papua")
		if dir:
			dir.make_dir("heightmaps")
			print("  📁 Created heightmaps directory")
		else:
			print("  ⚠️ Could not create heightmaps directory")
	
	# Save the image
	var error = image.save_png(save_path)
	if error == OK:
		print("  ✅ Test heightmap saved: " + save_path)
		print("  📊 Size: 256x256 pixels")
		print("  🎯 Use this path in TerrainManager.configure_heightmap()")
	else:
		print("  ❌ Failed to save heightmap: " + str(error))
	
	# Also create a Tambora version
	var tambora_image = Image.new()
	tambora_image.create(256, 256, false, Image.FORMAT_R8)
	
	# Create a more mountainous pattern for Tambora
	for x in range(256):
		for y in range(256):
			var height = 0.0
			
			# Create multiple peaks for volcanic terrain
			var peak1 = create_peak(x, y, 64, 64, 100.0)
			var peak2 = create_peak(x, y, 192, 64, 80.0)
			var peak3 = create_peak(x, y, 128, 192, 120.0)
			
			height = max(peak1, max(peak2, peak3))
			height += randf_range(-10.0, 10.0)
			height = clamp(height, 0.0, 255.0)
			
			tambora_image.set_pixel(x, y, Color(height / 255.0, height / 255.0, height / 255.0, 1.0))
	
	# Ensure Tambora directory exists
	var tambora_dir = DirAccess.open("res://Assets/Terrain/Tambora/heightmaps")
	if not tambora_dir:
		tambora_dir = DirAccess.open("res://Assets/Terrain/Tambora")
		if tambora_dir:
			tambora_dir.make_dir("heightmaps")
			print("  📁 Created Tambora heightmaps directory")
		else:
			print("  ⚠️ Could not create Tambora heightmaps directory")
	
	# Save Tambora heightmap
	var tambora_path = "res://Assets/Terrain/Tambora/heightmaps/tambora_test_heightmap.png"
	error = tambora_image.save_png(tambora_path)
	if error == OK:
		print("  ✅ Tambora test heightmap saved: " + tambora_path)
	else:
		print("  ❌ Failed to save Tambora heightmap: " + str(error))

func create_peak(x: int, y: int, center_x: int, center_y: int, max_height: float) -> float:
	"""Create a peak at the specified center with given maximum height"""
	var distance = sqrt((x - center_x) * (x - center_x) + (y - center_y) * (y - center_y))
	var max_distance = 50.0  # Peak radius
	
	if distance > max_distance:
		return 0.0
	
	# Create a smooth peak
	var normalized_distance = distance / max_distance
	var height = (1.0 - normalized_distance * normalized_distance) * max_height
	return height

func _input(event):
	"""Handle input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
