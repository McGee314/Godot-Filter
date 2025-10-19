extends Node

# Singleton for cooking game integration
# Handles the bridge between 3D map system and student's cooking game

# Cooking game data structure - Focus on Jakarta recipes
var cooking_recipes: Dictionary = {
	"SotoBetawi": {
		"name": "Soto Betawi",
		"region": "DKI Jakarta",
		"description": "Traditional beef soup from Jakarta",
		"ingredients": ["beef", "coconut milk", "spices", "rice"],
		"difficulty": "medium",
		"time_limit": 400,  # 6.5 minutes
		"scene_path": "res://students/cooking-game/Map.tscn"
	},
	"Pempek": {
		"name": "Pempek Palembang",
		"region": "Sumatera Selatan",
		"description": "Traditional fish cake from Palembang (Student's working level)",
		"ingredients": ["fish", "flour", "salt", "water"],
		"difficulty": "medium",
		"time_limit": 300,  # 5 minutes
		"scene_path": "res://students/cooking-game/Map.tscn"
	},
	"NasiGudeg": {
		"name": "Nasi Gudeg Jakarta",
		"region": "DKI Jakarta",
		"description": "Traditional jackfruit rice from Jakarta",
		"ingredients": ["jackfruit", "rice", "coconut", "spices"],
		"difficulty": "hard",
		"time_limit": 600,  # 10 minutes
		"scene_path": "res://students/cooking-game/Map.tscn"
	},
	"Lotek": {
		"name": "Lotek Jakarta",
		"region": "DKI Jakarta",
		"description": "Traditional vegetable salad from Jakarta",
		"ingredients": ["vegetables", "peanut sauce", "rice", "spices"],
		"difficulty": "easy",
		"time_limit": 250,  # 4 minutes
		"scene_path": "res://students/cooking-game/Map.tscn"
	},
	"Baso": {
		"name": "Baso Jakarta",
		"region": "DKI Jakarta",
		"description": "Traditional meatball soup from Jakarta",
		"ingredients": ["meatballs", "noodles", "broth", "vegetables"],
		"difficulty": "easy",
		"time_limit": 300,  # 5 minutes
		"scene_path": "res://students/cooking-game/Map.tscn"
	},
	"Sate": {
		"name": "Sate Jakarta",
		"region": "DKI Jakarta",
		"description": "Traditional grilled meat skewers from Jakarta",
		"ingredients": ["meat", "peanut sauce", "rice", "spices"],
		"difficulty": "medium",
		"time_limit": 350,  # 6 minutes
		"scene_path": "res://students/cooking-game/Map.tscn"
	}
}

# Game state
var current_recipe: String = ""
var current_region: String = ""
var cooking_score: int = 0
var cooking_time_remaining: float = 0.0
var cooking_stats: Dictionary = {}

# Signals
signal cooking_game_started(recipe: String, region: String)
signal cooking_game_completed(score: int, time: float)
signal cooking_game_failed(reason: String)

func _ready():
	# Set as singleton
	name = "CookingGameIntegration"
	
	# Connect to global signals if available
	if has_node("/root/GlobalSignals"):
		var global_signals = get_node("/root/GlobalSignals")
		if global_signals.has_signal("cooking_game_completed"):
			global_signals.connect("cooking_game_completed", _on_cooking_game_completed)
		if global_signals.has_signal("cooking_game_failed"):
			global_signals.connect("cooking_game_failed", _on_cooking_game_failed)

func start_cooking_game(recipe_name: String, region_name: String) -> bool:
	"""Start a cooking game for the specified recipe and region"""
	if not recipe_name in cooking_recipes:
		GameLogger.error("Recipe not found: " + recipe_name)
		return false
	
	var recipe_data = cooking_recipes[recipe_name]
	current_recipe = recipe_name
	current_region = region_name
	cooking_time_remaining = recipe_data.time_limit
	
	GameLogger.info("Starting cooking game: " + recipe_name + " from " + region_name)
	
	# Emit signal
	cooking_game_started.emit(recipe_name, region_name)
	
	# Load the cooking game scene
	var scene_path = recipe_data.scene_path
	if ResourceLoader.exists(scene_path):
		# Store current scene state for return
		Global.current_region = region_name
		Global.current_recipe = recipe_name
		
		get_tree().change_scene_to_file(scene_path)
		return true
	else:
		GameLogger.error("Cooking game scene not found: " + scene_path)
		# Create a basic cooking game scene as fallback
		create_basic_cooking_game_scene(recipe_name)
		return true

