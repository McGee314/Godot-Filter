extends Node3D
class_name ProceduralAssetPlacer

# Procedural Asset Placer for Tambora Hiking Trail
# Places PSX assets procedurally based on terrain profiles and trail positions

signal asset_placed(asset_type: String, position: Vector3)

@export var placement_density: float = 0.3  # Overall placement density
@export var max_assets_per_segment: int = 5  # Maximum assets per trail segment
@export var placement_radius: float = 10.0  # Radius around trail for asset placement

var psx_asset_pack: PSXAssetPack
var placed_assets: Array[Node3D] = []
var random_seed_value: int = 42

func _ready():
	GameLogger.info("Initializing Procedural Asset Placer")
	
	# Load Tambora PSX asset pack
	psx_asset_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if not psx_asset_pack:
		GameLogger.error("Failed to load Tambora PSX asset pack")
		return
	
	GameLogger.info("Loaded PSX asset pack: %s" % psx_asset_pack.region_name)

func place_tree(pos: Vector3, tree_type: String = "pine"):
	"""Place a tree at the specified position"""
	if not psx_asset_pack:
		return
	
	var tree_assets = psx_asset_pack.get_assets_by_category("trees")
	if tree_assets.size() == 0:
		GameLogger.warning("No tree assets available")
		return
	
	# Select random tree asset
	var tree_path = tree_assets[randi() % tree_assets.size()]
	var tree_scene = load(tree_path)
	
	if tree_scene:
		var tree_instance = tree_scene.instantiate()
		add_child(tree_instance)
		tree_instance.position = pos
		
		# Add random rotation and scale variation
		tree_instance.rotation.y = randf() * TAU
		var scale_factor = 0.8 + randf() * 0.4  # 0.8 to 1.2 scale
		tree_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		placed_assets.append(tree_instance)
		asset_placed.emit("tree", pos)
		
		GameLogger.debug("Placed tree at %s" % pos)

func place_vegetation(pos: Vector3, vegetation_type: String = "grass"):
	"""Place vegetation at the specified position"""
	if not psx_asset_pack:
		return
	
	var vegetation_assets = psx_asset_pack.get_assets_by_category("vegetation")
	if vegetation_assets.size() == 0:
		GameLogger.warning("No vegetation assets available")
		return
	
	# Filter by vegetation type if specified
	var filtered_assets = []
	for asset_path in vegetation_assets:
		if vegetation_type == "grass" and "grass" in asset_path:
			filtered_assets.append(asset_path)
		elif vegetation_type == "ferns" and "fern" in asset_path:
			filtered_assets.append(asset_path)
	
	if filtered_assets.size() == 0:
		filtered_assets = vegetation_assets  # Use all if no specific type found
	
	# Select random vegetation asset
	var veg_path = filtered_assets[randi() % filtered_assets.size()]
	var veg_scene = load(veg_path)
	
	if veg_scene:
		var veg_instance = veg_scene.instantiate()
		add_child(veg_instance)
		veg_instance.position = pos
		
		# Add random rotation and slight position variation
		veg_instance.rotation.y = randf() * TAU
		veg_instance.position += Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
		
		placed_assets.append(veg_instance)
		asset_placed.emit("vegetation", pos)
		
		GameLogger.debug("Placed vegetation at %s" % pos)

func place_stone(pos: Vector3):
	"""Place a stone at the specified position"""
	if not psx_asset_pack:
		return
	
	var stone_assets = psx_asset_pack.get_assets_by_category("stones")
	if stone_assets.size() == 0:
		GameLogger.warning("No stone assets available")
		return
	
	# Select random stone asset
	var stone_path = stone_assets[randi() % stone_assets.size()]
	var stone_scene = load(stone_path)
	
	if stone_scene:
		var stone_instance = stone_scene.instantiate()
		add_child(stone_instance)
		stone_instance.position = pos
		
		# Add random rotation and scale variation
		stone_instance.rotation.y = randf() * TAU
		stone_instance.rotation.x = randf_range(-0.2, 0.2)
		stone_instance.rotation.z = randf_range(-0.2, 0.2)
		
		var scale_factor = 0.7 + randf() * 0.6  # 0.7 to 1.3 scale
		stone_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		placed_assets.append(stone_instance)
		asset_placed.emit("stone", pos)
		
		GameLogger.debug("Placed stone at %s" % pos)

