class_name MainMenuController
extends Control

# Exhibition title and branding
@export var exhibition_title: String = "Indonesian Cultural Heritage Exhibition"
@export var seminar_info: String = "International Seminar on Indonesian Cultural Diversity"

# Scene references for the three regions
@export var indonesia_barat_scene: PackedScene
@export var indonesia_tengah_scene: PackedScene
@export var indonesia_timur_scene: PackedScene

# 3D Map system
@export var indonesia_3d_map_scene: PackedScene
@export var indonesia_3d_map_final_scene: PackedScene

# UI elements - Main Menu
@onready var main_menu_container: VBoxContainer = $MainMenuContainer
@onready var title_label: Label = $MainMenuContainer/TitleLabel
@onready var subtitle_label: Label = $MainMenuContainer/SubtitleLabel
@onready var start_game_button: Button = $MainMenuContainer/MainButtons/StartGameButton
@onready var explore_3d_map_button: Button = $MainMenuContainer/MainButtons/Explore3DMapButton
@onready var topeng_nusantara_button: Button = $MainMenuContainer/MainButtons/TopengNusantaraButton
@onready var load_game_button: Button = $MainMenuContainer/MainButtons/LoadGameButton
@onready var how_to_play_button: Button = $MainMenuContainer/MainButtons/HowToPlayButton
@onready var about_us_button: Button = $MainMenuContainer/MainButtons/AboutUsButton
@onready var credits_button: Button = $MainMenuContainer/MainButtons/CreditsButton
@onready var exit_button: Button = $MainMenuContainer/MainButtons/ExitButton
@onready var instructions_label: Label = $MainMenuContainer/InstructionsLabel

# UI elements - Start Game Submenu
@onready var start_game_submenu: Control = $StartGameSubmenu
@onready var indonesia_barat_button: Button = $StartGameSubmenu/SubmenuContainer/MapContainer/RegionButtons/IndonesiaBaratButton
@onready var indonesia_tengah_button: Button = $StartGameSubmenu/SubmenuContainer/MapContainer/RegionButtons/IndonesiaTengahButton
@onready var indonesia_timur_button: Button = $StartGameSubmenu/SubmenuContainer/MapContainer/RegionButtons/IndonesiaTimurButton
@onready var back_button: Button = $StartGameSubmenu/SubmenuContainer/BackButton
@onready var indonesia_map: TextureRect = $StartGameSubmenu/SubmenuContainer/MapContainer/IndonesiaMap

# UI elements - Other Panels
@onready var how_to_play_panel: Control = $HowToPlayPanel
@onready var about_us_panel: Control = $AboutUsPanel
@onready var credits_panel: Control = $CreditsPanel

# Audio
@onready var button_sound: AudioStreamPlayer = $ButtonSound

# Zoom effect variables
var original_map_scale: Vector2 = Vector2.ONE
var zoom_duration: float = 1.0
var is_zooming: bool = false

func _ready():
	# Set up the main menu
	GameLogger.info("🚀 MainMenuController _ready() called")
	setup_menu()
	connect_signals()
	GameLogger.info("✅ MainMenuController initialization completed")
	
	# Always show main menu (removed auto-opening of 2D region selection)
	# Since we're using 3D map directly, no need to show 2D region selection
	
	# Set focus to explore map button since start game is hidden
	explore_3d_map_button.grab_focus()
	# Ensure main menu is visible and submenus are hidden
	show_main_menu()
	
	# Store original map scale
	original_map_scale = indonesia_map.scale

func setup_menu():
	# Set exhibition title and info
	title_label.text = exhibition_title
	subtitle_label.text = seminar_info
	
	# Hide start game button - using 3D map directly
	start_game_button.visible = false
	explore_3d_map_button.text = "Explore Indonesia Map"
	load_game_button.text = "Load Game"
	how_to_play_button.text = "How to Play"
	about_us_button.text = "About Us"
	credits_button.text = "Credits"
	
	# Set region button texts
	indonesia_barat_button.text = "Indonesia Barat\nTraditional Market"
	indonesia_tengah_button.text = "Indonesia Tengah\nMount Tambora"
	indonesia_timur_button.text = "Indonesia Timur\nPapua Highlands"
	
	# Set instructions
	instructions_label.text = "Explore Indonesian cultural heritage through interactive experiences"

