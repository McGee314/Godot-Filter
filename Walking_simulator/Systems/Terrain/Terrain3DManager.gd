extends Node3D
class_name Terrain3DManager

## Terrain3D Integration Manager for Papua Scene
## Handles Terrain3D setup, PSX texture integration, and asset placement

@onready var terrain3d: Terrain3D
@onready var terrain_material: Terrain3DMaterial
@onready var terrain_assets: Terrain3DAssets

# Terrain3D configuration
var terrain_data_directory: String = "res://Scenes/IndonesiaTimur/terrain_data"
var terrain_size: int = 1024  # Terrain size in meters
var terrain_resolution: int = 1024  # Height map resolution

# PSX texture integration
var psx_textures: Dictionary = {}
var psx_materials: Dictionary = {}

# Asset placement
var asset_placer: Node3D
var psx_asset_pack: Resource

func _ready():
	GameLogger.info("🌍 Terrain3DManager: Initializing Terrain3D system...")
	
	# Setup Terrain3D system
	setup_terrain3d_system()
	
	# Load PSX textures
	load_psx_textures()
	
	# Create terrain material with PSX textures
	create_terrain_material()
	
	# Setup asset placement system
	setup_asset_placement()
	
	GameLogger.info("✅ Terrain3DManager: System initialized successfully")

func setup_terrain3d_system():
	"""Setup the core Terrain3D system"""
	GameLogger.info("🏗️ Setting up Terrain3D system...")
	
	# Create Terrain3D node
	terrain3d = Terrain3D.new()
	terrain3d.name = "Terrain3D"
	terrain3d.data_directory = terrain_data_directory
	terrain3d.collision_mask = 1  # Player collision layer
	terrain3d.top_level = true
	
	# Add to scene
	add_child(terrain3d)
	
	# Create data directory if it doesn't exist
	ensure_data_directory()
	
	GameLogger.info("✅ Terrain3D node created and configured")

func ensure_data_directory():
	"""Ensure the terrain data directory exists"""
	var dir = DirAccess.open("res://Scenes/IndonesiaTimur/")
	if dir == null:
		GameLogger.error("❌ Cannot access Scenes/IndonesiaTimur/ directory")
		return
	
	if not dir.dir_exists("terrain_data"):
		var result = dir.make_dir("terrain_data")
		if result == OK:
			GameLogger.info("📁 Created terrain data directory")
		else:
			GameLogger.error("❌ Failed to create terrain data directory")
	else:
		GameLogger.info("📁 Terrain data directory already exists")

func load_psx_textures():
	"""Load PSX textures for terrain material"""
	GameLogger.info("🎨 Loading PSX textures...")
	
	# Load PSX textures from Assets/PSX/PSX Textures
	var psx_texture_dir = "res://Assets/PSX/PSX Textures/Color/"
	var psx_normal_dir = "res://Assets/PSX/PSX Textures/Normal/"
	
	# Load terrain textures
	var terrain_textures = [
		"ground_01", "ground_02", "ground_03", "ground_04",
		"rock_01", "rock_02", "rock_03", "rock_04",
		"grass_01", "grass_02", "grass_03", "grass_04"
	]
	
	for texture_name in terrain_textures:
		var color_path = psx_texture_dir + texture_name + ".png"
		var normal_path = psx_normal_dir + texture_name + "_n.png"
		
		# Load color texture
		if FileAccess.file_exists(color_path):
			var color_texture = load(color_path)
			if color_texture:
				psx_textures[texture_name + "_color"] = color_texture
				GameLogger.info("✅ Loaded PSX texture: " + texture_name + "_color")
		
		# Load normal texture
		if FileAccess.file_exists(normal_path):
			var normal_texture = load(normal_path)
			if normal_texture:
				psx_textures[texture_name + "_normal"] = normal_texture
				GameLogger.info("✅ Loaded PSX texture: " + texture_name + "_normal")
	
	GameLogger.info("🎨 Loaded %d PSX textures" % psx_textures.size())

