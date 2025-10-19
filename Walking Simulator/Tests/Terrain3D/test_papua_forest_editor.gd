extends Node3D

# Test script for Papua Forest Trail
# Validates tropical forest terrain generation, asset placement, and ecosystem simulation

var papua_forest: Node3D
var test_results: Dictionary = {}
var asset_placer: Node3D

# Forest textures directory (TGA atlas/basecolor)
const FOREST_TEX_DIR := "res://Assets/Terrain/Shared/textures/forest/"
const SHARED_ROOT := "res://Assets/Terrain/Shared/"
const SHARED_PSX_MODELS := "res://Assets/Terrain/Shared/psx_models/"

func _filter_glb(paths: Array) -> Array[String]:
	var out: Array[String] = []
	for p in paths:
		if typeof(p) == TYPE_STRING:
			var sp: String = p
			sp = sp.replace("\\", "/")
			if sp.to_lower().ends_with(".glb") and sp.begins_with(SHARED_ROOT):
				out.append(sp)
	return out

# Bamboo function removed - using only jungle trees and vegetation

# Bamboo orientation function removed - no longer needed

func _ready():
	GameLogger.info("=== Papua Forest Test ===")
	GameLogger.info("🌴 Scene name: " + get_tree().current_scene.name)
	GameLogger.info("🌿 Tropical forest simulation starting...")
	
	# Check if camera is current
	var camera = get_node_or_null("TestCamera")
	if camera:
		GameLogger.info("📷 Camera found: " + str(camera.get_path()))
		if not camera.current:
			GameLogger.warning("⚠️ Camera is not current! Setting it as current...")
			camera.current = true
	else:
		GameLogger.error("❌ Camera not found!")
	
	# Test lighting and create tropical forest environment
	test_lighting_with_forest_elements()
	
	# Setup Papua forest environment
	setup_papua_forest()
	
	# Setup UI connections
	setup_ui_connections()
	
	GameLogger.info("✅ Papua Forest test environment ready")
	GameLogger.info("🎯 Try clicking the buttons to test tropical forest features!")

func _load_tga_texture_from_dir(prefer_name_contains: String = "atlas") -> Texture2D:
	var dir := DirAccess.open(FOREST_TEX_DIR)
	if dir == null:
		GameLogger.warning("⚠️ Forest textures dir not found: %s" % FOREST_TEX_DIR)
		return null
	dir.list_dir_begin()
	var first_tga := ""
	var best_match := ""
	var name := dir.get_next()
	while name != "":
		if name.to_lower().ends_with(".tga"):
			if first_tga == "":
				first_tga = name
			if prefer_name_contains != "" and name.to_lower().find(prefer_name_contains) != -1:
				best_match = name
		name = dir.get_next()
	dir.list_dir_end()
	var chosen := best_match if best_match != "" else first_tga
	if chosen == "":
		return null
	var img := Image.new()
	var err := img.load(FOREST_TEX_DIR.path_join(chosen))
	if err != OK:
		GameLogger.warning("⚠️ Failed to load TGA: %s (err %s)" % [chosen, str(err)])
		return null
	return ImageTexture.create_from_image(img)

func _make_plant_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	# TGA atlas with alpha cutout
	var atlas := _load_tga_texture_from_dir("atlas")
	if atlas != null:
		mat.albedo_texture = atlas
	# Backface culling OFF (double sided plants)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Alpha cutout
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.3
	# PBR settings
	mat.metallic = 0.0
	mat.roughness = 0.7
	# Slight subsurface disabled to avoid remap warnings on imports
	# mat.subsurface_scattering_strength = 0.15
	return mat