func connect_signals():
	# Main menu buttons
	# Start game button hidden - using 3D map directly
	# if not start_game_button.pressed.is_connected(_on_start_game_pressed):
	#	start_game_button.pressed.connect(_on_start_game_pressed)
	if not explore_3d_map_button.pressed.is_connected(_on_explore_3d_map_pressed):
		explore_3d_map_button.pressed.connect(_on_explore_3d_map_pressed)
	if not load_game_button.pressed.is_connected(_on_load_game_pressed):
		load_game_button.pressed.connect(_on_load_game_pressed)
	if not how_to_play_button.pressed.is_connected(_on_how_to_play_pressed):
		how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	if not about_us_button.pressed.is_connected(_on_about_us_pressed):
		about_us_button.pressed.connect(_on_about_us_pressed)
	if not credits_button.pressed.is_connected(_on_credits_pressed):
		credits_button.pressed.connect(_on_credits_pressed)
	if not exit_button.pressed.is_connected(_on_exit_game_pressed):
		exit_button.pressed.connect(_on_exit_game_pressed)
		GameLogger.info("✅ Connected Exit Game button signal")
	else:
		GameLogger.info("ℹ️ Exit Game button signal already connected")
	
	# Region buttons
	if not indonesia_barat_button.pressed.is_connected(_on_indonesia_barat_pressed):
		indonesia_barat_button.pressed.connect(_on_indonesia_barat_pressed)
	if not indonesia_tengah_button.pressed.is_connected(_on_indonesia_tengah_pressed):
		indonesia_tengah_button.pressed.connect(_on_indonesia_tengah_pressed)
	if not indonesia_timur_button.pressed.is_connected(_on_indonesia_timur_pressed):
		indonesia_timur_button.pressed.connect(_on_indonesia_timur_pressed)
	
	# Back buttons
	if not back_button.pressed.is_connected(_on_back_to_main_pressed):
		back_button.pressed.connect(_on_back_to_main_pressed)

# Main Menu Navigation
# Start game functionality removed - using 3D map directly
# func _on_start_game_pressed():
#	play_button_sound()
#	show_start_game_submenu()

func _on_explore_3d_map_pressed():
	play_button_sound()
	show_3d_map_final()

func _on_load_game_pressed():
	play_button_sound()
	show_load_game_dialog()

func _on_how_to_play_pressed():
	play_button_sound()
	show_how_to_play_panel()

func _on_about_us_pressed():
	play_button_sound()
	show_about_us_panel()

func _on_credits_pressed():
	play_button_sound()
	show_credits_panel()

func _on_exit_game_pressed():
	play_button_sound()
	GameLogger.info("🔘 Exit Game button pressed - showing unified confirmation dialog")
	UnifiedExitDialog.show_main_menu_exit_dialog()

func _on_ethnicity_detection_pressed():
	play_button_sound()
	GameLogger.info("🔍 Ethnicity Detection button pressed - navigating to ethnicity detection")
	get_tree().change_scene_to_file("res://Scenes/EthnicityDetection/EthnicityDetectionScene.tscn")

func _on_topeng_nusantara_pressed():
	play_button_sound()
	GameLogger.info("🎭 Topeng Nusantara button pressed - navigating to mask selection")
	get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengSelectionScene.tscn")

func show_load_game_dialog():
	# Check if save data exists
	if has_node("/root/GameSceneManager"):
		var scene_manager = get_node("/root/GameSceneManager")
		if scene_manager and scene_manager.has_save_data():
			# Show load confirmation with save info
			show_load_confirmation()
		else:
			# Show no save data message
			show_no_save_data_message()
	else:
		show_no_save_data_message()

