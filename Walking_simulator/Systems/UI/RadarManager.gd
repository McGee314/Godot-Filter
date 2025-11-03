class_name RadarManager
extends Node

# Radar instance
var radar_system: RadarSystem

# Radar configuration
@export var auto_show_radar: bool = true
@export var radar_show_duration: float = 3.0  # How long to show radar when entering scene

# Radar state
var is_radar_enabled: bool = true
var radar_timer: Timer

func _ready():
	setup_radar()
	setup_timer()
	
	# Connect to scene change signals
	if GameSceneManager:
		GameSceneManager.scene_changed.connect(_on_scene_changed)

func setup_radar():
	# Create radar instance
	var radar_scene = preload("res://Systems/UI/RadarSystem.tscn")
	radar_system = radar_scene.instantiate()
	
	# Add to current scene
	get_tree().current_scene.add_child(radar_system)
	
	# Position radar in top-right corner
	radar_system.position = Vector2(get_viewport().size.x - 220, 20)
	
	GameLogger.info("RadarManager: Radar system initialized")

func setup_timer():
	radar_timer = Timer.new()
	radar_timer.wait_time = radar_show_duration
	radar_timer.one_shot = true
	radar_timer.timeout.connect(_on_radar_timer_timeout)
	add_child(radar_timer)

func _on_scene_changed(scene_name: String):
	# Handle radar for different scenes
	match scene_name:
		"TamboraScene", "PapuaScene":
			# Outdoor scenes - show radar longer
			show_radar_for_outdoor_scene()
		"PasarScene":
			# Indoor scene - show radar briefly
			show_radar_for_indoor_scene()
		_:
			# Other scenes - hide radar
			hide_radar()

func show_radar_for_outdoor_scene():
	if not is_radar_enabled:
		return
	
	# Show radar for outdoor scenes (larger maps)
	radar_system.show_radar()
	radar_timer.wait_time = 5.0  # Show longer for outdoor scenes
	radar_timer.start()
	
	GameLogger.debug("RadarManager: Showing radar for outdoor scene")

func show_radar_for_indoor_scene():
	if not is_radar_enabled:
		return
	
	# Show radar briefly for indoor scenes
	radar_system.show_radar()
	radar_timer.wait_time = 2.0  # Show briefly for indoor scenes
	radar_timer.start()
	
	GameLogger.debug("RadarManager: Showing radar for indoor scene")

func _on_radar_timer_timeout():
	# Auto-hide radar after timer expires
	if radar_system:
		radar_system.hide_radar()
	GameLogger.debug("RadarManager: Auto-hiding radar")

func show_radar():
	if radar_system and is_radar_enabled:
		radar_system.show_radar()
		radar_timer.stop()  # Stop auto-hide timer

func hide_radar():
	if radar_system:
		radar_system.hide_radar()
		radar_timer.stop()

func toggle_radar():
	if radar_system:
		radar_system.toggle_radar()
		radar_timer.stop()  # Stop auto-hide timer when manually toggled

func enable_radar():
	is_radar_enabled = true
	GameLogger.debug("RadarManager: Radar enabled")

func disable_radar():
	is_radar_enabled = false
	hide_radar()
	GameLogger.debug("RadarManager: Radar disabled")

func refresh_radar():
	if radar_system:
		radar_system.refresh_radar()

# Get radar system for external access
func get_radar_system() -> RadarSystem:
	return radar_system

# Check if radar is visible
func is_radar_visible() -> bool:
	if radar_system:
		return radar_system.visible
	return false