func _apply_plant_materials_to_instance(root: Node) -> void:
	var mat := _make_plant_material()
	if mat == null:
		return
	var stack: Array[Node] = [root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			# Apply to override and surfaces
			mi.material_override = null
			var mesh := mi.mesh
			if mesh is ArrayMesh:
				var am := mesh as ArrayMesh
				var sc := am.get_surface_count()
				for si in range(sc):
					mi.set_surface_override_material(si, mat)
		for c in n.get_children():
			if c is Node:
				stack.push_back(c)

func test_lighting_with_forest_elements():
	"""Test lighting with tropical forest elements"""
	GameLogger.info("🌴 Testing lighting with tropical forest elements...")
	
	# Create forest floor plane
	var forest_floor = CSGBox3D.new()
	forest_floor.size = Vector3(2000, 1, 2000)
	forest_floor.position = Vector3(0, -0.5, 0)
	forest_floor.material = StandardMaterial3D.new()
	forest_floor.material.albedo_color = Color(0.2, 0.4, 0.2, 1)  # Dark green forest floor
	forest_floor.name = "ForestFloor"
	
	add_child(forest_floor)
	GameLogger.info("✅ Added forest floor for better terrain visualization")
	
	# Create test markers for different forest zones
	var zones = [
		{"name": "Dense Forest", "pos": Vector3(0, 5, 0), "color": Color.GREEN},
		{"name": "River Valley", "pos": Vector3(200, 2, 0), "color": Color.BLUE},
		{"name": "Highland", "pos": Vector3(0, 50, -200), "color": Color.BROWN},
		{"name": "Clearing", "pos": Vector3(-200, 10, 0), "color": Color.YELLOW}
	]
	
	for zone in zones:
		var marker = CSGBox3D.new()
		marker.size = Vector3(15, 15, 15)
		marker.position = zone.pos
		marker.material = StandardMaterial3D.new()
		marker.material.albedo_color = zone.color
		marker.name = zone.name + "Marker"
		
		add_child(marker)
		GameLogger.info("✅ Added %s zone marker at %s" % [zone.name, zone.pos])
	
	# Create trail path visualization
	create_forest_trail_visualization()

func create_forest_trail_visualization():
	"""Create visual markers to show the forest trail path"""
	GameLogger.info("🛤️ Creating forest trail path visualization...")
	
	# Define trail points through different forest zones
	var trail_points = [
		Vector3(0, 5, 100),      # Trail start - dense forest
		Vector3(50, 8, 50),      # Through vegetation grove
		Vector3(150, 3, 0),      # Near river valley
		Vector3(100, 15, -100),  # Upland forest
		Vector3(0, 40, -200),    # Highland approach
		Vector3(-50, 25, -150),  # Mountain slope
		Vector3(-100, 10, -50),  # Return through clearing
		Vector3(-50, 8, 0),      # Back to river area
		Vector3(0, 5, 100)       # Complete loop
	]
	
	# Create trail markers
	for i in range(trail_points.size()):
		var trail_marker = CSGBox3D.new()
		trail_marker.size = Vector3(3, 3, 3)
		trail_marker.position = trail_points[i]
		trail_marker.material = StandardMaterial3D.new()
		trail_marker.material.albedo_color = Color.ORANGE
		trail_marker.name = "TrailPoint" + str(i)
		
		add_child(trail_marker)
	
	# Create connecting lines between trail points
	for i in range(trail_points.size() - 1):
		var start_point = trail_points[i]
		var end_point = trail_points[i + 1]
		var distance = start_point.distance_to(end_point)
		var direction = (end_point - start_point).normalized()
		var center = (start_point + end_point) / 2
		
		var trail_line = CSGBox3D.new()
		trail_line.size = Vector3(1, 1, distance)
		trail_line.position = center
		# Use look_at_from_position to orient before the node is inside the tree
		trail_line.look_at_from_position(center, end_point, Vector3.UP)
		trail_line.material = StandardMaterial3D.new()
		trail_line.material.albedo_color = Color.WHITE
		trail_line.material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		trail_line.material.albedo_color.a = 0.4
		trail_line.name = "TrailConnection" + str(i)
		
		add_child(trail_line)
	
	GameLogger.info("✅ Added forest trail path visualization with %d points" % trail_points.size())

func setup_papua_forest():
	"""Setup the Papua forest environment"""
	GameLogger.info("🌴 Setting up Papua forest environment...")
	
	# Load Papua asset pack
	var asset_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if not asset_pack:
		GameLogger.error("❌ Failed to load Papua asset pack")
		return
	
	GameLogger.info("✅ Loaded Papua asset pack: " + asset_pack.region_name)
	GameLogger.info("🌿 Environment type: " + asset_pack.environment_type)
	
	# Create asset placer
	asset_placer = Node3D.new()
	asset_placer.name = "PapuaAssetPlacer"
	add_child(asset_placer)
	
	# Store reference to asset pack
	asset_placer.set_meta("asset_pack", asset_pack)
	
	GameLogger.info("✅ Papua forest environment setup complete")

func setup_ui_connections():
	"""Connect UI buttons to test functions"""
	GameLogger.info("🔍 Setting up UI connections...")
	
	var ui_root = get_node_or_null("UI")
	if not ui_root:
		GameLogger.error("❌ UI root not found")
		return
	
	var test_panel = ui_root.get_node_or_null("TestPanel")
	if not test_panel:
		GameLogger.error("❌ TestPanel not found")
		return
	
	var ui = test_panel.get_node_or_null("VBoxContainer")
	if not ui:
		GameLogger.error("❌ VBoxContainer not found")
		return
	
	# Get buttons
	var test_forest_btn = ui.get_node_or_null("Button")
	var test_tropical_assets_btn = ui.get_node_or_null("Button2")
	var test_ecosystem_btn = ui.get_node_or_null("Button3")
	var show_stats_btn = ui.get_node_or_null("Button4")
	var debug_btn = ui.get_node_or_null("Button5")
	var canopy_view_btn = ui.get_node_or_null("Button6")
	var ground_view_btn = ui.get_node_or_null("Button7")
	var test_biodiversity_btn = ui.get_node_or_null("Button8")
	var test_biomes_btn = ui.get_node_or_null("Button9")
	var clear_btn = ui.get_node_or_null("Button10")
	
	# Connect buttons
	if test_forest_btn:
		test_forest_btn.pressed.connect(_on_test_forest_generation)
		GameLogger.info("✅ Connected forest generation button")
	
	if test_tropical_assets_btn:
		test_tropical_assets_btn.pressed.connect(_on_test_tropical_asset_placement)
		GameLogger.info("✅ Connected tropical asset placement button")
	
	if test_ecosystem_btn:
		test_ecosystem_btn.pressed.connect(_on_test_ecosystem_simulation)
		GameLogger.info("✅ Connected ecosystem simulation button")
	
	if show_stats_btn:
		show_stats_btn.pressed.connect(_on_show_forest_statistics)
		GameLogger.info("✅ Connected forest statistics button")
	
	if debug_btn:
		debug_btn.pressed.connect(debug_forest_test)
		GameLogger.info("✅ Connected debug button")
	
	if canopy_view_btn:
		canopy_view_btn.pressed.connect(_on_canopy_view)
		GameLogger.info("✅ Connected canopy view button")
	
	if ground_view_btn:
		ground_view_btn.pressed.connect(_on_ground_view)
		GameLogger.info("✅ Connected ground view button")
	
	if test_biodiversity_btn:
		test_biodiversity_btn.pressed.connect(_on_test_biodiversity_placement)
		GameLogger.info("✅ Connected biodiversity placement button")
	
	if test_biomes_btn:
		test_biomes_btn.pressed.connect(_on_test_biome_transitions)
		GameLogger.info("✅ Connected biome transitions button")
	
	if clear_btn:
		clear_btn.pressed.connect(clear_placed_assets)
		GameLogger.info("✅ Connected clear/reset button")

func _on_test_forest_generation():
	"""Test tropical forest generation"""
	GameLogger.info("🌴 BUTTON CLICKED: Test Forest Generation")
	
	# Generate different forest zones
	var zones = [
		{"center": Vector3(0, 5, 0), "type": "dense_tropical", "radius": 50},
		{"center": Vector3(200, 2, 0), "type": "riverine", "radius": 30},
		{"center": Vector3(0, 40, -200), "type": "highland", "radius": 40},
		{"center": Vector3(-200, 10, 0), "type": "clearing", "radius": 25}
	]
	
	for zone in zones:
		generate_forest_zone(zone.center, zone.radius, zone.type)
	
	test_results["forest_generation"] = true
	update_results("✅ Generated %d forest zones" % zones.size())

func _diagnose_category(name: String, arr: Array) -> void:
	var total := arr.size()
	var glb_shared := 0
	var skipped_sample: Array[String] = []
	var valid_files: Array[String] = []
	
	for p in arr:
		if typeof(p) == TYPE_STRING:
			var s: String = p
			s = s.replace("\\", "/")
			if s.to_lower().ends_with(".glb") and s.begins_with(SHARED_ROOT):
				glb_shared += 1
				valid_files.append(s)
			else:
				if skipped_sample.size() < 3:
					skipped_sample.append(s)
	
	GameLogger.info("🔎 %s: total=%d, glb_shared=%d, skipped=%d" % [name, total, glb_shared, total - glb_shared])
	
	if valid_files.size() > 0:
		GameLogger.info("   Valid GLB files:")
		for file in valid_files:
			GameLogger.info("     ✅ %s" % file)
	
	if skipped_sample.size() > 0:
		GameLogger.info("   Skipped sample: %s" % ", ".join(skipped_sample))

func _diagnose_assets() -> void:
	var asset_pack = asset_placer.get_meta("asset_pack")
	if not asset_pack:
		GameLogger.warning("⚠️ No asset_pack set on asset_placer")
		return
	
	GameLogger.info("🔍 Asset Pack Diagnosis: %s" % asset_pack.region_name)
	_diagnose_category("trees", asset_pack.trees)
	_diagnose_category("vegetation", asset_pack.vegetation)
	_diagnose_category("mushrooms", asset_pack.mushrooms)
	_diagnose_category("stones", asset_pack.stones)
	_diagnose_category("debris", asset_pack.debris)
	
	# Verify all assets exist
	verify_asset_files(asset_pack)

# Update callers to run diagnostics
func _on_test_tropical_asset_placement():
	"""Test tropical asset placement"""
	GameLogger.info("🌿 BUTTON CLICKED: Test Tropical Asset Placement")
	var asset_pack = asset_placer.get_meta("asset_pack")
	if not asset_pack:
		update_results("❌ Asset pack not found")
		return
	_diagnose_assets()
	# Place tropical vegetation
	place_tropical_vegetation(Vector3(100, 5, 100), 60)
	place_vegetation_groves(Vector3(-100, 8, 50), 40)
	place_tropical_trees(Vector3(50, 5, -100), 80)
	test_results["tropical_placement"] = true
	update_results("✅ Placed tropical forest assets")

func _on_test_ecosystem_simulation():
	"""Test ecosystem simulation"""
	GameLogger.info("🦋 BUTTON CLICKED: Test Ecosystem Simulation")
	
	# Simulate different forest layers
	simulate_canopy_layer(Vector3(0, 25, 0), 100)
	simulate_understory_layer(Vector3(0, 10, 0), 100)
	simulate_forest_floor_layer(Vector3(0, 2, 0), 100)
	
	test_results["ecosystem_simulation"] = true
	update_results("✅ Simulated forest ecosystem layers")

func simulate_canopy_layer(center: Vector3, radius: float):
	"""Simulate the upper canopy layer with tall trees"""
	GameLogger.info("🌳 Simulating canopy layer at %s" % center)
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	var trees = _filter_glb(asset_pack.trees)
	
	if trees.size() == 0:
		GameLogger.warning("⚠️ No trees available for canopy simulation")
		return
	
	# Place fewer, larger trees for canopy
	for i in range(15):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 3)
		
		if trees.size() == 0:
			continue
		var inst := _instantiate_glb(trees[randi() % trees.size()])
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(1.2, 1.8)  # Larger scale for canopy
			inst.rotation.y = randf() * TAU
			inst.name = "canopy_tree_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)
	
	GameLogger.info("✅ Placed %d canopy trees" % 15)