func create_basic_cooking_game_scene(recipe_name: String):
	"""Create a basic cooking game scene using simple 3D shapes"""
	GameLogger.info("Creating basic cooking game scene for: " + recipe_name)
	
	# Create a new scene
	var cooking_scene = Node3D.new()
	cooking_scene.name = "BasicCookingGame"
	
	# Add camera
	var _camera = Camera3D.new()
	_camera.position = Vector3(0, 5, 5)
	_camera.look_at(Vector3.ZERO, Vector3.UP)
	cooking_scene.add_child(_camera)
	
	# Add lighting
	var _light = DirectionalLight3D.new()
	_light.position = Vector3(0, 10, 0)
	_light.light_energy = 1.0
	cooking_scene.add_child(_light)
	
	# Add basic cooking station
	var basic_assets = BasicCookingGameAssets.new()
	var _cooking_station = basic_assets.create_basic_cooking_station(cooking_scene)
	
	# Add UI overlay
	var ui_layer = CanvasLayer.new()
	cooking_scene.add_child(ui_layer)
	
	# Add recipe info panel
	var recipe_panel = Panel.new()
	recipe_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	recipe_panel.size = Vector2(300, 150)
	ui_layer.add_child(recipe_panel)
	
	var recipe_label = Label.new()
	recipe_label.text = "Cooking: " + get_recipe_display_name(recipe_name)
	recipe_label.position = Vector2(10, 10)
	recipe_panel.add_child(recipe_label)
	
	var time_label = Label.new()
	time_label.text = "Time: " + str(cooking_time_remaining) + "s"
	time_label.position = Vector2(10, 40)
	recipe_panel.add_child(time_label)
	
	var back_button = Button.new()
	back_button.text = "Back to Pasar"
	back_button.position = Vector2(10, 80)
	back_button.pressed.connect(_on_back_to_pasar)
	recipe_panel.add_child(back_button)
	
	# Add simple cooking interaction
	var interaction_area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 2.0
	collision_shape.shape = sphere_shape
	interaction_area.add_child(collision_shape)
	cooking_scene.add_child(interaction_area)
	
	# Connect interaction
	interaction_area.input_event.connect(_on_cooking_interaction)
	
	# Set as current scene
	get_tree().current_scene = cooking_scene
	
	# Start cooking timer
	start_cooking_timer()

func get_recipe_display_name(recipe_name: String) -> String:
	"""Get display name for recipe"""
	if recipe_name in cooking_recipes:
		return cooking_recipes[recipe_name].name
	return recipe_name

func start_cooking_timer():
	"""Start the cooking game timer"""
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_cooking_timer_tick)
	timer.autostart = true
	add_child(timer)

func _on_cooking_timer_tick():
	"""Handle cooking timer tick"""
	cooking_time_remaining -= 1.0
	
	if cooking_time_remaining <= 0:
		# Time's up - complete the game
		_on_cooking_game_completed(100, 0)  # Give some score