func place_debris(pos: Vector3):
	"""Place debris at the specified position"""
	if not psx_asset_pack:
		return
	
	var debris_assets = psx_asset_pack.get_assets_by_category("debris")
	if debris_assets.size() == 0:
		GameLogger.warning("No debris assets available")
		return
	
	# Select random debris asset
	var debris_path = debris_assets[randi() % debris_assets.size()]
	var debris_scene = load(debris_path)
	
	if debris_scene:
		var debris_instance = debris_scene.instantiate()
		add_child(debris_instance)
		debris_instance.position = pos
		
		# Add random rotation and scale variation
		debris_instance.rotation.y = randf() * TAU
		debris_instance.rotation.x = randf_range(-0.3, 0.3)
		debris_instance.rotation.z = randf_range(-0.3, 0.3)
		
		var scale_factor = 0.8 + randf() * 0.4  # 0.8 to 1.2 scale
		debris_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		placed_assets.append(debris_instance)
		asset_placed.emit("debris", pos)
		
		GameLogger.debug("Placed debris at %s" % pos)

func place_mushroom(pos: Vector3):
	"""Place a mushroom at the specified position"""
	if not psx_asset_pack:
		return
	
	var mushroom_assets = psx_asset_pack.get_assets_by_category("mushrooms")
	if mushroom_assets.size() == 0:
		GameLogger.warning("No mushroom assets available")
		return
	
	# Select random mushroom asset
	var mushroom_path = mushroom_assets[randi() % mushroom_assets.size()]
	var mushroom_scene = load(mushroom_path)
	
	if mushroom_scene:
		var mushroom_instance = mushroom_scene.instantiate()
		add_child(mushroom_instance)
		mushroom_instance.position = pos
		
		# Add random rotation and scale variation
		mushroom_instance.rotation.y = randf() * TAU
		var scale_factor = 0.6 + randf() * 0.8  # 0.6 to 1.4 scale
		mushroom_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		placed_assets.append(mushroom_instance)
		asset_placed.emit("mushroom", pos)
		
		GameLogger.debug("Placed mushroom at %s" % pos)

func place_assets_in_area(center: Vector3, radius: float, profile: Dictionary):
	"""Place assets in a circular area based on terrain profile"""
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed_value
	
	# Calculate number of assets to place based on density
	var area = PI * radius * radius
	var max_assets = int(area * profile.get("vegetation_density", 0.5) * placement_density)
	max_assets = min(max_assets, max_assets_per_segment)
	
	for i in range(max_assets):
		# Generate random position within radius
		var angle = rng.randf() * TAU
		var distance = rng.randf() * radius
		var offset = Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		var asset_position = center + offset
		
		# Determine asset type based on profile
		var asset_choice = rng.randf()
		
		if asset_choice < 0.3 and profile.get("tree_types", []).size() > 0:
			var tree_type = profile.tree_types[rng.randi() % profile.tree_types.size()]
			place_tree(asset_position, tree_type)
		elif asset_choice < 0.6 and profile.get("ground_cover", []).size() > 0:
			var cover_type = profile.ground_cover[rng.randi() % profile.ground_cover.size()]
			place_vegetation(asset_position, cover_type)
		elif asset_choice < 0.8 and profile.get("rock_density", 0.0) > 0.3:
			place_stone(asset_position)
		elif asset_choice < 0.9 and profile.get("debris_density", 0.0) > 0.3:
			place_debris(asset_position)
		else:
			place_mushroom(asset_position)
	
	random_seed_value += 1

func clear_assets():
	"""Clear all placed assets"""
	GameLogger.info("Clearing %d placed assets" % placed_assets.size())
	
	for asset in placed_assets:
		if is_instance_valid(asset):
			asset.queue_free()
	
	placed_assets.clear()

func get_asset_count() -> int:
	"""Get total number of placed assets"""
	return placed_assets.size()

func get_asset_count_by_type() -> Dictionary:
	"""Get count of assets by type"""
	var counts = {
		"trees": 0,
		"vegetation": 0,
		"stones": 0,
		"debris": 0,
		"mushrooms": 0
	}
	
	for asset in placed_assets:
		if is_instance_valid(asset):
			var asset_name = asset.name.to_lower()
			if "tree" in asset_name:
				counts.trees += 1
			elif "grass" in asset_name or "fern" in asset_name:
				counts.vegetation += 1
			elif "stone" in asset_name:
				counts.stones += 1
			elif "log" in asset_name or "stump" in asset_name:
				counts.debris += 1
			elif "mushroom" in asset_name:
				counts.mushrooms += 1
	
	return counts

func set_random_seed(seed_value: int):
	"""Set random seed for consistent placement"""
	random_seed_value = seed_value
	GameLogger.info("Set random seed to %d" % seed_value)

# =====================================================================
# ENHANCED PROCEDURAL PLACEMENT ALGORITHMS
# =====================================================================