func simulate_understory_layer(center: Vector3, radius: float):
	"""Simulate the middle understory layer with medium vegetation"""
	GameLogger.info("🌿 Simulating understory layer at %s" % center)
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	var vegetation = _filter_glb(asset_pack.vegetation)
	
	if vegetation.size() == 0:
		GameLogger.warning("⚠️ No vegetation available for understory simulation")
		return
	
	# Place medium-density vegetation
	for i in range(40):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 2)
		
		if vegetation.size() == 0:
			continue
		var asset_path = vegetation[randi() % vegetation.size()]
		var inst := _instantiate_glb(asset_path)
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(0.6, 1.1)  # Medium scale
			inst.rotation.y = randf() * TAU
			
			inst.name = "understory_veg_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)
	
	GameLogger.info("✅ Placed %d understory vegetation" % 40)

func simulate_forest_floor_layer(center: Vector3, radius: float):
	"""Simulate the ground floor layer with small plants and debris"""
	GameLogger.info("🌱 Simulating forest floor layer at %s" % center)
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	var vegetation = _filter_glb(asset_pack.vegetation)
	var mushrooms = _filter_glb(asset_pack.mushrooms)
	var debris = _filter_glb(asset_pack.debris)
	
	# Place small ground cover
	for i in range(60):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-0.5, 1)
		
		var asset_type = ""
		var asset_path = ""
		
		# Choose asset type based on probability
		var rand_val = randf()
		if rand_val < 0.4 and vegetation.size() > 0:
			asset_type = "vegetation"
			asset_path = vegetation[randi() % vegetation.size()]
		elif rand_val < 0.7 and mushrooms.size() > 0:
			asset_type = "mushroom"
			asset_path = mushrooms[randi() % mushrooms.size()]
		elif debris.size() > 0:
			asset_type = "debris"
			asset_path = debris[randi() % debris.size()]
		else:
			continue
		
		var inst := _instantiate_glb(asset_path)
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(0.3, 0.8)  # Small scale for ground
			inst.rotation.y = randf() * TAU
			inst.name = "floor_" + asset_type + "_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)
	
	GameLogger.info("✅ Placed forest floor vegetation and debris")

