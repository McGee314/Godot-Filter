extends Node3D

# Isolated tree test script to debug texture and UV mapping issues
# Focus on understanding why tree leaves appear as "big squares" and "sticker-like"

@onready var camera: Camera3D
@onready var tree_container: Node3D
@onready var status_label: Label

var current_tree_instance: Node3D = null
var mouse_sensitivity = 0.002
var mouse_captured = false

# Tree-specific textures
var tree_textures = {
	"pine_tree_n_1": "res://Assets/PSX/PSX Nature/textures/pine_bark_1.png",
	"pine_tree_n_2": "res://Assets/PSX/PSX Nature/textures/pine_bark_2.png",
	"pine_tree_n_3": "res://Assets/PSX/PSX Nature/textures/pine_bark_1.png"
}

func _ready():
	GameLogger.info("TreeTest: Starting isolated tree test")
	
	# Get references
	camera = get_node_or_null("Camera3D")
	tree_container = get_node_or_null("TreeContainer")
	status_label = get_node_or_null("UI/StatusLabel")
	
	GameLogger.info("TreeTest: Node references - Camera: " + str(camera != null) + ", TreeContainer: " + str(tree_container != null) + ", StatusLabel: " + str(status_label != null))
	
	if not camera or not tree_container or not status_label:
		GameLogger.error("TreeTest: Missing required nodes!")
		return
	
	# Connect button signals
	connect_button_signals()
	
	update_status("Ready! Load a tree to begin testing.")
	GameLogger.info("TreeTest: Initialization complete")

func connect_button_signals():
	"""Connect all UI button signals"""
	var button_connections = {
		"UI/ButtonContainer/LoadTree1": "load_tree_1",
		"UI/ButtonContainer/LoadTree5": "load_tree_5", 
		"UI/ButtonContainer/LoadTree6": "load_tree_6",
		"UI/ButtonContainer/ApplyOriginalTexture": "apply_original_texture",
		"UI/ButtonContainer/ApplyCustomTexture": "apply_custom_texture",
		"UI/ButtonContainer/CheckUVMapping": "check_uv_mapping",
		"UI/ButtonContainer/ResetTree": "reset_tree"
	}
	
	for button_path in button_connections:
		var button = get_node_or_null(button_path)
		if button:
			var function_name = button_connections[button_path]
			button.pressed.connect(Callable(self, function_name))
			GameLogger.info("TreeTest: Connected button " + button_path + " to function " + function_name)
		else:
			GameLogger.warning("TreeTest: Button not found: " + button_path)

func load_tree_1():
	GameLogger.info("TreeTest: Load Pine Tree 1 button pressed!")
	load_tree("pine_tree_n_1", "res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_1.glb")

func load_tree_5():
	GameLogger.info("TreeTest: Load Pine Tree 2 button pressed!")
	load_tree("pine_tree_n_2", "res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_2.glb")

func load_tree_6():
	GameLogger.info("TreeTest: Load Pine Tree 3 button pressed!")
	load_tree("pine_tree_n_3", "res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_3.glb")

func load_tree(tree_name: String, tree_path: String):
	"""Load a specific tree model"""
	GameLogger.info("TreeTest: Loading " + tree_name + " from " + tree_path)
	update_status("Loading " + tree_name + "...")
	
	# Clear previous tree
	if current_tree_instance:
		current_tree_instance.queue_free()
		current_tree_instance = null
	
	# Load the tree scene
	var tree_scene = load(tree_path)
	if not tree_scene:
		GameLogger.error("TreeTest: Failed to load tree scene: " + tree_path)
		update_status("Failed to load tree scene!")
		return
	
	# Instantiate the tree
	current_tree_instance = tree_scene.instantiate()
	if not current_tree_instance:
		GameLogger.error("TreeTest: Failed to instantiate tree scene")
		update_status("Failed to instantiate tree!")
		return
	
	# Position the tree
	current_tree_instance.transform.origin = Vector3(0, 0, 0)
	tree_container.add_child(current_tree_instance)
	
	# Analyze the tree structure
	analyze_tree_structure(current_tree_instance)
	
	update_status("Loaded " + tree_name + " - Check UV Mapping or Apply Textures")

func analyze_tree_structure(tree_node: Node):
	"""Analyze the complete tree structure to understand the issue"""
	GameLogger.info("TreeTest: Analyzing tree structure...")
	
	var analysis = {
		"total_meshes": 0,
		"meshes_with_uv": 0,
		"meshes_without_uv": 0,
		"meshes_with_materials": 0,
		"meshes_with_textures": 0,
		"leaf_surfaces": 0,
		"trunk_surfaces": 0,
		"details": []
	}
	
	analyze_node_recursive(tree_node, analysis)
	
	GameLogger.info("TreeTest: Analysis Results:")
	GameLogger.info("  - Total meshes: " + str(analysis.total_meshes))
	GameLogger.info("  - Meshes with UV: " + str(analysis.meshes_with_uv))
	GameLogger.info("  - Meshes without UV: " + str(analysis.meshes_without_uv))
	GameLogger.info("  - Meshes with materials: " + str(analysis.meshes_with_materials))
	GameLogger.info("  - Meshes with textures: " + str(analysis.meshes_with_textures))
	GameLogger.info("  - Leaf surfaces: " + str(analysis.leaf_surfaces))
	GameLogger.info("  - Trunk surfaces: " + str(analysis.trunk_surfaces))
	
	update_status("Analysis: " + str(analysis.total_meshes) + " meshes, " + str(analysis.meshes_with_uv) + " with UV")