func place_assets_with_poisson_disk(center: Vector3, radius: float, min_distance: float, profile: Dictionary):
	"""Place assets using Poisson disk sampling for natural distribution"""
	GameLogger.info("Placing assets using Poisson disk sampling")
	
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed_value
	
	var points = []
	var active_list = []
	var grid_size = min_distance / sqrt(2)
	var grid_width = int(radius * 2 / grid_size) + 1
	var grid_height = int(radius * 2 / grid_size) + 1
	var grid = []
	
	# Initialize grid
	for i in range(grid_width):
		grid.append([])
		for j in range(grid_height):
			grid[i].append(-1)
	
	# Generate initial point
	var initial_point = center + Vector3(rng.randf_range(-radius/4, radius/4), 0, rng.randf_range(-radius/4, radius/4))
	points.append(initial_point)
	active_list.append(0)
	
	var grid_x = int((initial_point.x - center.x + radius) / grid_size)
	var grid_z = int((initial_point.z - center.z + radius) / grid_size)
	if grid_x >= 0 and grid_x < grid_width and grid_z >= 0 and grid_z < grid_height:
		grid[grid_x][grid_z] = 0
	
	# Generate points
	while active_list.size() > 0:
		var random_index = rng.randi() % active_list.size()
		var point_index = active_list[random_index]
		var point = points[point_index]
		var found = false
		
		for attempt in range(30):  # Max attempts per point
			var angle = rng.randf() * TAU
			var distance = rng.randf_range(min_distance, 2 * min_distance)
			var new_point = point + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
			
			# Check if point is within radius
			if new_point.distance_to(center) > radius:
				continue
			
			# Check grid for conflicts
			var new_grid_x = int((new_point.x - center.x + radius) / grid_size)
			var new_grid_z = int((new_point.z - center.z + radius) / grid_size)
			
			if new_grid_x < 0 or new_grid_x >= grid_width or new_grid_z < 0 or new_grid_z >= grid_height:
				continue
			
			var valid = true
			for dx in range(-2, 3):
				for dz in range(-2, 3):
					var check_x = new_grid_x + dx
					var check_z = new_grid_z + dz
					if check_x >= 0 and check_x < grid_width and check_z >= 0 and check_z < grid_height:
						if grid[check_x][check_z] != -1:
							var existing_point = points[grid[check_x][check_z]]
							if existing_point.distance_to(new_point) < min_distance:
								valid = false
								break
				if not valid:
					break
			
			if valid:
				points.append(new_point)
				active_list.append(points.size() - 1)
				grid[new_grid_x][new_grid_z] = points.size() - 1
				found = true
				break
		
		if not found:
			active_list.remove_at(random_index)
	
	# Place assets at generated points
	for point in points:
		var asset_choice = rng.randf()
		if asset_choice < 0.4 and profile.get("tree_types", []).size() > 0:
			var tree_type = profile.tree_types[rng.randi() % profile.tree_types.size()]
			place_tree(point, tree_type)
		elif asset_choice < 0.7 and profile.get("ground_cover", []).size() > 0:
			var cover_type = profile.ground_cover[rng.randi() % profile.ground_cover.size()]
			place_vegetation(point, cover_type)
		else:
			place_stone(point)
	
	random_seed_value += 1
	GameLogger.info("Placed %d assets using Poisson disk sampling" % points.size())

func place_assets_with_noise_field(center: Vector3, radius: float, profile: Dictionary, noise_scale: float = 0.01):
	"""Place assets using noise field for organic distribution patterns"""
	GameLogger.info("Placing assets using noise field distribution")
	
	var noise = FastNoiseLite.new()
	noise.seed = random_seed_value
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale
	
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed_value
	
	# Generate candidate positions in a grid
	var grid_resolution = 20
	var step = radius * 2 / grid_resolution
	
	for i in range(grid_resolution):
		for j in range(grid_resolution):
			var x = center.x - radius + i * step
			var z = center.z - radius + j * step
			var candidate_pos = Vector3(x, center.y, z)
			
			# Skip if outside radius
			if candidate_pos.distance_to(center) > radius:
				continue
			
			# Sample noise to determine placement probability
			var noise_value = noise.get_noise_2d(x, z)
			var normalized_noise = (noise_value + 1.0) / 2.0  # 0 to 1
			
			# Use different thresholds for different asset types
			var tree_threshold = 1.0 - profile.get("vegetation_density", 0.5) * 0.5
			var rock_threshold = 1.0 - profile.get("rock_density", 0.3) * 0.7
			
			if normalized_noise > tree_threshold and profile.get("tree_types", []).size() > 0:
				var tree_type = profile.tree_types[rng.randi() % profile.tree_types.size()]
				place_tree(candidate_pos, tree_type)
			elif normalized_noise > rock_threshold:
				place_stone(candidate_pos)
			elif normalized_noise > 0.3 and profile.get("ground_cover", []).size() > 0:
				var cover_type = profile.ground_cover[rng.randi() % profile.ground_cover.size()]
				place_vegetation(candidate_pos, cover_type)
	
	random_seed_value += 1

