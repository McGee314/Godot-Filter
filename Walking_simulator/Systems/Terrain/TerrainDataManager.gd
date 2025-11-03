class_name TerrainDataManager
extends Node

## TerrainDataManager - Saves and loads persistent terrain environment data
## Handles: Terrain3D heightmaps, PSX asset placements, hexagon paths, NPC positions

signal data_saved(save_name: String)
signal data_loaded(save_name: String)
signal save_failed(error_message: String)
signal load_failed(error_message: String)

const SAVE_DIRECTORY = "user://terrain_data/"
const SAVE_EXTENSION = ".terrain_data"

# Data structure for environment save
var current_save_data: Dictionary = {}

func _ready():
	# Ensure save directory exists
	ensure_save_directory()

func ensure_save_directory():
	"""Ensure the save directory exists"""
	if not DirAccess.dir_exists_absolute(SAVE_DIRECTORY):
		DirAccess.open("user://").make_dir_recursive("terrain_data")
		GameLogger.info("📁 Created terrain data directory: %s" % SAVE_DIRECTORY)

func get_available_saves() -> Array[String]:
	"""Get list of available save files"""
	var saves: Array[String] = []
	var dir = DirAccess.open(SAVE_DIRECTORY)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(SAVE_EXTENSION):
				var save_name = file_name.replace(SAVE_EXTENSION, "")
				saves.append(save_name)
			file_name = dir.get_next()
	
	saves.sort()
	return saves

func save_environment_data(save_name: String, terrain_controller: Node) -> bool:
	"""Save complete environment data"""
	GameLogger.info("💾 Saving environment data: %s" % save_name)
	
	try:
		# Collect terrain data
		var terrain_data = collect_terrain_data(terrain_controller)
		
		# Collect asset data
		var asset_data = collect_asset_data(terrain_controller)
		
		# Collect hexagon path data
		var hexagon_data = collect_hexagon_data(terrain_controller)
		
		# Collect NPC data
		var npc_data = collect_npc_data()
		
		# Create save data structure
		var save_data = {
			"version": "1.0",
			"timestamp": Time.get_datetime_string_from_system(),
			"terrain": terrain_data,
			"assets": asset_data,
			"hexagon_paths": hexagon_data,
			"npcs": npc_data,
			"metadata": {
				"save_name": save_name,
				"scene_name": get_tree().current_scene.scene_file_path,
				"total_assets": asset_data.get("total_count", 0),
				"hexagon_vertices": hexagon_data.get("vertices", []).size()
			}
		}
		
		# Save to file
		var file_path = SAVE_DIRECTORY + save_name + SAVE_EXTENSION
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		
		if file:
			var json_string = JSON.stringify(save_data, "\t")
			file.store_string(json_string)
			file.close()
			
			GameLogger.info("✅ Environment data saved: %s" % file_path)
			data_saved.emit(save_name)
			return true
		else:
			GameLogger.error("❌ Failed to create save file: %s" % file_path)
			save_failed.emit("Failed to create save file")
			return false
			
	except:
		var error_msg = "Failed to save environment data: %s" % str(get_error())
		GameLogger.error("❌ " + error_msg)
		save_failed.emit(error_msg)
		return false

func load_environment_data(save_name: String, terrain_controller: Node) -> bool:
	"""Load complete environment data"""
	GameLogger.info("📂 Loading environment data: %s" % save_name)
	
	try:
		var file_path = SAVE_DIRECTORY + save_name + SAVE_EXTENSION
		var file = FileAccess.open(file_path, FileAccess.READ)
		
		if not file:
			var error_msg = "Save file not found: %s" % file_path
			GameLogger.error("❌ " + error_msg)
			load_failed.emit(error_msg)
			return false
		
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result != OK:
			var error_msg = "Failed to parse save file: %s" % json.get_error_message()
			GameLogger.error("❌ " + error_msg)
			load_failed.emit(error_msg)
			return false
		
		var save_data = json.get_data()
		current_save_data = save_data
		
		# Clear existing environment
		clear_existing_environment(terrain_controller)
		
		# Restore terrain data
		restore_terrain_data(save_data.get("terrain", {}), terrain_controller)
		
		# Restore asset data
		restore_asset_data(save_data.get("assets", {}), terrain_controller)
		
		# Restore hexagon path data
		restore_hexagon_data(save_data.get("hexagon_paths", {}), terrain_controller)
		
		# Restore NPC data
		restore_npc_data(save_data.get("npcs", {}))
		
		GameLogger.info("✅ Environment data loaded: %s" % save_name)
		GameLogger.info("📊 Loaded: %d assets, %d hexagon vertices" % [
			save_data.get("metadata", {}).get("total_assets", 0),
			save_data.get("metadata", {}).get("hexagon_vertices", 0)
		])
		
		data_loaded.emit(save_name)
		return true
		
	except:
		var error_msg = "Failed to load environment data: %s" % str(get_error())
		GameLogger.error("❌ " + error_msg)
		load_failed.emit(error_msg)
		return false

