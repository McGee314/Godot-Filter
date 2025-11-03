extends Node

# Scene paths
const MAIN_MENU_SCENE = "res://Scenes/MainMenu/MainMenu.tscn"
const SAVE_FILE_PATH = "user://game_save.dat"

# Current scene tracking
var current_scene_name: String = ""
var is_in_game_scene: bool = false
var is_transitioning: bool = false

# Save data structure
var save_data: Dictionary = {
	"last_scene": "",
	"current_region": "",
	"collected_items": [],
	"last_save_time": ""
}

# UI flow flag: when true, main menu should open Start Game submenu automatically
var open_start_game_on_menu: bool = false

# Track currently shown dialog to free safely
var active_dialog: AcceptDialog

func _ready():
	# Always process to catch input
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Debug input events only - don't handle ESC here
	if has_node("/root/DebugConfig") and get_node("/root/DebugConfig").enable_input_debug:
		if event is InputEventKey:
			var info = "key phys=" + str(event.physical_keycode) + ", pressed=" + str(event.pressed)
			GameLogger.debug("[InputDebug] _input: " + info + ", is_in_game_scene=" + str(is_in_game_scene) + ", transitioning=" + str(is_transitioning))
			
			# Special debug for Escape key
			if event.physical_keycode == 4194305:
				GameLogger.debug("[InputDebug] ESCAPE KEY DETECTED! pressed=" + str(event.pressed))
		elif event is InputEventMouseButton:
			var info = "mouse btn=" + str(event.button_index) + ", pressed=" + str(event.pressed)
			GameLogger.debug("[InputDebug] _input: " + info + ", is_in_game_scene=" + str(is_in_game_scene) + ", transitioning=" + str(is_transitioning))

func _unhandled_input(event):
	# Handle ESC only if no scene handled it first (using _unhandled_input for lower priority)
	var escape_pressed = event.is_action_pressed("ui_cancel")
	
	# Fallback: Check for Escape key directly if actions aren't working
	if not escape_pressed and event is InputEventKey and event.physical_keycode == 4194305 and event.pressed:
		GameLogger.info("🔧 GameSceneManager: Escape key detected directly (fallback)")
		escape_pressed = true
	
	if escape_pressed and is_in_game_scene and not is_transitioning:
		# Check if there's already an active dialog to prevent conflicts
		if UnifiedExitDialog.active_dialog_instance and is_instance_valid(UnifiedExitDialog.active_dialog_instance):
			GameLogger.info("⚠️ GameSceneManager: UnifiedExitDialog already active - skipping GameSceneManager dialog")
			return
		
		# Check if there's already an active dialog in GameSceneManager
		if active_dialog and is_instance_valid(active_dialog):
			GameLogger.info("⚠️ GameSceneManager: GameSceneManager dialog already active - skipping")
			return
		
		# If we reach here, no scene handled the ESC key, so we handle it
		var current_scene = get_tree().current_scene
		var scene_name = current_scene.scene_file_path.get_file().get_basename()
		GameLogger.info("🚨 GameSceneManager: Unhandled ESC in scene: " + scene_name + " - showing GameSceneManager dialog")
		handle_escape_in_game_scene()
	elif escape_pressed:
		GameLogger.info("🔧 GameSceneManager: ESC detected but conditions not met - is_in_game_scene=" + str(is_in_game_scene) + ", transitioning=" + str(is_transitioning))

func set_current_scene(scene_name: String):
	current_scene_name = scene_name
	is_in_game_scene = scene_name in ["PasarScene", "TamboraScene", "PapuaScene", "PapuaScene_Terrain3D"]
	is_transitioning = false
	
	GameLogger.debug("Current scene set: " + current_scene_name + ", is_in_game_scene=" + str(is_in_game_scene))

func handle_escape_in_game_scene():
	# Show confirmation dialog before returning to main menu
	GameLogger.info("🔧 GameSceneManager: handle_escape_in_game_scene() called")
	show_return_to_menu_confirmation()

func show_return_to_menu_confirmation():
	# Prevent multiple dialogs
	GameLogger.info("🔧 GameSceneManager: show_return_to_menu_confirmation() called")
	if active_dialog and is_instance_valid(active_dialog):
		GameLogger.info("⚠️ GameSceneManager: Dialog already active - ignoring new request")
		return
	
	# Create confirmation dialog (better for Yes/No scenarios)
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Return to main menu?\nYour progress will be saved."
	popup.title = "Return to Menu"
	
	# ConfirmationDialog automatically has OK (Yes) and Cancel (No) buttons
	popup.get_ok_button().text = "Yes"
	popup.get_cancel_button().text = "No"
	
	# Connect the dialog signals
	popup.confirmed.connect(_on_return_confirmed)  # Yes button
	popup.canceled.connect(_on_return_canceled)    # No button
	popup.tree_exited.connect(_on_dialog_tree_exited)
	
	# Add to current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(popup)
		active_dialog = popup
		GameLogger.debug("Dialog shown. in_tree=" + str(active_dialog.is_inside_tree()))
		popup.popup_centered()
		GameLogger.info("✅ GameSceneManager dialog created and shown")
		


