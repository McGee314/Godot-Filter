extends Node

func _ready():
	print("=== Simple Terrain3D Check ===")
	
	# Check if Terrain3D class exists
	if ClassDB.class_exists("Terrain3D"):
		print("✅ Terrain3D class exists!")
		
		# Try to create a Terrain3D node
		var terrain = ClassDB.instantiate("Terrain3D")
		if terrain:
			print("✅ Terrain3D node created successfully!")
			print("Node name: " + terrain.name)
			terrain.free()
		else:
			print("❌ Failed to create Terrain3D node")
	else:
		print("❌ Terrain3D class not found")
	
	print("=== Check Complete ===")
	get_tree().quit()