func _on_show_forest_statistics():
	"""Show detailed forest statistics"""
	GameLogger.info("📊 BUTTON CLICKED: Show Forest Statistics")
	_diagnose_assets()
	var total_assets = asset_placer.get_child_count()
	var stats_by_type = count_assets_by_type()
	var stats_text = "🌴 Papua Forest Statistics:\n"
	stats_text += "Total Assets: %d\n" % total_assets
	stats_text += "Trees: %d\n" % stats_by_type.get("trees", 0)
	stats_text += "Vegetation: %d\n" % stats_by_type.get("vegetation", 0)
	stats_text += "Ferns: %d\n" % stats_by_type.get("ferns", 0)
	stats_text += "Tropical Plants: %d\n" % stats_by_type.get("tropical", 0)
	stats_text += "Mushrooms: %d\n" % stats_by_type.get("mushrooms", 0)
	stats_text += "Debris: %d" % stats_by_type.get("debris", 0)
	update_results(stats_text)

func _on_canopy_view():
	"""Switch to canopy view"""
	GameLogger.info("📷 BUTTON CLICKED: Canopy View")
	
	var camera = get_node_or_null("TestCamera")
	if camera:
		camera.global_position = Vector3(150, 60, 150)
		camera.look_at(Vector3(0, 30, 0), Vector3.UP)
		update_results("📷 Camera: Canopy View\nElevation: 60m\nLooking at forest canopy")

