class_name CookingGameNPC
extends CulturalNPC

# Specialized NPC for offering cooking mini-games
# Integrates with student's cooking game system

# Cooking game data
@export var available_recipes: Array[String] = ["SotoBetawi", "Pempek", "NasiGudeg"]
@export var cooking_scene_path: String = "res://students/cooking-game/Map.tscn"

# Dialogue data for cooking games
var cooking_dialogue_data: Array[Dictionary] = [
	{
		"id": "greeting",
		"text": "Selamat datang! Saya bisa mengajarkan Anda cara memasak masakan tradisional Jakarta. Mau belajar memasak apa?",
		"options": [
			{"text": "Soto Betawi", "action": "offer_recipe", "recipe": "SotoBetawi"},
			{"text": "Pempek Palembang", "action": "offer_recipe", "recipe": "Pempek"},
			{"text": "Nasi Gudeg", "action": "offer_recipe", "recipe": "NasiGudeg"},
			{"text": "Tidak, terima kasih", "action": "decline"}
		]
	},
	{
		"id": "offer_recipe",
		"text": "Bagus! Saya akan mengajarkan Anda cara memasak {recipe_name}. Siap untuk memulai?",
		"options": [
			{"text": "Ya, mari mulai!", "action": "start_cooking_game"},
			{"text": "Tidak, terima kasih", "action": "decline"}
		]
	},
	{
		"id": "decline",
		"text": "Baik, jika Anda ingin belajar memasak, datanglah lagi ke sini!",
		"options": [
			{"text": "Terima kasih", "action": "end_dialogue"}
		]
	},
	{
		"id": "cooking_complete",
		"text": "Selamat! Anda berhasil menyelesaikan {recipe_name}! Apakah Anda ingin mencoba resep lain?",
		"options": [
			{"text": "Ya, resep lain", "action": "greeting"},
			{"text": "Tidak, terima kasih", "action": "end_dialogue"}
		]
	}
]

# Current cooking game state
var current_recipe: String = ""
var cooking_game_active: bool = false

func _ready():
	# Set up cooking-specific NPC data
	npc_name = "Chef Jakarta"
	npc_type = "Cooking Instructor"
	cultural_region = "Indonesia Barat"
	
	# Override dialogue data with cooking-specific dialogue
	dialogue_data = cooking_dialogue_data
	
	# Call parent setup
	super._ready()
	
	# Connect to cooking game integration
	connect_cooking_game_signals()

func connect_cooking_game_signals():
	"""Connect to cooking game integration signals"""
	if has_node("/root/CookingGameIntegration"):
		var cooking_integration = get_node("/root/CookingGameIntegration")
		cooking_integration.cooking_game_completed.connect(_on_cooking_game_completed)
		cooking_integration.cooking_game_failed.connect(_on_cooking_game_failed)

func setup_default_dialogue():
	"""Setup default cooking dialogue"""
	dialogue_data = cooking_dialogue_data

func handle_dialogue_option(option: Dictionary):
	"""Handle dialogue option selection"""
	var action = option.get("action", "")
	
	match action:
		"offer_recipe":
			offer_recipe(option.get("recipe", ""))
		"start_cooking_game":
			start_cooking_game()
		"decline":
			decline_cooking()
		"end_dialogue":
			end_visual_dialogue()
		_:
			# Fallback to parent handling
			super.handle_dialogue_option(option)

func offer_recipe(recipe_name: String):
	"""Offer a specific recipe to the player"""
	current_recipe = recipe_name
	
	# Update dialogue with recipe name
	var recipe_dialogue = get_dialogue_by_id("offer_recipe")
	if recipe_dialogue:
		recipe_dialogue.text = recipe_dialogue.text.format({"recipe_name": get_recipe_display_name(recipe_name)})
	
	# Show recipe offer dialogue
	var dialogue = get_dialogue_by_id("offer_recipe")
	if dialogue:
		show_dialogue_ui(dialogue)