func create_terrain_material():
	"""Create Terrain3D material with PSX textures"""
	GameLogger.info("🎨 Creating Terrain3D material with PSX textures...")
	
	# Create Terrain3D material
	terrain_material = Terrain3DMaterial.new()
	terrain_material.auto_shader = true
	terrain_material.dual_scaling = true
	
	# Configure material parameters for PSX style
	terrain_material.set_shader_parameter("blend_sharpness", 0.8)
	terrain_material.set_shader_parameter("height_blending", true)
	terrain_material.set_shader_parameter("world_space_normal_blend", true)
	terrain_material.set_shader_parameter("dual_scale_near", 50.0)
	terrain_material.set_shader_parameter("dual_scale_far", 150.0)
	terrain_material.set_shader_parameter("dual_scale_reduction", 0.4)
	
	# Create Terrain3D assets
	create_terrain_assets()
	
	# Assign material and assets to terrain
	terrain3d.material = terrain_material
	terrain3d.assets = terrain_assets
	
	GameLogger.info("✅ Terrain3D material created with PSX textures")

func create_terrain_assets():
	"""Create Terrain3D assets with PSX textures"""
	GameLogger.info("🎨 Creating Terrain3D assets...")
	
	terrain_assets = Terrain3DAssets.new()
	
	# Create texture assets from PSX textures
	var texture_assets = []
	
	# Ground texture
	if psx_textures.has("ground_01_color"):
		var ground_texture = Terrain3DTextureAsset.new()
		ground_texture.name = "PSX_Ground"
		ground_texture.albedo_texture = psx_textures["ground_01_color"]
		ground_texture.normal_texture = psx_textures.get("ground_01_normal", null)
		ground_texture.uv_scale = 0.1  # Small scale for detailed PSX look
		ground_texture.roughness = 0.8
		texture_assets.append(ground_texture)
	
	# Rock texture
	if psx_textures.has("rock_01_color"):
		var rock_texture = Terrain3DTextureAsset.new()
		rock_texture.name = "PSX_Rock"
		rock_texture.albedo_texture = psx_textures["rock_01_color"]
		rock_texture.normal_texture = psx_textures.get("rock_01_normal", null)
		rock_texture.uv_scale = 0.05  # Even smaller for rock detail
		rock_texture.roughness = 0.9
		texture_assets.append(rock_texture)
	
	# Grass texture
	if psx_textures.has("grass_01_color"):
		var grass_texture = Terrain3DTextureAsset.new()
		grass_texture.name = "PSX_Grass"
		grass_texture.albedo_texture = psx_textures["grass_01_color"]
		grass_texture.normal_texture = psx_textures.get("grass_01_normal", null)
		grass_texture.uv_scale = 0.2  # Larger scale for grass
		grass_texture.roughness = 0.7
		texture_assets.append(grass_texture)
	
	# Assign texture assets
	terrain_assets.texture_list = texture_assets
	
	GameLogger.info("✅ Created %d Terrain3D texture assets" % texture_assets.size())

func setup_asset_placement():
	"""Setup asset placement system for terrain snapping"""
	GameLogger.info("🌳 Setting up asset placement system...")
	
	# Create asset placer
	asset_placer = Node3D.new()
	asset_placer.name = "TerrainAssetPlacer"
	add_child(asset_placer)
	
	# Load PSX asset pack
	psx_asset_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if psx_asset_pack:
		GameLogger.info("✅ Loaded PSX asset pack: " + psx_asset_pack.region_name)
		asset_placer.set_meta("asset_pack", psx_asset_pack)
	else:
		GameLogger.error("❌ Failed to load PSX asset pack")
	
	GameLogger.info("✅ Asset placement system ready")

func place_asset_on_terrain(asset_path: String, position: Vector3, asset_type: String = "misc") -> Node3D:
	"""Place an asset on the terrain with proper height snapping"""
	if not terrain3d:
		GameLogger.error("❌ Terrain3D not available for asset placement")
		return null
	
	# Get terrain height at position
	var terrain_height = get_terrain_height_at_position(position)
	if terrain_height == -1:
		GameLogger.warning("⚠️ Could not get terrain height at " + str(position))
		terrain_height = position.y
	
	# Load and instantiate asset
	var asset_scene = load(asset_path)
	if not asset_scene:
		GameLogger.error("❌ Failed to load asset: " + asset_path)
		return null
	
	var asset_instance = asset_scene.instantiate()
	if not asset_instance:
		GameLogger.error("❌ Failed to instantiate asset: " + asset_path)
		return null
	
	# Position asset on terrain
	asset_instance.position = Vector3(position.x, terrain_height, position.z)
	asset_instance.rotation.y = randf() * TAU  # Random rotation
	
	# Scale asset appropriately
	var scale_factor = 1.0
	match asset_type:
		"tree":
			scale_factor = randf_range(0.8, 1.3)
		"vegetation":
			scale_factor = randf_range(0.6, 1.2)
		"mushroom":
			scale_factor = randf_range(0.4, 0.8)
		"stone":
			scale_factor = randf_range(0.7, 1.1)
		_:
			scale_factor = randf_range(0.8, 1.0)
	
	asset_instance.scale = Vector3.ONE * scale_factor
	asset_instance.name = asset_type + "_" + str(asset_placer.get_child_count())
	
	# Add to scene
	asset_placer.add_child(asset_instance)
	
	GameLogger.debug("✅ Placed %s at %s (height: %.2f)" % [asset_type, position, terrain_height])
	return asset_instance

