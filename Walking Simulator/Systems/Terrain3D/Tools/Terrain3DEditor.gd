class_name PapuaScene_Terrain3DEditor
extends Control

## PapuaScene_Terrain3DEditor - UI for saving/loading terrain environment data
## Provides interface for managing persistent terrain, assets, and hexagon paths

@onready var terrain_data_manager: TerrainDataManager = $TerrainDataManager
@onready var save_name_input: LineEdit = $UI/MainPanel/VBoxContainer/SaveSection/SaveNameContainer/SaveNameInput
@onready var save_button: Button = $UI/MainPanel/VBoxContainer/SaveSection/SaveButton
@onready var load_list: ItemList = $UI/MainPanel/VBoxContainer/LoadSection/LoadListContainer/LoadList
@onready var load_button: Button = $UI/MainPanel/VBoxContainer/LoadSection/LoadButtonContainer/LoadButton
@onready var delete_button: Button = $UI/MainPanel/VBoxContainer/LoadSection/LoadButtonContainer/DeleteButton
@onready var generate_button: Button = $UI/MainPanel/VBoxContainer/ActionsSection/ActionsContainer/GenerateButton
@onready var clear_button: Button = $UI/MainPanel/VBoxContainer/ActionsSection/ActionsContainer/ClearButton
@onready var status_text: RichTextLabel = $UI/MainPanel/VBoxContainer/StatusSection/StatusText
@onready var close_button: Button = $UI/MainPanel/VBoxContainer/CloseButton

var terrain_controller: Node = null