func start_cooking_game():
	"""Start the cooking game for the current recipe"""
	if current_recipe.is_empty():
		GameLogger.error("No recipe selected for cooking game")
		return
	
	GameLogger.info("Starting cooking game: " + current_recipe)
	
	# Use cooking game integration
	var cooking_integration = get_node_or_null("/root/CookingGameIntegration")
	if cooking_integration:
		var success = cooking_integration.start_cooking_game(current_recipe, "Indonesia Barat")
		if success:
			cooking_game_active = true
			# The cooking game will handle scene transition
		else:
			show_error_message("Failed to start cooking game!")
	else:
		# Fallback to direct scene loading
		load_cooking_scene_directly()

func load_cooking_scene_directly():
	"""Load cooking scene directly as fallback"""
	if ResourceLoader.exists(cooking_scene_path):
		# Store current scene state
		Global.current_region = "Indonesia Barat"
		Global.current_recipe = current_recipe
		
		# Load cooking scene
		get_tree().change_scene_to_file(cooking_scene_path)
	else:
		GameLogger.error("Cooking scene not found: " + cooking_scene_path)
		show_error_message("Cooking game not available!")

func decline_cooking():
	"""Handle player declining cooking game"""
	var dialogue = get_dialogue_by_id("decline")
	if dialogue:
		show_dialogue_ui(dialogue)

func _on_cooking_game_completed(score: int, time: float):
	"""Handle cooking game completion"""
	cooking_game_active = false
	
	GameLogger.info("Cooking game completed! Score: " + str(score) + ", Time: " + str(time))
	
	# Update dialogue with completion message
	var complete_dialogue = get_dialogue_by_id("cooking_complete")
	if complete_dialogue:
		complete_dialogue.text = complete_dialogue.text.format({"recipe_name": get_recipe_display_name(current_recipe)})
	
	# Show completion dialogue
	var dialogue = get_dialogue_by_id("cooking_complete")
	if dialogue:
		show_dialogue_ui(dialogue)

func _on_cooking_game_failed(reason: String):
	"""Handle cooking game failure"""
	cooking_game_active = false
	
	GameLogger.info("Cooking game failed: " + reason)
	
	# Show failure message
	show_error_message("Cooking game failed: " + reason)

func get_recipe_display_name(recipe_id: String) -> String:
	"""Get display name for recipe ID"""
	match recipe_id:
		"SotoBetawi":
			return "Soto Betawi"
		"Pempek":
			return "Pempek Palembang"
		"NasiGudeg":
			return "Nasi Gudeg"
		_:
			return recipe_id

func get_available_recipes() -> Array[String]:
	"""Get list of available recipes"""
	return available_recipes

func is_recipe_available(recipe_id: String) -> bool:
	"""Check if a recipe is available"""
	return recipe_id in available_recipes

func add_recipe(recipe_id: String):
	"""Add a new recipe to available recipes"""
	if not recipe_id in available_recipes:
		available_recipes.append(recipe_id)
		GameLogger.info("Added recipe: " + recipe_id)

func remove_recipe(recipe_id: String):
	"""Remove a recipe from available recipes"""
	if recipe_id in available_recipes:
		available_recipes.erase(recipe_id)
		GameLogger.info("Removed recipe: " + recipe_id)

func get_cooking_stats() -> Dictionary:
	"""Get cooking game statistics"""
	var cooking_integration = get_node_or_null("/root/CookingGameIntegration")
	if cooking_integration:
		return cooking_integration.get_cooking_statistics()
	return {}

func show_error_message(message: String):
	"""Show error message to player"""
	# Create a simple error popup
	var popup = AcceptDialog.new()
	popup.dialog_text = message
	popup.title = "Cooking Game Error"
	add_child(popup)
	popup.popup_centered()
	
	# Auto-remove after 3 seconds
	await get_tree().create_timer(3.0).timeout
	popup.queue_free()

# Override parent methods for cooking-specific behavior
func get_interaction_text() -> String:
	"""Get interaction text for cooking NPC"""
	return "Tekan E untuk berbicara dengan " + npc_name + " tentang memasak"

func get_cultural_info() -> Dictionary:
	"""Get cultural information about cooking"""
	return {
		"title": "Masakan Tradisional Jakarta",
		"description": "Belajar memasak masakan tradisional Jakarta dengan Chef berpengalaman",
		"region": cultural_region,
		"type": "Cooking Instruction",
		"available_recipes": available_recipes
	}