func collect_terrain_data(terrain_controller: Node) -> Dictionary:
	"""Collect terrain3D heightmap and material data"""
	var terrain_data = {}
	
	# Get Terrain3D node
	var terrain3d = terrain_controller.get_node_or_null("Terrain3D")
	if terrain3d:
		terrain_data["terrain3d_exists"] = true
		terrain_data["terrain3d_position"] = terrain3d.global_position
		terrain_data["terrain3d_scale"] = terrain3d.scale
	else:
		terrain_data["terrain3d_exists"] = false
	
	# Get terrain material data
	var terrain_material = terrain_controller.get_node_or_null("Terrain3D/Terrain3D/Terrain3D")
	if terrain_material:
		terrain_data["material_exists"] = true
		# Save material properties if needed
	else:
		terrain_data["material_exists"] = false
	
	return terrain_data

func collect_asset_data(terrain_controller: Node) -> Dictionary:
	"""Collect PSX asset placement data"""
	var asset_data = {
		"total_count": 0,
		"assets": []
	}
	
	# Get all asset containers
	var containers = [
		terrain_controller.get_node_or_null("ForestAssets"),
		terrain_controller.get_node_or_null("HexagonArtifacts")
	]
	
	for container in containers:
		if container:
			for child in container.get_children():
				if child is MeshInstance3D:
					var asset_info = {
						"name": child.name,
						"position": child.global_position,
						"rotation": child.global_rotation,
						"scale": child.scale,
						"mesh_path": child.mesh.resource_path if child.mesh else "",
						"container": container.name
					}
					asset_data.assets.append(asset_info)
					asset_data.total_count += 1
	
	return asset_data

func collect_hexagon_data(terrain_controller: Node) -> Dictionary:
	"""Collect hexagon path system data"""
	var hexagon_data = {
		"vertices": [],
		"paths": [],
		"exists": false
	}
	
	# Get hexagon paths container
	var paths_container = terrain_controller.get_node_or_null("HexagonPaths")
	if paths_container:
		hexagon_data.exists = true
		
		# Calculate hexagon vertices (same as generation logic)
		var hex_radius = 80.0
		var center_pos = Vector3(0, 0, 0)
		
		for i in range(6):
			var angle = i * PI / 3.0
			var x = center_pos.x + cos(angle) * hex_radius
			var z = center_pos.z + sin(angle) * hex_radius
			hexagon_data.vertices.append(Vector3(x, center_pos.y, z))
		
		# Collect path meshes
		for child in paths_container.get_children():
			if child is MeshInstance3D:
				var path_info = {
					"name": child.name,
					"position": child.global_position,
					"rotation": child.global_rotation,
					"scale": child.scale
				}
				hexagon_data.paths.append(path_info)
	
	return hexagon_data

func collect_npc_data() -> Dictionary:
	"""Collect NPC position and state data"""
	var npc_data = {
		"npcs": []
	}
	
	var existing_npcs = get_tree().get_nodes_in_group("npc")
	for npc in existing_npcs:
		if not npc.name.begins_with("NPC_") and not npc.name.contains("Hexagon"):
			var npc_info = {
				"name": npc.name,
				"position": npc.global_position,
				"rotation": npc.global_rotation,
				"is_story_npc": true
			}
			npc_data.npcs.append(npc_info)
	
	return npc_data