func analyze_node_recursive(node: Node, analysis: Dictionary):
	"""Recursively analyze all nodes in the tree"""
	if node is MeshInstance3D:
		analysis.total_meshes += 1
		var mesh = node.mesh
		if mesh:
			var mesh_details = {
				"node_name": node.name,
				"surfaces": mesh.get_surface_count(),
				"has_uv": false,
				"has_material": false,
				"has_texture": false,
				"surface_details": []
			}
			
			for i in range(mesh.get_surface_count()):
				var surface_detail = {
					"surface_index": i,
					"has_uv": false,
					"has_material": false,
					"has_texture": false,
					"geometry_type": "unknown",
					"size": Vector3.ZERO
				}
				
				# Check UV mapping
				if mesh.surface_get_format(i) & Mesh.ARRAY_TEX_UV:
					analysis.meshes_with_uv += 1
					mesh_details.has_uv = true
					surface_detail.has_uv = true
				else:
					analysis.meshes_without_uv += 1
				
				# Check material and texture
				var material = mesh.surface_get_material(i)
				if material:
					analysis.meshes_with_materials += 1
					mesh_details.has_material = true
					surface_detail.has_material = true
					
					if material is StandardMaterial3D:
						var std_material = material as StandardMaterial3D
						if std_material.albedo_texture:
							analysis.meshes_with_textures += 1
							mesh_details.has_texture = true
							surface_detail.has_texture = true
				
				# Analyze geometry
				var arrays = mesh.surface_get_arrays(i)
				if arrays.size() > Mesh.ARRAY_VERTEX:
					var vertices = arrays[Mesh.ARRAY_VERTEX]
					if vertices.size() > 0:
						var min_pos = vertices[0]
						var max_pos = vertices[0]
						for vertex in vertices:
							min_pos = min_pos.min(vertex)
							max_pos = max_pos.max(vertex)
						
						var size = max_pos - min_pos
						surface_detail.size = size
						
						# Determine geometry type
						var height_ratio = size.y / max(size.x, size.z) if max(size.x, size.z) > 0 else 0
						var flatness_ratio = size.y / (size.x + size.z) if (size.x + size.z) > 0 else 0
						
						if flatness_ratio < 0.2:
							surface_detail.geometry_type = "leaf"
							analysis.leaf_surfaces += 1
						elif height_ratio > 2.0:
							surface_detail.geometry_type = "trunk"
							analysis.trunk_surfaces += 1
						else:
							surface_detail.geometry_type = "branch"
				
				mesh_details.surface_details.append(surface_detail)
			
			analysis.details.append(mesh_details)
	
	# Recursively analyze children
	for child in node.get_children():
		analyze_node_recursive(child, analysis)

func apply_original_texture():
	"""Apply the original texture that should come with the tree model"""
	GameLogger.info("TreeTest: Apply Original Texture button pressed!")
	
	if not current_tree_instance:
		update_status("No tree loaded!")
		return
	
	GameLogger.info("TreeTest: Applying original texture (preserving existing UV mapping)")
	update_status("Applying original texture...")
	
	# This should preserve the original UV mapping and just apply the texture
	apply_texture_preserving_uv(current_tree_instance, null)  # null means use original
	
	update_status("Applied original texture - check if leaves look natural now")

func apply_custom_texture():
	"""Apply a custom texture to test if the issue is with the texture or UV mapping"""
	GameLogger.info("TreeTest: Apply Custom Texture button pressed!")
	
	if not current_tree_instance:
		update_status("No tree loaded!")
		return
	
	GameLogger.info("TreeTest: Applying custom texture")
	update_status("Applying custom texture...")
	
	# Try to determine which texture to use based on tree name
	var tree_name = current_tree_instance.name
	var texture_path = ""
	
	if tree_name.begins_with("pine_tree_n_1"):
		texture_path = tree_textures.get("pine_tree_n_1", "")
	elif tree_name.begins_with("pine_tree_n_2"):
		texture_path = tree_textures.get("pine_tree_n_2", "")
	elif tree_name.begins_with("pine_tree_n_3"):
		texture_path = tree_textures.get("pine_tree_n_3", "")
	
	if texture_path == "" or not FileAccess.file_exists(texture_path):
		GameLogger.warning("TreeTest: Custom texture not found, using fallback")
		texture_path = tree_textures.get("pine_tree_n_1", "")
	
	if texture_path != "" and FileAccess.file_exists(texture_path):
		var texture = load(texture_path)
		if texture:
			apply_texture_preserving_uv(current_tree_instance, texture)
			update_status("Applied custom texture: " + texture_path.get_file())
		else:
			update_status("Failed to load custom texture!")
	else:
		update_status("No custom texture available!")