func _on_ground_view():
	"""Switch to ground level view"""
	GameLogger.info("📷 BUTTON CLICKED: Ground View")
	
	var camera = get_node_or_null("TestCamera")
	if camera:
		camera.global_position = Vector3(10, 8, 10)
		camera.look_at(Vector3(50, 5, 0), Vector3.UP)
		update_results("📷 Camera: Ground View\nElevation: 8m\nForest floor perspective")

func _on_test_biodiversity_placement():
	"""Test biodiversity-focused placement"""
	GameLogger.info("🌺 BUTTON CLICKED: Test Biodiversity Placement")
	
	# Create biodiverse clusters
	var biodiversity_zones = [
		{"center": Vector3(300, 5, 0), "species_count": 8},
		{"center": Vector3(-300, 8, 100), "species_count": 12},
		{"center": Vector3(0, 15, -300), "species_count": 6}
	]
	
	for zone in biodiversity_zones:
		create_biodiversity_cluster(zone.center, 40, zone.species_count)
	
	update_results("✅ Created %d biodiversity zones" % biodiversity_zones.size())

func create_biodiversity_cluster(center: Vector3, radius: float, species_count: int):
	"""Create a cluster with high species diversity"""
	GameLogger.info("🌺 Creating biodiversity cluster at %s with %d species" % [center, species_count])
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	var all_assets = []
	
	# Collect all available asset types
	all_assets += _filter_glb(asset_pack.trees)
	all_assets += _filter_glb(asset_pack.vegetation)
	all_assets += _filter_glb(asset_pack.mushrooms)
	all_assets += _filter_glb(asset_pack.stones)
	all_assets += _filter_glb(asset_pack.debris)
	
	if all_assets.size() == 0:
		GameLogger.warning("⚠️ No assets available for biodiversity cluster")
		return
	
	# Place diverse species in the cluster
	for i in range(species_count * 3):  # 3 instances per species for better visibility
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 3)
		
		if all_assets.size() == 0:
			continue
		var asset_path = all_assets[randi() % all_assets.size()]
		var inst := _instantiate_glb(asset_path)
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(0.5, 1.2)
			inst.rotation.y = randf() * TAU
			
			# Apply appropriate scaling for different asset types
			if asset_path.find("/trees/") != -1:
				inst.scale = Vector3.ONE * randf_range(0.8, 1.3)
			elif asset_path.find("/vegetation/") != -1:
				inst.scale = Vector3.ONE * randf_range(0.6, 1.2)
			
			inst.name = "biodiversity_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)
	
	GameLogger.info("✅ Created biodiversity cluster with %d asset instances" % (species_count * 3))

func _on_test_biome_transitions():
	"""Test biome transition areas"""
	GameLogger.info("🌿 BUTTON CLICKED: Test Biome Transitions")
	
	# Create transition zones between different biomes
	create_forest_to_river_transition(Vector3(150, 4, 50))
	create_lowland_to_highland_transition(Vector3(0, 20, -100))
	create_dense_to_clearing_transition(Vector3(-150, 8, 50))
	
	update_results("✅ Created biome transition zones")

func create_forest_to_river_transition(center: Vector3):
	"""Create a transition zone from dense forest to river"""
	GameLogger.info("🌊 Creating forest-to-river transition at %s" % center)
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	var vegetation = _filter_glb(asset_pack.vegetation)
	var trees = _filter_glb(asset_pack.trees)
	
	# Create a gradient from dense to sparse vegetation
	for i in range(50):
		var angle = randf() * TAU
		var distance = randf() * 30  # Smaller radius for transition
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 2)
		
		# Reduce density as we move away from center
		var density_factor = 1.0 - (distance / 30.0)
		if randf() > density_factor * 0.8:
			continue
		
		var asset_path = ""
		if vegetation.size() > 0:
			asset_path = vegetation[randi() % vegetation.size()]
		elif trees.size() > 0:
			asset_path = trees[randi() % trees.size()]
		else:
			continue
		var inst := _instantiate_glb(asset_path)
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(0.4, 0.9)
			inst.rotation.y = randf() * TAU
			inst.name = "transition_forest_river_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)
	
	GameLogger.info("✅ Created forest-to-river transition zone")