func get_terrain_height_at_position(position: Vector3) -> float:
	"""Get terrain height at a specific position"""
	if not terrain3d:
		return -1
	
	# Use ray casting to get terrain height
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		position + Vector3.UP * 1000,  # Start high above
		position + Vector3.DOWN * 1000  # End far below
	)
	query.collision_mask = 1  # Terrain collision layer
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.position.y
	
	return -1

func generate_terrain_heightmap():
	"""Generate a height map for the terrain"""
	GameLogger.info("⛰️ Generating terrain height map...")
	
	# Create a simple height map using noise
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.01
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	# Create height map image
	var height_map = Image.create(terrain_resolution, terrain_resolution, false, Image.FORMAT_RF)
	
	for x in range(terrain_resolution):
		for y in range(terrain_resolution):
			var world_x = (x / float(terrain_resolution)) * terrain_size - terrain_size / 2
			var world_y = (y / float(terrain_resolution)) * terrain_size - terrain_size / 2
			
			# Generate height using noise
			var height = noise.get_noise_2d(world_x, world_y)
			height = (height + 1.0) / 2.0  # Normalize to 0-1
			height = height * 50.0  # Scale to 0-50 meters
			
			height_map.set_pixel(x, y, Color(height, 0, 0, 1))
	
	# Save height map
	var height_map_path = terrain_data_directory + "/heightmap.png"
	height_map.save_png(height_map_path)
	
	GameLogger.info("✅ Generated height map: " + height_map_path)

func place_forest_assets(center: Vector3, radius: float, density: float = 0.5):
	"""Place forest assets in a circular area"""
	GameLogger.info("🌲 Placing forest assets at %s (radius: %.1f)" % [center, radius])
	
	if not psx_asset_pack:
		GameLogger.error("❌ No PSX asset pack available")
		return
	
	var trees = psx_asset_pack.trees
	var vegetation = psx_asset_pack.vegetation
	var mushrooms = psx_asset_pack.mushrooms
	var stones = psx_asset_pack.stones
	
	var total_assets = 0
	
	# Place trees
	for i in range(int(radius * density * 2)):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		if trees.size() > 0:
			var tree_path = trees[randi() % trees.size()]
			place_asset_on_terrain(tree_path, pos, "tree")
			total_assets += 1
	
	# Place vegetation
	for i in range(int(radius * density * 3)):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		if vegetation.size() > 0:
			var veg_path = vegetation[randi() % vegetation.size()]
			place_asset_on_terrain(veg_path, pos, "vegetation")
			total_assets += 1
	
	# Place mushrooms
	for i in range(int(radius * density * 1)):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		if mushrooms.size() > 0:
			var mushroom_path = mushrooms[randi() % mushrooms.size()]
			place_asset_on_terrain(mushroom_path, pos, "mushroom")
			total_assets += 1
	
	# Place stones
	for i in range(int(radius * density * 0.5)):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		if stones.size() > 0:
			var stone_path = stones[randi() % stones.size()]
			place_asset_on_terrain(stone_path, pos, "stone")
			total_assets += 1
	
	GameLogger.info("✅ Placed %d forest assets" % total_assets)

func clear_placed_assets():
	"""Clear all placed assets"""
	GameLogger.info("🧹 Clearing placed assets...")
	
	if asset_placer:
		for child in asset_placer.get_children():
			child.queue_free()
	
	GameLogger.info("✅ Cleared all placed assets")

func get_terrain_info() -> Dictionary:
	"""Get information about the terrain system"""
	var info = {
		"terrain_size": terrain_size,
		"terrain_resolution": terrain_resolution,
		"data_directory": terrain_data_directory,
		"psx_textures_loaded": psx_textures.size(),
		"assets_placed": asset_placer.get_child_count() if asset_placer else 0
	}
	
	return info