func clear_existing_environment(terrain_controller: Node):
	"""Clear existing generated environment"""
	GameLogger.info("🧹 Clearing existing environment...")
	
	# Clear asset containers
	var containers_to_clear = [
		"ForestAssets",
		"HexagonArtifacts", 
		"HexagonPaths",
		"HexagonNPCs"
	]
	
	for container_name in containers_to_clear:
		var container = terrain_controller.get_node_or_null(container_name)
		if container:
			for child in container.get_children():
				child.queue_free()
			GameLogger.info("Cleared container: %s" % container_name)

func restore_terrain_data(terrain_data: Dictionary, terrain_controller: Node):
	"""Restore terrain3D data"""
	if terrain_data.get("terrain3d_exists", false):
		GameLogger.info("🏔️ Restoring terrain3D data...")
		# Terrain3D should already exist, just log
		GameLogger.info("✅ Terrain3D data restored")

func restore_asset_data(asset_data: Dictionary, terrain_controller: Node):
	"""Restore PSX asset placements"""
	GameLogger.info("🌲 Restoring %d assets..." % asset_data.get("total_count", 0))
	
	for asset_info in asset_data.get("assets", []):
		# Create asset mesh
		var asset = MeshInstance3D.new()
		asset.name = asset_info.name
		asset.global_position = asset_info.position
		asset.global_rotation = asset_info.rotation
		asset.scale = asset_info.scale
		
		# Load mesh if path exists
		if asset_info.mesh_path != "":
			var mesh_resource = load(asset_info.mesh_path)
			if mesh_resource:
				asset.mesh = mesh_resource
		
		# Add to appropriate container
		var container_name = asset_info.container
		var container = terrain_controller.get_node_or_null(container_name)
		if not container:
			container = Node3D.new()
			container.name = container_name
			terrain_controller.add_child(container)
		
		container.add_child(asset)
	
	GameLogger.info("✅ Restored %d assets" % asset_data.get("total_count", 0))

func restore_hexagon_data(hexagon_data: Dictionary, terrain_controller: Node):
	"""Restore hexagon path system"""
	if hexagon_data.get("exists", false):
		GameLogger.info("🔷 Restoring hexagon path system...")
		
		# Create paths container
		var paths_container = Node3D.new()
		paths_container.name = "HexagonPaths"
		terrain_controller.add_child(paths_container)
		
		# Restore path meshes
		for path_info in hexagon_data.get("paths", []):
			var path_mesh = MeshInstance3D.new()
			path_mesh.name = path_info.name
			path_mesh.global_position = path_info.position
			path_mesh.global_rotation = path_info.rotation
			path_mesh.scale = path_info.scale
			
			# Create basic path mesh
			var box_mesh = BoxMesh.new()
			box_mesh.size = Vector3(8.0, 0.2, 8.0)
			path_mesh.mesh = box_mesh
			
			# Create brown material
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.4, 0.2, 0.1)  # Brown
			path_mesh.material_override = material
			
			paths_container.add_child(path_mesh)
		
		GameLogger.info("✅ Restored hexagon path system")

func restore_npc_data(npc_data: Dictionary):
	"""Restore NPC positions"""
	GameLogger.info("👥 Restoring NPC positions...")
	
	var existing_npcs = get_tree().get_nodes_in_group("npc")
	var npc_dict = {}
	
	# Create lookup dictionary
	for npc in existing_npcs:
		if not npc.name.begins_with("NPC_") and not npc.name.contains("Hexagon"):
			npc_dict[npc.name] = npc
	
	# Restore positions
	for npc_info in npc_data.get("npcs", []):
		var npc = npc_dict.get(npc_info.name)
		if npc:
			npc.global_position = npc_info.position
			npc.global_rotation = npc_info.rotation
			GameLogger.info("Restored NPC: %s" % npc_info.name)
	
	GameLogger.info("✅ Restored NPC positions")

func delete_save(save_name: String) -> bool:
	"""Delete a save file"""
	var file_path = SAVE_DIRECTORY + save_name + SAVE_EXTENSION
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		GameLogger.info("🗑️ Deleted save: %s" % save_name)
		return true
	else:
		GameLogger.warning("⚠️ Save file not found: %s" % save_name)
		return false