func _on_cooking_interaction(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	"""Handle cooking interaction"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Simple cooking interaction - just complete the game
		GameLogger.info("Cooking interaction detected - completing game")
		_on_cooking_game_completed(150, cooking_time_remaining)

func _on_back_to_pasar():
	"""Return to Pasar scene"""
	GameLogger.info("Returning to Pasar scene")
	get_tree().change_scene_to_file("res://Scenes/IndonesiaBarat/PasarScene.tscn")

func get_recipe_data(recipe_name: String) -> Dictionary:
	"""Get recipe data by name"""
	if recipe_name in cooking_recipes:
		return cooking_recipes[recipe_name]
	return {}

func get_available_recipes() -> Array[String]:
	"""Get list of available recipe names"""
	return cooking_recipes.keys()

func get_recipes_by_region(region_name: String) -> Array[String]:
	"""Get recipes available in a specific region"""
	var region_recipes: Array[String] = []
	for recipe_name in cooking_recipes:
		var recipe_data = cooking_recipes[recipe_name]
		if recipe_data.region == region_name:
			region_recipes.append(recipe_name)
	return region_recipes

func get_recipes_by_difficulty(difficulty: String) -> Array[String]:
	"""Get recipes by difficulty level"""
	var difficulty_recipes: Array[String] = []
	for recipe_name in cooking_recipes:
		var recipe_data = cooking_recipes[recipe_name]
		if recipe_data.difficulty == difficulty:
			difficulty_recipes.append(recipe_name)
	return difficulty_recipes

func _on_cooking_game_completed(score: int, time: float):
	"""Handle cooking game completion"""
	cooking_score = score
	GameLogger.info("Cooking game completed! Score: " + str(score) + ", Time: " + str(time))
	
	# Update cooking stats
	if not cooking_stats.has(current_recipe):
		cooking_stats[current_recipe] = {
			"best_score": score,
			"best_time": time,
			"attempts": 1,
			"completed": true
		}
	else:
		var stats = cooking_stats[current_recipe]
		stats.attempts += 1
		stats.completed = true
		if score > stats.best_score:
			stats.best_score = score
		if time < stats.best_time:
			stats.best_time = time
	
	# Emit signal
	cooking_game_completed.emit(score, time)
	
	# Return to 3D map
	return_to_3d_map()

func _on_cooking_game_failed(reason: String):
	"""Handle cooking game failure"""
	GameLogger.info("Cooking game failed: " + reason)
	
	# Update cooking stats
	if not cooking_stats.has(current_recipe):
		cooking_stats[current_recipe] = {
			"best_score": 0,
			"best_time": 0,
			"attempts": 1,
			"completed": false
		}
	else:
		var stats = cooking_stats[current_recipe]
		stats.attempts += 1
	
	# Emit signal
	cooking_game_failed.emit(reason)
	
	# Return to 3D map
	return_to_3d_map()

func return_to_3d_map():
	"""Return to the appropriate scene after cooking game"""
	GameLogger.info("Returning to region scene...")
	
	# Return to the appropriate region scene based on current region
	match current_region:
		"Indonesia Barat", "DKI Jakarta":
			get_tree().change_scene_to_file("res://Scenes/IndonesiaBarat/PasarScene.tscn")
		"Indonesia Tengah":
			get_tree().change_scene_to_file("res://Scenes/IndonesiaTengah/TamboraScene.tscn")
		"Indonesia Timur":
			get_tree().change_scene_to_file("res://Scenes/IndonesiaTimur/PapuaScene.tscn")
		_:
			# Fallback to 3D map
			get_tree().change_scene_to_file("res://Scenes/MainMenu/Indonesia3DMap.tscn")

func get_cooking_statistics() -> Dictionary:
	"""Get cooking game statistics"""
	return {
		"current_recipe": current_recipe,
		"current_region": current_region,
		"last_score": cooking_score,
		"time_remaining": cooking_time_remaining,
		"stats": cooking_stats
	}

func reset_cooking_game():
	"""Reset cooking game state"""
	current_recipe = ""
	current_region = ""
	cooking_score = 0
	cooking_time_remaining = 0.0
	GameLogger.info("Cooking game state reset")

func get_recipe_progress(recipe_name: String) -> Dictionary:
	"""Get progress for a specific recipe"""
	if recipe_name in cooking_stats:
		return cooking_stats[recipe_name]
	return {
		"best_score": 0,
		"best_time": 0,
		"attempts": 0,
		"completed": false
	}

func is_recipe_completed(recipe_name: String) -> bool:
	"""Check if a recipe has been completed"""
	if recipe_name in cooking_stats:
		return cooking_stats[recipe_name].completed
	return false

func get_total_completed_recipes() -> int:
	"""Get total number of completed recipes"""
	var completed = 0
	for recipe_name in cooking_stats:
		if cooking_stats[recipe_name].completed:
			completed += 1
	return completed

func get_total_attempts() -> int:
	"""Get total number of cooking attempts"""
	var total = 0
	for recipe_name in cooking_stats:
		total += cooking_stats[recipe_name].attempts
	return total
