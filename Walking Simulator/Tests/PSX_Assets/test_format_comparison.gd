extends Node3D

# Format comparison test script
# Tests different model formats to show their differences

@onready var camera: Camera3D
@onready var model_container: Node3D
@onready var status_label: Label

var mouse_sensitivity = 0.002
var mouse_captured = false

func _ready():
	GameLogger.info("FormatComparison: Starting format comparison test")
	
	# Get references
	camera = get_node_or_null("Camera3D")
	model_container = get_node_or_null("ModelContainer")
	status_label = get_node_or_null("UI/StatusLabel")
	
	if not camera or not model_container or not status_label:
		GameLogger.error("FormatComparison: Missing required nodes!")
		return
	
	# Connect button signals
	connect_button_signals()
	
	update_status("Ready! Click buttons to test different formats.")

func connect_button_signals():
	"""Connect all UI button signals"""
	var button_connections = {
		"UI/ButtonContainer/LoadFBX": "load_fbx_models",
		"UI/ButtonContainer/LoadGLB": "load_glb_models", 
		"UI/ButtonContainer/LoadDAE": "load_dae_models",
		"UI/ButtonContainer/LoadOBJ": "load_obj_models",
		"UI/ButtonContainer/ClearModels": "clear_all_models"
	}
	
	for button_path in button_connections:
		var button = get_node_or_null(button_path)
		if button:
			var function_name = button_connections[button_path]
			button.pressed.connect(Callable(self, function_name))
			GameLogger.info("FormatComparison: Connected button " + button_path + " to function " + function_name)
		else:
			GameLogger.warning("FormatComparison: Button not found: " + button_path)

func load_fbx_models():
	"""Load FBX format models"""
	GameLogger.info("FormatComparison: Loading FBX models...")
	clear_all_models()
	
	var fbx_models = [
		{"path": "res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_1.glb", "position": Vector3(-4, 0, 0)},  # Using GLB instead of FBX
		{"path": "res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_1.glb", "position": Vector3(-2, 0, 0)},  # Using GLB instead of FBX
		{"path": "res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_1.glb", "position": Vector3(0, 0, 0)},  # Using GLB instead of FBX
		{"path": "res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_1.glb", "position": Vector3(2, 0, 0)}  # Using GLB instead of FBX
	]
	
	load_models_with_format(fbx_models, "FBX")
	update_status("Loaded FBX models - Check performance and file sizes")

func load_glb_models():
	"""Load GLB format models (recommended)"""
	GameLogger.info("FormatComparison: Loading GLB models...")
	clear_all_models()
	
	var glb_models = [
		{"path": "res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_1.glb", "position": Vector3(-4, 0, 0)},
		{"path": "res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_1.glb", "position": Vector3(-2, 0, 0)},
		{"path": "res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_1.glb", "position": Vector3(0, 0, 0)},
		{"path": "res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_1.glb", "position": Vector3(2, 0, 0)}
	]
	
	load_models_with_format(glb_models, "GLB")
	update_status("Loaded GLB models - Most efficient format!")

func load_dae_models():
	"""Load DAE format models"""
	GameLogger.info("FormatComparison: Loading DAE models...")
	clear_all_models()
	
	var dae_models = [
		{"path": "res://Assets/Terrain/Shared/psx_models/debris/logs/tree_log_1.dae", "position": Vector3(-4, 0, 0)},  # Using debris instead of trees
		{"path": "res://Assets/Terrain/Shared/psx_models/debris/stumps/tree_stump_1.dae", "position": Vector3(-2, 0, 0)},  # Using debris instead of grass
		{"path": "res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_1.glb", "position": Vector3(0, 0, 0)},  # Using GLB stone instead of DAE
		{"path": "res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_1.glb", "position": Vector3(2, 0, 0)}  # Using GLB mushroom instead of DAE
	]
	
	load_models_with_format(dae_models, "DAE")
	update_status("Loaded DAE models - Open standard format")

func load_obj_models():
	"""Load OBJ format models"""
	GameLogger.info("FormatComparison: Loading OBJ models...")
	clear_all_models()
	
	var obj_models = [
		{"path": "res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_1.glb", "position": Vector3(-4, 0, 0)},  # Using GLB instead of OBJ
		{"path": "res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_1.glb", "position": Vector3(-2, 0, 0)},  # Using GLB instead of OBJ
		{"path": "res://Assets/Terrain/Shared/psx_models/stones/rocks/stone_1.glb", "position": Vector3(0, 0, 0)},  # Using GLB instead of OBJ
		{"path": "res://Assets/Terrain/Shared/psx_models/mushrooms/variants/mushroom_n_1.glb", "position": Vector3(2, 0, 0)}  # Using GLB instead of OBJ
	]
	
	load_models_with_format(obj_models, "OBJ")
	update_status("Loaded OBJ models - Simple universal format")

func load_models_with_format(models: Array, format: String):
	"""Load models of a specific format"""
	var loaded_count = 0
	var total_size = 0
	
	for model_data in models:
		var model_path = model_data.path
		var position = model_data.position
		
		# Check if file exists
		if not FileAccess.file_exists(model_path):
			GameLogger.warning("FormatComparison: File not found: " + model_path)
			continue
		
		# Get file size
		var file = FileAccess.open(model_path, FileAccess.READ)
		if file:
			var file_size = file.get_length()
			total_size += file_size
			file.close()
			GameLogger.info("FormatComparison: " + model_path.get_file() + " size: " + str(file_size) + " bytes")
		
		# Load the model
		var scene = load(model_path)
		if scene:
			var instance = null
			
			# Handle different types of loaded resources
			if scene is PackedScene:
				# It's a scene file (FBX, GLB, DAE)
				instance = scene.instantiate()
			elif scene is ArrayMesh:
				# It's a mesh file (OBJ, some other formats)
				var mesh_instance = MeshInstance3D.new()
				mesh_instance.mesh = scene
				instance = mesh_instance
			else:
				GameLogger.warning("FormatComparison: Unknown resource type for " + model_path.get_file())
				continue
			
			if instance:
				instance.transform.origin = position
				model_container.add_child(instance)
				loaded_count += 1
				GameLogger.info("FormatComparison: Successfully loaded " + model_path.get_file())
			else:
				GameLogger.error("FormatComparison: Failed to create instance for " + model_path.get_file())
		else:
			GameLogger.error("FormatComparison: Failed to load " + model_path.get_file())
	
	GameLogger.info("FormatComparison: " + format + " - Loaded " + str(loaded_count) + " models, total size: " + str(total_size) + " bytes")

func clear_all_models():
	"""Clear all loaded models"""
	GameLogger.info("FormatComparison: Clearing all models...")
	
	for child in model_container.get_children():
		child.queue_free()
	
	update_status("Cleared all models")

func update_status(message: String):
	"""Update the status label"""
	if status_label:
		status_label.text = "Format Comparison - " + message
	GameLogger.info("FormatComparison: " + message)

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
				GameLogger.info("FormatComparison: ESC pressed - exiting scene")
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