func create_lowland_to_highland_transition(center: Vector3):
	"""Create a transition zone from lowland to highland"""
	GameLogger.info("⛰️ Creating lowland-to-highland transition at %s" % center)
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	var trees = _filter_glb(asset_pack.trees)
	var stones = _filter_glb(asset_pack.stones)
	
	# Create elevation-based transition
	for i in range(40):
		var angle = randf() * TAU
		var distance = randf() * 25
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Increase elevation towards the center
		var elevation_factor = distance / 25.0
		pos.y = center.y + (elevation_factor * 15) + randf_range(-2, 3)
		
		# Choose asset based on elevation
		var asset_path = ""
		if elevation_factor < 0.5 and trees.size() > 0:
			asset_path = trees[randi() % trees.size()]
		elif stones.size() > 0:
			asset_path = stones[randi() % stones.size()]
		else:
			continue
		
		var inst := _instantiate_glb(asset_path)
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(0.6, 1.3)
			inst.rotation.y = randf() * TAU
			inst.name = "transition_lowland_highland_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)
	
	GameLogger.info("✅ Created lowland-to-highland transition zone")

func create_dense_to_clearing_transition(center: Vector3):
	"""Create a transition zone from dense forest to clearing"""
	GameLogger.info("🌳 Creating dense-to-clearing transition at %s" % center)
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	var vegetation = _filter_glb(asset_pack.vegetation)
	var debris = _filter_glb(asset_pack.debris)
	
	# Create density gradient
	for i in range(35):
		var angle = randf() * TAU
		var distance = randf() * 20
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-0.5, 1.5)
		
		# Reduce density towards center (clearing)
		var density_factor = distance / 20.0
		if randf() > density_factor * 0.7:
			continue
		
		# Prefer debris near clearing center
		var asset_path = ""
		if distance < 10 and debris.size() > 0:
			asset_path = debris[randi() % debris.size()]
		elif vegetation.size() > 0:
			asset_path = vegetation[randi() % vegetation.size()]
		else:
			continue
		
		var inst := _instantiate_glb(asset_path)
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(0.3, 0.8)
			inst.rotation.y = randf() * TAU
			inst.name = "transition_dense_clearing_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)
	
	GameLogger.info("✅ Created dense-to-clearing transition zone")

func generate_forest_zone(center: Vector3, radius: float, zone_type: String):
	"""Generate a specific type of forest zone"""
	GameLogger.info("🌲 Generating %s forest zone at %s" % [zone_type, center])
	
	var asset_pack = asset_placer.get_meta("asset_pack")
	if not asset_pack:
		return
	
	match zone_type:
		"dense_tropical":
			place_dense_tropical_forest(center, radius)
		"riverine":
			place_riverine_forest(center, radius)
		"highland":
			place_highland_forest(center, radius)
		"clearing":
			place_forest_clearing(center, radius)

func place_dense_tropical_forest(center: Vector3, radius: float):
	"""Place dense tropical forest vegetation (GLB models only)"""
	var asset_pack = asset_placer.get_meta("asset_pack")
	var trees = _filter_glb(asset_pack.trees)
	var vegetation = _filter_glb(asset_pack.vegetation)
	
	for i in range(80):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-2, 5)
		if randf() < 0.6 and trees.size() > 0:
			place_asset_at_position(trees[randi() % trees.size()], pos, "tree")
		elif vegetation.size() > 0:
			place_asset_at_position(vegetation[randi() % vegetation.size()], pos, "vegetation")

func place_riverine_forest(center: Vector3, radius: float):
	"""Place riverine forest with water-loving plants (GLB only)"""
	var asset_pack = asset_placer.get_meta("asset_pack")
	var vegetation = _filter_glb(asset_pack.vegetation)
	for i in range(50):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 3)
		if vegetation.size() > 0:
			place_asset_at_position(vegetation[randi() % vegetation.size()], pos, "vegetation")

func place_highland_forest(center: Vector3, radius: float):
	"""Place highland forest with adapted species (GLB only)"""
	var asset_pack = asset_placer.get_meta("asset_pack")
	var trees = _filter_glb(asset_pack.trees)
	var stones = _filter_glb(asset_pack.stones)
	for i in range(40):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-3, 8)
		if randf() < 0.5 and stones.size() > 0:
			place_asset_at_position(stones[randi() % stones.size()], pos, "stone")
		elif randf() < 0.3 and trees.size() > 0:
			place_asset_at_position(trees[randi() % trees.size()], pos, "tree")

