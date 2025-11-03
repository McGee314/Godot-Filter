extends Node

# Game Logger Singleton for automatic debug logging
# Automatically saves all debug output to timestamped log files

var log_file: FileAccess
var current_log_path: String
var log_level: int = 0  # 0=Error, 1=Warning, 2=Info, 3=Debug

# Log levels
enum LogLevel {
	ERROR = 0,
	WARNING = 1,
	INFO = 2,
	DEBUG = 3
}

func _ready():
	# Initialize from DebugConfig if available
	if has_node("/root/DebugConfig"):
		var cfg = get_node("/root/DebugConfig")
		log_level = int(cfg.log_level)
		# Connect to DebugConfig changes
		if cfg.has_signal("config_changed"):
			cfg.config_changed.connect(_on_debug_config_changed)
	
	# Create logs directory if it doesn't exist
	var logs_dir = "logs"
	if not DirAccess.dir_exists_absolute(logs_dir):
		DirAccess.make_dir_absolute(logs_dir)
	
	# Create timestamped log file
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	current_log_path = logs_dir + "/game_log_" + timestamp + ".log"
	
	# Open log file
	log_file = FileAccess.open(current_log_path, FileAccess.WRITE)
	if log_file:
		write_log("Game Logger initialized - Log file: " + current_log_path, LogLevel.INFO)
	else:
		push_error("Failed to create log file: " + current_log_path)

func _exit_tree():
	if log_file:
		write_log("Game Logger shutting down", LogLevel.INFO)
		log_file.close()

func write_log(message: String, level: LogLevel = LogLevel.INFO, category: String = ""):
	# Filter by configured level
	if level > log_level:
		return
	
	# Category-based filtering for focused debugging
	if category != "" and has_node("/root/DebugConfig"):
		var debug_config = get_node("/root/DebugConfig")
		var should_log = _should_log_category(category, debug_config)
		if not should_log and level != LogLevel.ERROR:
			return
	
	var timestamp = Time.get_datetime_string_from_system()
	var level_name = LogLevel.keys()[level]
	var category_prefix = "[%s] " % category if category != "" else ""
	var log_entry = "[%s] [%s] %s%s" % [timestamp, level_name, category_prefix, message]
	
	# Write to file only (no console output to reduce debug spam)
	if log_file:
		log_file.store_line(log_entry)
		log_file.flush()
	
	# Only show critical errors in console, everything else goes to file only
	if level == LogLevel.ERROR:
		push_error("🔥 %s%s" % [category_prefix, message])

func _should_log_category(category: String, debug_config: Node) -> bool:
	"""Check if a specific category should be logged based on DebugConfig"""
	match category.to_lower():
		"graphsystem", "graph_system", "basegraph", "base_graph":
			return debug_config.enable_graph_system_debug
		"terrain3dcontroller", "terrain3d_controller", "terrain_controller":
			return debug_config.enable_terrain3d_controller_debug
		"terrain3d", "terrain":
			return debug_config.enable_terrain_debug
		"npc":
			return debug_config.enable_npc_debug
		"ui":
			return debug_config.enable_ui_debug
		"scene":
			return debug_config.enable_scene_debugger
		_:
			return true  # Log uncategorized messages

# Convenience methods
func error(message: String, category: String = ""):
	write_log(message, LogLevel.ERROR, category)

func warning(message: String, category: String = ""):
	write_log(message, LogLevel.WARNING, category)

func info(message: String, category: String = ""):
	write_log(message, LogLevel.INFO, category)

func debug(message: String, category: String = ""):
	write_log(message, LogLevel.DEBUG, category)

# Specific category methods for focused debugging
func graph_error(message: String):
	error(message, "GraphSystem")

func graph_warning(message: String):
	warning(message, "GraphSystem")

func terrain_error(message: String):
	error(message, "Terrain3DController")

func terrain_warning(message: String):
	warning(message, "Terrain3DController")

# Set log level (0=Error only, 3=All messages)
func set_log_level(level: int):
	log_level = clamp(level, 0, 3)
	# Don't spam when set to silent modes
	if log_level >= LogLevel.INFO:
		info("Log level set to: " + str(log_level))

# Get current log file path
func get_log_path() -> String:
	return current_log_path

# Handle DebugConfig changes
func _on_debug_config_changed():
	if has_node("/root/DebugConfig"):
		var cfg = get_node("/root/DebugConfig")
		log_level = int(cfg.log_level)
		info("Log level updated to: " + str(log_level))