func show_load_confirmation():
	var scene_manager = get_node("/root/GameSceneManager")
	var last_region = scene_manager.get_last_region()
	var last_save_time = scene_manager.get_last_save_time()
	
	GameLogger.info("🔧 Creating load game confirmation dialog...")
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Load last checkpoint?\n\nRegion: " + last_region + "\nSaved: " + last_save_time
	popup.title = "Load Game"
	
	# ConfirmationDialog automatically has OK (Yes) and Cancel (No) buttons
	popup.get_ok_button().text = "Yes"
	popup.get_cancel_button().text = "No"
	
	# Ensure mouse is visible for dialog interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	popup.confirmed.connect(_on_load_confirmed)
	popup.canceled.connect(_on_load_canceled)
	
	add_child(popup)
	popup.popup_centered()
	GameLogger.info("✅ Load game dialog shown")

func show_no_save_data_message():
	var popup = AcceptDialog.new()
	popup.dialog_text = "No save data found.\nStart a new game to create a checkpoint."
	popup.title = "No Save Data"
	popup.add_button("OK", true, "ok")
	
	popup.confirmed.connect(_on_no_save_confirmed)
	popup.custom_action.connect(_on_no_save_confirmed)
	
	add_child(popup)
	popup.popup_centered()

func _on_load_confirmed():
	# User chose Yes - load the checkpoint
	GameLogger.info("✅ User chose YES on load dialog - loading checkpoint")
	load_last_checkpoint()

func _on_load_canceled():
	# User chose No - close dialog and stay in main menu
	GameLogger.info("✅ User chose NO on load dialog - staying in main menu")
	# Dialog automatically closes, no action needed

func _on_no_save_confirmed(_action: String):
	# Ensure the dialog is freed before proceeding
	var dialog = get_parent()
	if dialog is AcceptDialog:
		dialog.queue_free()
	# Return to main menu
	show_main_menu()

func load_last_checkpoint():
	var scene_manager = get_node("/root/GameSceneManager")
	if scene_manager.load_last_checkpoint():
		GameLogger.info("Checkpoint loaded successfully")
	else:
		GameLogger.error("Failed to load checkpoint")
		# Show error message
		var popup = AcceptDialog.new()
		popup.dialog_text = "Failed to load checkpoint.\nPlease try starting a new game."
		popup.title = "Load Error"
		popup.add_button("OK", true, "ok")
		
		popup.confirmed.connect(_on_load_error_confirmed)
		popup.custom_action.connect(_on_load_error_confirmed)
		
		add_child(popup)
		popup.popup_centered()

func _on_load_error_confirmed(_action: String):
	# Ensure the dialog is freed before proceeding
	var dialog = get_parent()
	if dialog is AcceptDialog:
		dialog.queue_free()
	# Return to main menu
	show_main_menu()

func _on_back_to_main_pressed():
	play_button_sound()
	show_main_menu()

# Panel Visibility Management
func show_main_menu():
	main_menu_container.visible = true
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = false
	start_game_button.grab_focus()

func show_start_game_submenu():
	main_menu_container.visible = false
	start_game_submenu.visible = true
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = false
	indonesia_barat_button.grab_focus()
	
	# Reset map scale when showing submenu
	indonesia_map.scale = original_map_scale
	is_zooming = false

func show_load_game_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = false

func show_how_to_play_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = true
	about_us_panel.visible = false
	credits_panel.visible = false

func show_about_us_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = true
	credits_panel.visible = false

func show_credits_panel():
	main_menu_container.visible = false
	start_game_submenu.visible = false
	how_to_play_panel.visible = false
	about_us_panel.visible = false
	credits_panel.visible = true

func show_3d_map():
	"""Show the original 3D Indonesia map (for learning/reference)"""
	GameLogger.info("Loading original 3D Indonesia Map...")
	
	# Load the original 3D map scene
	if indonesia_3d_map_scene:
		get_tree().change_scene_to_packed(indonesia_3d_map_scene)
	else:
		# Fallback to direct scene loading
		var scene_path = "res://Scenes/MainMenu/Indonesia3DMap.tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			GameLogger.error("3D Map scene not found: " + scene_path)