func place_forest_clearing(center: Vector3, radius: float):
	"""Place forest clearing with sparse vegetation (GLB only)"""
	var asset_pack = asset_placer.get_meta("asset_pack")
	var vegetation = _filter_glb(asset_pack.vegetation)
	var debris = _filter_glb(asset_pack.debris)
	for i in range(20):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 2)
		if randf() < 0.7 and vegetation.size() > 0:
			place_asset_at_position(vegetation[randi() % vegetation.size()], pos, "vegetation")
		elif debris.size() > 0:
			place_asset_at_position(debris[randi() % debris.size()], pos, "debris")

func place_tropical_vegetation(center: Vector3, radius: float):
	"""Place diverse tropical vegetation (GLB only)"""
	GameLogger.info("🌿 Placing tropical vegetation cluster")
	var asset_pack = asset_placer.get_meta("asset_pack")
	var vegetation = _filter_glb(asset_pack.vegetation)
	for i in range(60):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 3)
		if vegetation.size() > 0:
			place_asset_at_position(vegetation[randi() % vegetation.size()], pos, "vegetation")

func place_vegetation_groves(center: Vector3, radius: float):
	"""Place vegetation groves (using jungle trees and vegetation)"""
	GameLogger.info("🌿 Placing vegetation groves")
	var asset_pack = asset_placer.get_meta("asset_pack")
	var trees = _filter_glb(asset_pack.trees)
	var vegetation = _filter_glb(asset_pack.vegetation)
	
	if trees.size() == 0 and vegetation.size() == 0:
		GameLogger.warning("⚠️ No GLB trees or vegetation found; skipping")
		return
		
	for i in range(30):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(0, 2)
		
		var asset_path = ""
		if randf() < 0.4 and trees.size() > 0:
			asset_path = trees[randi() % trees.size()]
		elif vegetation.size() > 0:
			asset_path = vegetation[randi() % vegetation.size()]
		else:
			continue
			
		var inst := _instantiate_glb(asset_path)
		if inst != null:
			inst.position = pos
			inst.scale = Vector3.ONE * randf_range(0.6, 1.2)
			inst.name = "jungle_vegetation_" + str(asset_placer.get_child_count())
			asset_placer.add_child(inst)

func _instantiate_glb(path: String) -> Node3D:
	# Check if file exists first
	var file_check = FileAccess.open(path, FileAccess.READ)
	if not file_check:
		GameLogger.error("❌ File not found: %s" % path)
		return null
	file_check.close()
	
	var scene := load(path)
	if scene == null:
		GameLogger.error("❌ Failed to load GLB: %s" % path)
		return null
	var node: Node = scene.instantiate()
	if node is Node3D:
		return node as Node3D
	return null

# Override place_asset_at_position to block non-GLB and enforce Shared root
func place_asset_at_position(asset_path: String, position: Vector3, asset_type: String):
	if not (asset_path.to_lower().ends_with(".glb") and asset_path.begins_with(SHARED_ROOT)):
		GameLogger.warning("⛔ Skipping non-GLB or non-Shared asset: %s" % asset_path)
		return
	var inst := _instantiate_glb(asset_path)
	if inst == null:
		return
	inst.position = position
	inst.rotation.y = randf() * TAU
	var scale_factor = 1.0
	match asset_type:
		"tree":
			scale_factor = randf_range(0.8, 1.3)
		"vegetation":
			scale_factor = randf_range(0.6, 1.2)
		"mushroom":
			scale_factor = randf_range(0.4, 0.8)
		_:
			scale_factor = randf_range(0.7, 1.1)
	inst.scale = Vector3.ONE * scale_factor
	inst.name = asset_type + "_" + str(asset_placer.get_child_count())
	asset_placer.add_child(inst)

func count_assets_by_type() -> Dictionary:
	"""Count assets by type"""
	var counts = {}
	
	for child in asset_placer.get_children():
		var asset_name = child.name.to_lower()
		
		if "tree" in asset_name:
			counts["trees"] = counts.get("trees", 0) + 1
		elif "vegetation" in asset_name:
			counts["vegetation"] = counts.get("vegetation", 0) + 1
		elif "fern" in asset_name:
			counts["ferns"] = counts.get("ferns", 0) + 1
		elif "tropical" in asset_name or "vegetation" in asset_name:
			counts["tropical"] = counts.get("tropical", 0) + 1
		elif "mushroom" in asset_name:
			counts["mushrooms"] = counts.get("mushrooms", 0) + 1
		elif "debris" in asset_name:
			counts["debris"] = counts.get("debris", 0) + 1
	
	return counts

