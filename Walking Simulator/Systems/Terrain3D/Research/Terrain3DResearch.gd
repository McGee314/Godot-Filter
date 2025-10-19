extends Node

## Terrain3D Research Class
## Contains experimental terrain generation functions for research purposes
## These functions are separated from the main terrain controller to avoid clutter

var terrain3d_node: Terrain3D
var debug_config: Node

func _ready():
	# Setup references
	terrain3d_node = get_node_or_null("../../Terrain3DManager/Terrain3D")
	debug_config = get_node_or_null("/root/DebugConfig")

func _input(event):
	"""Handle input for research functions"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				generate_basic_terrain()
			KEY_2:
				generate_terrain_from_noise_layers()
			KEY_3:
				generate_terrain_from_hand_painted()
			KEY_4:
				generate_terrain_from_image("res://Assets/Terrain/heightmap_example.png", 100.0)

func generate_basic_terrain():
	"""Generate basic terrain heightmap and apply to Terrain3D"""
	GameLogger.info("🔬 [RESEARCH] Generating basic terrain...")
	if not terrain3d_node:
		GameLogger.error("❌ [RESEARCH] Terrain3D node not found")
		return
	
	# Create a simple heightmap
	var heightmap = Image.create(512, 512, false, Image.FORMAT_RF)
	
	# Generate simple terrain with some hills
	for x in range(512):
		for y in range(512):
			var height = sin(x * 0.02) * cos(y * 0.02) * 10.0 + 5.0
			heightmap.set_pixel(x, y, Color(height, 0, 0, 1))
	
	# Apply to Terrain3D
	# Note: This is research code - actual implementation would depend on Terrain3D API
	GameLogger.info("✅ [RESEARCH] Basic terrain generated")

func generate_terrain_from_noise_layers():
	"""Generate complex terrain using multiple noise layers"""
	GameLogger.info("🔬 [RESEARCH] Generating terrain from noise layers...")
	if not terrain3d_node:
		GameLogger.error("❌ [RESEARCH] Terrain3D node not found")
		return
	
	# Create noise for terrain generation
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.01
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	# Create heightmap
	var heightmap = Image.create(512, 512, false, Image.FORMAT_RF)
	
	# Generate terrain with multiple noise layers
	for x in range(512):
		for y in range(512):
			var height = 0.0
			# Base terrain
			height += noise.get_noise_2d(x, y) * 20.0
			# Add detail noise
			noise.frequency = 0.05
			height += noise.get_noise_2d(x, y) * 5.0
			# Add fine detail
			noise.frequency = 0.1
			height += noise.get_noise_2d(x, y) * 2.0
			
			height = clamp(height + 10.0, 0.0, 50.0)
			heightmap.set_pixel(x, y, Color(height, 0, 0, 1))
	
	GameLogger.info("✅ [RESEARCH] Noise-based terrain generated")

func generate_terrain_from_hand_painted():
	"""Generate terrain from hand-painted heightmap"""
	GameLogger.info("🔬 [RESEARCH] Generating terrain from hand-painted heightmap...")
	if not terrain3d_node:
		GameLogger.error("❌ [RESEARCH] Terrain3D node not found")
		return
	
	# Load hand-painted heightmap
	var heightmap_path = "res://Assets/Terrain/hand_painted_heightmap.png"
	if FileAccess.file_exists(heightmap_path):
		var heightmap = Image.new()
		heightmap.load(heightmap_path)
		GameLogger.info("✅ [RESEARCH] Loaded hand-painted heightmap")
		# Apply to Terrain3D here
	else:
		GameLogger.warning("⚠️ [RESEARCH] Hand-painted heightmap not found at: %s" % heightmap_path)

func generate_terrain_from_image(image_path: String, height_scale: float = 100.0):
	"""Generate terrain heightmap from an image file"""
	GameLogger.info("🔬 [RESEARCH] Generating terrain from image: %s" % image_path)
	if not terrain3d_node:
		GameLogger.error("❌ [RESEARCH] Terrain3D node not found")
		return
	
	if FileAccess.file_exists(image_path):
		var heightmap = Image.new()
		heightmap.load(image_path)
		GameLogger.info("✅ [RESEARCH] Loaded heightmap from image")
		# Apply to Terrain3D here with height_scale
	else:
		GameLogger.warning("⚠️ [RESEARCH] Image not found at: %s" % image_path)

# Mountain Border Functions (moved from main system)
func create_mountain_borders(player_pos: Vector3, terrain_controller: Node):
	"""Create mountains around the gameplay area - RESEARCH VERSION"""
	GameLogger.info("🏔️ [RESEARCH] Creating mountain borders...")
	GameLogger.info("📍 Player position: %s" % player_pos)
	
	# Create mountain container
	var mountain_container = Node3D.new()
	mountain_container.name = "MountainBorders_Research"
	terrain_controller.add_child(mountain_container)
	
	# Create mountains in a circle around the player
	var mountain_count = 8
	var mountain_radius = 100.0
	
	for i in range(mountain_count):
		var angle = i * (2.0 * PI / mountain_count)
		var x = player_pos.x + cos(angle) * mountain_radius
		var z = player_pos.z + sin(angle) * mountain_radius
		var pos = Vector3(x, 0, z)
		
		# Get terrain height using the terrain controller
		var terrain_height = terrain_controller.get_terrain_height_at_position(pos)
		
		# Create mountain
		create_single_mountain(Vector3(pos.x, terrain_height, pos.z), i, mountain_container)
	
	GameLogger.info("✅ [RESEARCH] Created %d mountain borders around player" % mountain_count)

func create_single_mountain(pos: Vector3, mountain_index: int, container: Node3D):
	"""Create a single mountain at the specified position - RESEARCH VERSION"""
	GameLogger.info("🏔️ [RESEARCH] Creating mountain %d at position %s" % [mountain_index, pos])
	
	# Create mountain mesh
	var mountain = MeshInstance3D.new()
	var mountain_mesh = CylinderMesh.new()
	mountain_mesh.top_radius = 0.0  # Pointy top
	mountain_mesh.bottom_radius = 8.0  # Wide base
	mountain_mesh.height = 25.0
	mountain.mesh = mountain_mesh
	
	# Create mountain material
	var mountain_material = StandardMaterial3D.new()
	mountain_material.albedo_color = Color(0.4, 0.3, 0.2)  # Dark brown/gray
	mountain_material.roughness = 0.9
	mountain_material.metallic = 0.0
	mountain.material_override = mountain_material
	
	mountain.name = "Mountain_Research_%d" % mountain_index
	container.add_child(mountain)
	mountain.global_position = pos
	
	# Add some random variation
	mountain.rotation.y = randf() * TAU
	mountain.scale = Vector3(
		randf_range(0.8, 1.3),
		randf_range(0.7, 1.2),
		randf_range(0.8, 1.3)
	)
	
	GameLogger.info("✅ [RESEARCH] Created mountain %d at %s" % [mountain_index, pos])