func place_assets_in_clusters(center: Vector3, radius: float, profile: Dictionary, cluster_count: int = 5):
	"""Place assets in natural clusters"""
	GameLogger.info("Placing assets in %d clusters" % cluster_count)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed_value
	
	for cluster_id in range(cluster_count):
		# Generate cluster center
		var angle = rng.randf() * TAU
		var distance = rng.randf() * radius * 0.8
		var cluster_center = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		var cluster_radius = rng.randf_range(5.0, 15.0)
		
		# Determine cluster type
		var cluster_type = choose_cluster_type(profile, rng)
		var assets_in_cluster = rng.randi_range(3, 8)
		
		for asset_id in range(assets_in_cluster):
			var asset_angle = rng.randf() * TAU
			var asset_distance = rng.randf() * cluster_radius
			var asset_pos = cluster_center + Vector3(cos(asset_angle) * asset_distance, 0, sin(asset_angle) * asset_distance)
			
			# Place asset based on cluster type
			match cluster_type:
				"tree_grove":
					if profile.get("tree_types", []).size() > 0:
						var tree_type = profile.tree_types[rng.randi() % profile.tree_types.size()]
						place_tree(asset_pos, tree_type)
				"rock_formation":
					place_stone(asset_pos)
				"vegetation_patch":
					if profile.get("ground_cover", []).size() > 0:
						var cover_type = profile.ground_cover[rng.randi() % profile.ground_cover.size()]
						place_vegetation(asset_pos, cover_type)
				"debris_area":
					place_debris(asset_pos)
	
	random_seed_value += 1

func choose_cluster_type(profile: Dictionary, rng: RandomNumberGenerator) -> String:
	"""Choose cluster type based on terrain profile"""
	var total_weight = 0.0
	var weights = {}
	
	if profile.get("tree_types", []).size() > 0:
		weights["tree_grove"] = profile.get("vegetation_density", 0.5)
		total_weight += weights["tree_grove"]
	
	weights["rock_formation"] = profile.get("rock_density", 0.3)
	total_weight += weights["rock_formation"]
	
	if profile.get("ground_cover", []).size() > 0:
		weights["vegetation_patch"] = profile.get("vegetation_density", 0.5) * 0.8
		total_weight += weights["vegetation_patch"]
	
	weights["debris_area"] = profile.get("debris_density", 0.2)
	total_weight += weights["debris_area"]
	
	var random_value = rng.randf() * total_weight
	var current_weight = 0.0
	
	for cluster_type in weights:
		current_weight += weights[cluster_type]
		if random_value <= current_weight:
			return cluster_type
	
	return "rock_formation"  # Fallback

func place_assets_along_spline(spline_points: PackedVector3Array, spacing: float, profile: Dictionary, spread_radius: float = 5.0):
	"""Place assets along a spline path (like rivers or roads)"""
	GameLogger.info("Placing assets along spline with %d points" % spline_points.size())
	
	if spline_points.size() < 2:
		GameLogger.warning("Need at least 2 spline points")
		return
	
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed_value
	
	var total_distance = 0.0
	var distances = [0.0]
	
	# Calculate cumulative distances
	for i in range(1, spline_points.size()):
		var segment_distance = spline_points[i-1].distance_to(spline_points[i])
		total_distance += segment_distance
		distances.append(total_distance)
	
	# Place assets at regular intervals
	var current_distance = 0.0
	while current_distance < total_distance:
		var position = interpolate_spline_position(spline_points, distances, current_distance)
		
		# Add some perpendicular spread
		var direction = get_spline_direction(spline_points, distances, current_distance)
		var perpendicular = Vector3(-direction.z, 0, direction.x).normalized()
		var side_offset = rng.randf_range(-spread_radius, spread_radius)
		var final_position = position + perpendicular * side_offset
		
		# Choose asset type based on distance from path
		var distance_from_path = abs(side_offset)
		if distance_from_path < spread_radius * 0.3:
			# Close to path - place smaller vegetation or markers
			if profile.get("ground_cover", []).size() > 0:
				var cover_type = profile.ground_cover[rng.randi() % profile.ground_cover.size()]
				place_vegetation(final_position, cover_type)
		elif distance_from_path < spread_radius * 0.7:
			# Medium distance - place trees or rocks
			if rng.randf() < 0.6 and profile.get("tree_types", []).size() > 0:
				var tree_type = profile.tree_types[rng.randi() % profile.tree_types.size()]
				place_tree(final_position, tree_type)
			else:
				place_stone(final_position)
		else:
			# Far from path - place larger features
			if profile.get("tree_types", []).size() > 0:
				var tree_type = profile.tree_types[rng.randi() % profile.tree_types.size()]
				place_tree(final_position, tree_type)
		
		current_distance += spacing
	
	random_seed_value += 1