func debug_forest_test():
	"""Debug function for forest testing"""
	GameLogger.info("🔧 DEBUG: Testing Papua forest functionality")
	
	var camera = get_node_or_null("TestCamera")
	if camera:
		GameLogger.info("📷 Camera position: " + str(camera.global_position))
	
	var total_assets = asset_placer.get_child_count()
	GameLogger.info("🌴 Total forest assets: " + str(total_assets))
	
	if total_assets > 0:
		GameLogger.info("🎯 Sample asset positions:")
		for i in range(min(5, total_assets)):
			var asset = asset_placer.get_child(i)
			GameLogger.info("   " + asset.name + " at " + str(asset.global_position))

func update_results(text: String):
	"""Update the results display"""
	var results_label = get_node_or_null("UI/TestPanel/VBoxContainer/ResultsLabel")
	if results_label:
		results_label.text = text
	GameLogger.info(text)

func clear_placed_assets():
	GameLogger.info("🧹 Clearing placed assets and debug markers...")
	var to_remove: Array[Node] = []
	for child in get_children():
		if child == asset_placer:
			# clear placer children
			for a in asset_placer.get_children():
				to_remove.append(a)
		elif child is CSGShape3D or child.name.ends_with("Marker") or child.name.begins_with("Trail"):
			to_remove.append(child)
	for n in to_remove:
		if n.get_parent():
			n.get_parent().remove_child(n)
			n.queue_free()
	GameLogger.info("✅ Cleared %d nodes" % to_remove.size())

func _input(event):
	"""Handle input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
			KEY_1:
				_on_ground_view()
			KEY_2:
				_on_canopy_view()
			KEY_F:
				_on_test_forest_generation()
			KEY_T:
				_on_test_tropical_asset_placement()
			KEY_E:
				_on_test_ecosystem_simulation()
			KEY_C:
				clear_placed_assets()

func place_tropical_trees(center: Vector3, radius: float):
	"""Place tropical trees (GLB-only from Shared)"""
	var asset_pack = asset_placer.get_meta("asset_pack")
	var trees := _filter_glb(asset_pack.trees)
	if trees.size() == 0:
		GameLogger.warning("⚠️ No GLB trees found under Shared. Update psx_assets to reference Shared GLB, or copy models to Shared.")
		return
	for i in range(25):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-2, 5)
		place_asset_at_position(trees[randi() % trees.size()], pos, "tree")

func verify_asset_files(asset_pack: Resource) -> void:
	"""Verify that all assets in the asset pack actually exist on disk"""
	GameLogger.info("🔍 Verifying asset files exist...")
	
	var all_assets = []
	all_assets += asset_pack.trees
	all_assets += asset_pack.vegetation
	all_assets += asset_pack.mushrooms
	all_assets += asset_pack.stones
	all_assets += asset_pack.debris
	
	var missing_files: Array[String] = []
	var valid_files: Array[String] = []
	
	for asset_path in all_assets:
		if typeof(asset_path) == TYPE_STRING:
			var file_check = FileAccess.open(asset_path, FileAccess.READ)
			if file_check:
				valid_files.append(asset_path)
				file_check.close()
			else:
				missing_files.append(asset_path)
	
	GameLogger.info("📊 Asset Verification Results:")
	GameLogger.info("   ✅ Valid files: %d" % valid_files.size())
	GameLogger.info("   ❌ Missing files: %d" % missing_files.size())
	
	if missing_files.size() > 0:
		GameLogger.warning("⚠️ Missing asset files:")
		for missing in missing_files:
			GameLogger.warning("   ❌ %s" % missing)
	
	if valid_files.size() > 0:
		GameLogger.info("✅ All valid assets ready for placement")

func _find_glb_recursive(root_dir: String) -> Array[String]:
	var results: Array[String] = []
	var dir := DirAccess.open(root_dir)
	if dir == null:
		return results
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next(); continue
		var full := root_dir.path_join(name)
		if dir.current_is_dir():
			results += _find_glb_recursive(full)
		else:
			if name.to_lower().ends_with(".glb"):
				results.append(full)
		name = dir.get_next()
	dir.list_dir_end()
	return results

func place_shared_psx_misc(center: Vector3, radius: float, max_count: int = 100):
	"""Scatter a mix of Shared psx_models/*.glb (all categories)."""
	var all_glb := _find_glb_recursive(SHARED_PSX_MODELS)
	# Filter all GLB assets for placement
	var filtered: Array[String] = []
	for p in all_glb:
		var s: String = p
		filtered.append(s)
	if filtered.size() == 0:
		GameLogger.warning("⚠️ No Shared psx_models GLB found to place")
		return
	var count: int = min(max_count, 150)
	for i in range(count):
		var angle = randf() * TAU
		var distance = randf() * radius
		var pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		pos.y = center.y + randf_range(-1, 3)
		if filtered.size() > 0:
			place_asset_at_position(filtered[randi() % filtered.size()], pos, "misc")