func apply_texture_preserving_uv(node: Node, texture: Texture2D):
	"""Apply texture while preserving existing UV mapping"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			GameLogger.info("TreeTest: Applying texture to " + node.name)
			
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if not material:
					material = StandardMaterial3D.new()
					mesh.surface_set_material(i, material)
				
				if material is StandardMaterial3D:
					var std_material = material as StandardMaterial3D
					if texture:
						std_material.albedo_texture = texture
					# Set PSX-style filtering
					std_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
					GameLogger.info("TreeTest: Applied texture to surface " + str(i))
	
	# Recursively apply to children
	for child in node.get_children():
		apply_texture_preserving_uv(child, texture)

func check_uv_mapping():
	"""Check the UV mapping of the current tree"""
	GameLogger.info("TreeTest: Check UV Mapping button pressed!")
	
	if not current_tree_instance:
		update_status("No tree loaded!")
		return
	
	GameLogger.info("TreeTest: Checking UV mapping...")
	update_status("Checking UV mapping...")
	
	var uv_info = {
		"total_surfaces": 0,
		"surfaces_with_uv": 0,
		"surfaces_without_uv": 0,
		"uv_ranges": []
	}
	
	check_uv_recursive(current_tree_instance, uv_info)
	
	GameLogger.info("TreeTest: UV Check Results:")
	GameLogger.info("  - Total surfaces: " + str(uv_info.total_surfaces))
	GameLogger.info("  - Surfaces with UV: " + str(uv_info.surfaces_with_uv))
	GameLogger.info("  - Surfaces without UV: " + str(uv_info.surfaces_without_uv))
	
	for uv_range in uv_info.uv_ranges:
		GameLogger.info("  - UV Range: " + str(uv_range))
	
	update_status("UV Check: " + str(uv_info.surfaces_with_uv) + "/" + str(uv_info.total_surfaces) + " surfaces have UV")

func check_uv_recursive(node: Node, uv_info: Dictionary):
	"""Recursively check UV mapping"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				uv_info.total_surfaces += 1
				
				if mesh.surface_get_format(i) & Mesh.ARRAY_TEX_UV:
					uv_info.surfaces_with_uv += 1
					
					# Check UV range
					var arrays = mesh.surface_get_arrays(i)
					if arrays.size() > Mesh.ARRAY_TEX_UV:
						var uvs = arrays[Mesh.ARRAY_TEX_UV]
						if uvs.size() > 0:
							var min_uv = uvs[0]
							var max_uv = uvs[0]
							for uv in uvs:
								min_uv = min_uv.min(uv)
								max_uv = max_uv.max(uv)
							
							uv_info.uv_ranges.append({
								"node": node.name,
								"surface": i,
								"min": min_uv,
								"max": max_uv,
								"range": max_uv - min_uv
							})
				else:
					uv_info.surfaces_without_uv += 1
	
	for child in node.get_children():
		check_uv_recursive(child, uv_info)

func reset_tree():
	"""Reset the current tree (remove it)"""
	GameLogger.info("TreeTest: Reset Tree button pressed!")
	
	if current_tree_instance:
		current_tree_instance.queue_free()
		current_tree_instance = null
		update_status("Tree reset - load a new tree to continue")
	else:
		update_status("No tree to reset!")

func update_status(message: String):
	"""Update the status label"""
	if status_label:
		status_label.text = "Tree Test - " + message
	GameLogger.info("TreeTest: " + message)

func _input(event):
	# Mouse camera rotation
	if event is InputEventMouseMotion and mouse_captured:
		if camera:
			camera.rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity)
	
	# Keyboard controls
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_TAB:
				toggle_mouse_capture()
			KEY_ESCAPE:
				get_tree().quit()
	
	# Camera movement
	if camera:
		var camera_speed = 5.0
		var delta = get_process_delta_time()
		
		if Input.is_key_pressed(KEY_A):
			camera.translate(Vector3.LEFT * camera_speed * delta)
		if Input.is_key_pressed(KEY_D):
			camera.translate(Vector3.RIGHT * camera_speed * delta)
		if Input.is_key_pressed(KEY_W):
			camera.translate(Vector3.FORWARD * camera_speed * delta)
		if Input.is_key_pressed(KEY_S):
			camera.translate(Vector3.BACK * camera_speed * delta)

func toggle_mouse_capture():
	"""Toggle mouse capture for camera rotation"""
	mouse_captured = !mouse_captured
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		update_status("Mouse captured - move mouse to rotate camera")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		update_status("Mouse released - press TAB to capture again")
