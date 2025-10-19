extends Node

# Centralized debug configuration
# Adjust these in one place to control verbosity across the game

# Log level mapping mirrors GameLogger.LogLevel
# 0=ERROR, 1=WARNING, 2=INFO, 3=DEBUG
var log_level: int = 3  # Set to DEBUG to see all messages for troubleshooting

# Module toggles - Focus ONLY on Pentagon wheel graph testing
var enable_scene_debugger: bool = false
var enable_npc_debug: bool = false         # DISABLED - too noisy
var enable_ui_debug: bool = false
var enable_input_debug: bool = true        # ENABLED - need to see KEY_5 detection

# Specific debug toggles - ONLY Pentagon wheel graph focus
var enable_npc_input_debug: bool = false  
var enable_timer_debug: bool = false      
var enable_tree_debug: bool = false     
var enable_terrain_debug: bool = false   
var enable_terrain_height_debug: bool = false  
var enable_asset_placement_debug: bool = false  

# PENTAGON WHEEL GRAPH FOCUS ONLY
var enable_graph_system_debug: bool = true      # Pentagon wheel graph generation
var enable_terrain3d_controller_debug: bool = true  # Controller initialization & KEY_5
var enable_baseGraph_debug: bool = true         # Pentagon graph creation

signal config_changed()

func _ready():
	# Optionally override via environment variables
	# e.g., GAME_LOG_LEVEL=3 to enable debug, SCENE_DEBUGGER=1 to enable scene debugger
	if OS.has_environment("GAME_LOG_LEVEL"):
		var lvl = int(OS.get_environment("GAME_LOG_LEVEL"))
		log_level = clamp(lvl, 0, 3)
	if OS.has_environment("SCENE_DEBUGGER"):
		enable_scene_debugger = OS.get_environment("SCENE_DEBUGGER") in ["1", "true", "TRUE"]
	if OS.has_environment("NPC_DEBUG"):
		enable_npc_debug = OS.get_environment("NPC_DEBUG") in ["1", "true", "TRUE"]
	if OS.has_environment("UI_DEBUG"):
		enable_ui_debug = OS.get_environment("UI_DEBUG") in ["1", "true", "TRUE"]
	if OS.has_environment("INPUT_DEBUG"):
		enable_input_debug = OS.get_environment("INPUT_DEBUG") in ["1", "true", "TRUE"]
	if OS.has_environment("TERRAIN_DEBUG"):
		enable_terrain_debug = OS.get_environment("TERRAIN_DEBUG") in ["1", "true", "TRUE"]
	
	# Emit signal for GameLogger to update
	config_changed.emit()

# Methods to dynamically change debug settings during runtime
func set_log_level(level: int):
	log_level = clamp(level, 0, 3)
	config_changed.emit()

func enable_error_focus():
	"""Enable only error logging for focused debugging"""
	log_level = 3  # DEBUG level to see all input flow and KEY_5 detection
	enable_scene_debugger = false
	enable_npc_debug = false
	enable_ui_debug = false
	enable_input_debug = false
	enable_terrain_debug = false
	enable_terrain_height_debug = false
	enable_asset_placement_debug = false
	config_changed.emit()

func enable_graph_system_focus():
	"""Enable focused debugging for GraphSystem testing"""
	log_level = 1  # ERROR + WARNING
	enable_graph_system_debug = true
	enable_terrain3d_controller_debug = true
	enable_baseGraph_debug = true
	config_changed.emit()

# Test method to verify configuration
func test_logger_focus():
	"""Test the GameLogger focus configuration"""
	print("🧪 Testing GameLogger focus configuration...")
	enable_error_focus()
	
	# Load and run the test script
	var test_scene = preload("res://Tests/Core_Systems/test_gamelogger_focus.gd")
	var test_instance = test_scene.new()
	get_tree().current_scene.add_child(test_instance)