func show_3d_map_final():
	"""Show the final working 3D Indonesia map with saved coordinates"""
	GameLogger.info("Loading final 3D Indonesia Map...")
	
	# Load the final 3D map scene
	if indonesia_3d_map_final_scene:
		get_tree().change_scene_to_packed(indonesia_3d_map_final_scene)
	else:
		# Fallback to direct scene loading
		var scene_path = "res://Scenes/MainMenu/Indonesia3DMapFinal.tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			GameLogger.error("Final 3D Map scene not found: " + scene_path)
			show_error_message("3D Map not available yet!")

# Region Selection with Zoom Effect
func _on_indonesia_barat_pressed():
	if is_zooming:
		return
	play_button_sound()
	zoom_to_region("Indonesia Barat", indonesia_barat_scene)

func _on_indonesia_tengah_pressed():
	if is_zooming:
		return
	play_button_sound()
	zoom_to_region("Indonesia Tengah", indonesia_tengah_scene)

func _on_indonesia_timur_pressed():
	if is_zooming:
		return
	play_button_sound()
	zoom_to_region("Indonesia Timur", indonesia_timur_scene)

func zoom_to_region(region_name: String, scene: PackedScene):
	is_zooming = true
	
	# Create zoom effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Zoom in effect
	tween.tween_property(indonesia_map, "scale", Vector2(2.0, 2.0), zoom_duration * 0.6)
	tween.tween_property(indonesia_map, "modulate", Color(1.2, 1.2, 1.0), zoom_duration * 0.6)
	
	# Wait a moment at zoom level
	await get_tree().create_timer(zoom_duration * 0.4).timeout
	
	# Show loading message
	show_loading_message("Loading " + region_name + "...")
	
	# Wait for loading message
	await get_tree().create_timer(1.0).timeout
	
	# Change scene
	change_scene(scene, region_name)

func change_scene(scene: PackedScene, region_name: String):
	if scene:
		# Store current region for reference
		Global.current_region = region_name
		Global.start_region_session(region_name)
		get_tree().change_scene_to_packed(scene)
	else:
		# Fallback to direct scene file loading
		var scene_path = ""
		match region_name:
			"Indonesia Barat":
				scene_path = "res://Scenes/IndonesiaBarat/PasarScene.tscn"
			"Indonesia Tengah":
				scene_path = "res://Scenes/IndonesiaTengah/TamboraScene.tscn"
			"Indonesia Timur":
				scene_path = "res://Scenes/IndonesiaTimur/PapuaScene.tscn"
		
		if scene_path:
			Global.current_region = region_name
			Global.start_region_session(region_name)
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Warning: Scene not assigned for ", region_name)
			show_error_message("Scene not available yet. Coming soon!")

func play_button_sound():
	if button_sound and button_sound.stream:
		button_sound.play()

func show_loading_message(message: String):
	# Create a simple loading overlay
	var loading_overlay = ColorRect.new()
	loading_overlay.color = Color(0, 0, 0, 0.8)
	loading_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var loading_label = Label.new()
	loading_label.text = message
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.add_theme_font_size_override("font_size", 24)
	loading_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	loading_overlay.add_child(loading_label)
	add_child(loading_overlay)
	
	# Remove overlay after scene change
	await get_tree().process_frame
	loading_overlay.queue_free()

func show_error_message(message: String):
	# Create error message popup
	var popup = AcceptDialog.new()
	popup.dialog_text = message
	popup.title = "Information"
	add_child(popup)
	popup.popup_centered()

# Keyboard shortcuts for quick access
func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Enter key - activate focused button
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Button:
			focused.pressed.emit()
	
	elif event.is_action_pressed("ui_cancel"):
		# Escape key - navigate to 3D map from region selection, or back to main menu from other panels
		if start_game_submenu.visible:
			# From region selection, go to 3D map
			GameLogger.info("ESC pressed from region selection - navigating to 3D map")
			show_3d_map_final()
		elif how_to_play_panel.visible or about_us_panel.visible or credits_panel.visible:
			# From other panels, go back to main menu
			_on_back_to_main_pressed()