func _ready():
	# Connect signals
	terrain_data_manager.data_saved.connect(_on_data_saved)
	terrain_data_manager.data_loaded.connect(_on_data_loaded)
	terrain_data_manager.save_failed.connect(_on_save_failed)
	terrain_data_manager.load_failed.connect(_on_load_failed)
	
	# Connect UI signals
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	generate_button.pressed.connect(_on_generate_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Set default save name
	save_name_input.text = "papua_base_v1"
	
	# Load available saves
	refresh_save_list()
	
	# Find terrain controller
	find_terrain_controller()
	
	update_status("🌴 Terrain3D Editor ready. Find terrain controller and load available saves.")

func find_terrain_controller():
	"""Find the terrain controller in the scene"""
	# Look for PapuaScene_TerrainController
	var terrain_controllers = get_tree().get_nodes_in_group("terrain_controller")
	if terrain_controllers.size() > 0:
		terrain_controller = terrain_controllers[0]
		update_status("✅ Found terrain controller: %s" % terrain_controller.name)
	else:
		# Try to find by name
		terrain_controller = get_node_or_null("../PapuaScene_TerrainController")
		if terrain_controller:
			update_status("✅ Found terrain controller: %s" % terrain_controller.name)
		else:
			update_status("⚠️ Terrain controller not found. Please ensure PapuaScene_TerrainController exists.")

func refresh_save_list():
	"""Refresh the list of available saves"""
	load_list.clear()
	var saves = terrain_data_manager.get_available_saves()
	
	if saves.size() == 0:
		load_list.add_item("No saves available")
		load_list.set_item_disabled(0, true)
	else:
		for save_name in saves:
			load_list.add_item("💾 " + save_name)
	
	update_status("📂 Found %d save files" % saves.size())

func _on_save_button_pressed():
	"""Save current environment data"""
	var save_name = save_name_input.text.strip_edges()
	
	if save_name == "":
		update_status("❌ Please enter a save name")
		return
	
	if not terrain_controller:
		update_status("❌ Terrain controller not found")
		return
	
	update_status("💾 Saving environment data: %s..." % save_name)
	save_button.disabled = true
	
	# Save the data
	var success = terrain_data_manager.save_environment_data(save_name, terrain_controller)
	
	if success:
		refresh_save_list()
		save_name_input.text = ""  # Clear input after successful save

func _on_load_button_pressed():
	"""Load selected environment data"""
	var selected_items = load_list.get_selected_items()
	
	if selected_items.size() == 0:
		update_status("❌ Please select a save to load")
		return
	
	if not terrain_controller:
		update_status("❌ Terrain controller not found")
		return
	
	var selected_index = selected_items[0]
	var item_text = load_list.get_item_text(selected_index)
	
	# Extract save name (remove emoji prefix)
	var save_name = item_text.replace("💾 ", "")
	
	update_status("📂 Loading environment data: %s..." % save_name)
	load_button.disabled = true
	
	# Load the data
	terrain_data_manager.load_environment_data(save_name, terrain_controller)

func _on_delete_button_pressed():
	"""Delete selected save"""
	var selected_items = load_list.get_selected_items()
	
	if selected_items.size() == 0:
		update_status("❌ Please select a save to delete")
		return
	
	var selected_index = selected_items[0]
	var item_text = load_list.get_item_text(selected_index)
	
	# Extract save name (remove emoji prefix)
	var save_name = item_text.replace("💾 ", "")
	
	# Confirm deletion
	var confirm_dialog = AcceptDialog.new()
	confirm_dialog.dialog_text = "Are you sure you want to delete save: %s?" % save_name
	confirm_dialog.title = "Confirm Deletion"
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()
	
	# Wait for confirmation
	await confirm_dialog.confirmed
	
	# Delete the save
	var success = terrain_data_manager.delete_save(save_name)
	
	if success:
		update_status("🗑️ Deleted save: %s" % save_name)
		refresh_save_list()
	else:
		update_status("❌ Failed to delete save: %s" % save_name)
	
	confirm_dialog.queue_free()

func _on_generate_button_pressed():
	"""Generate new environment"""
	if not terrain_controller:
		update_status("❌ Terrain controller not found")
		return
	
	update_status("🌲 Generating new environment...")
	generate_button.disabled = true
	
	# Call terrain generation functions
	if terrain_controller.has_method("generate_terrain_heightmap"):
		terrain_controller.generate_terrain_heightmap()
	
	if terrain_controller.has_method("generate_hexagonal_path_system"):
		terrain_controller.generate_hexagonal_path_system()
	
	update_status("✅ New environment generated")
	generate_button.disabled = false

func _on_clear_button_pressed():
	"""Clear all generated environment"""
	if not terrain_controller:
		update_status("❌ Terrain controller not found")
		return
	
	# Confirm clearing
	var confirm_dialog = AcceptDialog.new()
	confirm_dialog.dialog_text = "Are you sure you want to clear all generated environment?"
	confirm_dialog.title = "Confirm Clear"
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()
	
	# Wait for confirmation
	await confirm_dialog.confirmed
	
	update_status("🧹 Clearing all environment...")
	clear_button.disabled = true
	
	# Clear environment
	terrain_data_manager.clear_existing_environment(terrain_controller)
	
	update_status("✅ Environment cleared")
	clear_button.disabled = false
	
	confirm_dialog.queue_free()

func _on_close_button_pressed():
	"""Close the editor"""
	get_tree().quit()

func _on_data_saved(save_name: String):
	"""Handle successful data save"""
	update_status("✅ Environment data saved: %s" % save_name)
	save_button.disabled = false

func _on_data_loaded(save_name: String):
	"""Handle successful data load"""
	update_status("✅ Environment data loaded: %s" % save_name)
	load_button.disabled = false

func _on_save_failed(error_message: String):
	"""Handle save failure"""
	update_status("❌ Save failed: %s" % error_message)
	save_button.disabled = false

func _on_load_failed(error_message: String):
	"""Handle load failure"""
	update_status("❌ Load failed: %s" % error_message)
	load_button.disabled = false

func update_status(message: String):
	"""Update status display"""
	status_text.text = "[color=white]%s[/color]" % message
	GameLogger.info("Terrain3D Editor: %s" % message)

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_on_close_button_pressed()