func _on_dialog_tree_exited():
	var queued_info = "n/a" if active_dialog == null else str(active_dialog.is_queued_for_deletion())
	GameLogger.debug("Dialog tree_exited. queued=" + queued_info)

func _on_return_confirmed():
	# Set transitioning immediately to prevent any more input processing
	is_transitioning = true
	
	# Safely free dialog then navigate
	if active_dialog:
		GameLogger.debug("Confirm pressed. Freeing dialog. in_tree=" + str(active_dialog.is_inside_tree()))
		active_dialog.queue_free()
		active_dialog = null
	return_to_start_menu()

func _on_return_canceled():
	"""Handle No button press - close dialog and stay in scene"""
	GameLogger.info("✅ User chose NO - closing dialog and staying in scene")
	if active_dialog:
		GameLogger.debug("Hiding and freeing dialog...")
		active_dialog.hide()  # Hide immediately
		active_dialog.queue_free()  # Then queue for deletion
		active_dialog = null
	# Don't transition - stay in current scene
	GameLogger.info("✅ Dialog closed, remaining in current scene")

func return_to_main_menu():
	# Save any current progress here if needed
	save_current_progress()
	
	# Return to plain main menu
	open_start_game_on_menu = false
	is_transitioning = true
	GameLogger.debug("Changing scene to MAIN_MENU_SCENE (plain main menu)")
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	
	# Reset game scene state
	is_in_game_scene = false
	current_scene_name = ""

func return_to_start_menu():
	# Save any current progress here if needed
	save_current_progress()
	
	# Set flag so main menu opens Start Game submenu (map)
	open_start_game_on_menu = true
	is_transitioning = true
	GameLogger.debug("Changing scene to MAIN_MENU_SCENE with open_start_game_on_menu=true")
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	
	# Reset game scene state
	is_in_game_scene = false
	current_scene_name = ""

func save_current_progress():
	# Save current region and any collected items
	if Global.current_region != "":
		GameLogger.info("Saving progress for region: " + Global.current_region)
		
		# Update save data
		save_data["last_scene"] = current_scene_name
		save_data["current_region"] = Global.current_region
		save_data["last_save_time"] = Time.get_datetime_string_from_system()
		
		# Save collected items if inventory system exists
		if has_node("/root/Global") and Global.has_method("get_collected_items"):
			save_data["collected_items"] = Global.get_collected_items()
		
		# Write save file
		save_game_data()

func save_game_data():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		GameLogger.info("Game saved successfully")
	else:
		GameLogger.error("Failed to save game data")

func load_game_data() -> bool:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			save_data = json.data
			GameLogger.info("Game loaded successfully")
			return true
		else:
			GameLogger.error("Failed to parse save data")
			return false
	else:
		GameLogger.info("No save file found")
		return false

func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func get_last_scene() -> String:
	return save_data.get("last_scene", "")

func get_last_region() -> String:
	return save_data.get("current_region", "")

func get_last_save_time() -> String:
	return save_data.get("last_save_time", "")

func load_last_checkpoint():
	if not has_save_data():
		GameLogger.warning("No save data to load")
		return false
	
	if not load_game_data():
		return false
	
	var last_scene = get_last_scene()
	if last_scene == "":
		GameLogger.warning("No valid scene in save data")
		return false
	
	# Set global region
	Global.current_region = get_last_region()
	
	# Load the last scene
	var scene_path = ""
	match last_scene:
		"PasarScene":
			scene_path = "res://Scenes/IndonesiaBarat/PasarScene.tscn"
		"TamboraScene":
			scene_path = "res://Scenes/IndonesiaTengah/TamboraScene.tscn"
		"PapuaScene":
			scene_path = "res://Scenes/IndonesiaTimur/PapuaScene.tscn"
	
	if scene_path:
		GameLogger.info("Loading checkpoint: " + scene_path)
		get_tree().change_scene_to_file(scene_path)
		return true
	else:
		GameLogger.error("Invalid scene in save data: " + last_scene)
		return false

func delete_save_data():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		GameLogger.info("Save data deleted")
		save_data = {
			"last_scene": "",
			"current_region": "",
			"collected_items": [],
			"last_save_time": ""
		}