func interpolate_spline_position(points: PackedVector3Array, distances: Array, target_distance: float) -> Vector3:
	"""Interpolate position along spline at given distance"""
	for i in range(distances.size() - 1):
		if target_distance <= distances[i + 1]:
			var segment_start = distances[i]
			var segment_end = distances[i + 1]
			var segment_progress = (target_distance - segment_start) / (segment_end - segment_start)
			return points[i].lerp(points[i + 1], segment_progress)
	
	return points[-1]  # Return last point if beyond spline

func get_spline_direction(points: PackedVector3Array, distances: Array, target_distance: float) -> Vector3:
	"""Get direction vector along spline at given distance"""
	for i in range(distances.size() - 1):
		if target_distance <= distances[i + 1]:
			return (points[i + 1] - points[i]).normalized()
	
	return (points[-1] - points[-2]).normalized()

func place_ecosystem_driven_assets(center: Vector3, radius: float, profile: Dictionary):
	"""Place assets using ecosystem rules (predator-prey, resource competition)"""
	GameLogger.info("Placing assets using ecosystem-driven placement")
	
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed_value
	
	# Define ecosystem relationships
	var ecosystem = {
		"primary_producers": ["trees"],  # Large trees
		"secondary_vegetation": ["vegetation"],  # Ground cover
		"decomposers": ["mushrooms"],  # Mushrooms near debris
		"geological": ["stones", "debris"]  # Rocks and fallen logs
	}
	
	# First pass: Place primary producers (trees)
	var tree_positions = []
	if profile.get("tree_types", []).size() > 0:
		var tree_count = int(radius * radius * profile.get("vegetation_density", 0.5) * 0.02)
		for i in range(tree_count):
			var angle = rng.randf() * TAU
			var distance = rng.randf() * radius
			var tree_pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
			
			# Check minimum distance from other trees
			var min_tree_distance = 8.0
			var valid_position = true
			for existing_pos in tree_positions:
				if tree_pos.distance_to(existing_pos) < min_tree_distance:
					valid_position = false
					break
			
			if valid_position:
				tree_positions.append(tree_pos)
				var tree_type = profile.tree_types[rng.randi() % profile.tree_types.size()]
				place_tree(tree_pos, tree_type)
	
	# Second pass: Place secondary vegetation around trees
	for tree_pos in tree_positions:
		var vegetation_count = rng.randi_range(2, 5)
		for i in range(vegetation_count):
			var angle = rng.randf() * TAU
			var distance = rng.randf_range(3.0, 6.0)  # Ring around tree
			var veg_pos = tree_pos + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
			
			if profile.get("ground_cover", []).size() > 0:
				var cover_type = profile.ground_cover[rng.randi() % profile.ground_cover.size()]
				place_vegetation(veg_pos, cover_type)
	
	# Third pass: Place geological features
	var rock_count = int(radius * radius * profile.get("rock_density", 0.3) * 0.01)
	for i in range(rock_count):
		var angle = rng.randf() * TAU
		var distance = rng.randf() * radius
		var rock_pos = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Avoid placing too close to trees
		var valid_position = true
		for tree_pos in tree_positions:
			if rock_pos.distance_to(tree_pos) < 4.0:
				valid_position = false
				break
		
		if valid_position:
			if rng.randf() < 0.7:
				place_stone(rock_pos)
			else:
				place_debris(rock_pos)
				
				# Place mushrooms near debris (decomposer relationship)
				if rng.randf() < 0.4:
					var mushroom_angle = rng.randf() * TAU
					var mushroom_distance = rng.randf_range(1.0, 3.0)
					var mushroom_pos = rock_pos + Vector3(cos(mushroom_angle) * mushroom_distance, 0, sin(mushroom_angle) * mushroom_distance)
					place_mushroom(mushroom_pos)
	
	random_seed_value += 1
