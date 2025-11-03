extends Node3D

## Test script for PlayerControllerRefactored
## Demonstrates smooth movement and following camera system

var player: Node  # Changed to Node to accept any player controller type
var status_label: Label
var jitter_helper: JitterTestHelper
var start_jitter_button: Button
var stop_jitter_button: Button
var results_jitter_button: Button

# FPS monitoring
var fps_label: Label
var fps_update_timer: float = 0.0
var fps_update_interval: float = 0.5  # Update FPS every 0.5 seconds
var frame_count: int = 0
var fps: float = 0.0

func _ready():
	print("=== PlayerControllerRefactored Test ===")
	print("🎮 Testing enhanced player movement and camera system")
	
	# Get player reference
	player = get_node_or_null("Player")
	if not player:
		print("❌ Player not found")
		return
	
	print("✅ Found player: " + str(player.get_path()))
	print("Player type: " + str(player.get_class()))
	
	# Add player to group for jitter testing
	if not player.is_in_group("player"):
		player.add_to_group("player")
		print("✅ Added player to 'player' group for jitter testing")
	
	# Setup UI
	setup_ui()
	
	# Setup jitter helper
	setup_jitter_helper()
	
	print("🔧 Test environment ready")
	print("📋 Controls:")
	print("  - WASD: Move")
	print("  - SPACE: Jump")
	print("  - SHIFT: Run")
	print("  - Mouse: Look around")
	print("  - ESC: Exit")
	print("  - J: Start jitter test")
	print("  - K: Stop jitter test")
	print("  - L: Print jitter results")

func setup_ui():
	# Create UI for test information
	var ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Main panel
	var panel = Panel.new()
	panel.position = Vector2(10, 10)
	panel.size = Vector2(400, 300)
	ui_layer.add_child(panel)
	
	# VBox for layout
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(10, 10)
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "Player Controller Test"
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	# Status label
	status_label = Label.new()
	status_label.text = "Status: Initializing..."
	vbox.add_child(status_label)
	
	# FPS label
	fps_label = Label.new()
	fps_label.text = "FPS: --"
	vbox.add_child(fps_label)
	
	# Separator
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	# Jitter test section
	var jitter_title = Label.new()
	jitter_title.text = "Jitter Testing:"
	jitter_title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(jitter_title)
	
	# Jitter buttons
	start_jitter_button = Button.new()
	start_jitter_button.text = "Start Jitter Test (J)"
	start_jitter_button.pressed.connect(_on_start_jitter_test)
	vbox.add_child(start_jitter_button)
	
	stop_jitter_button = Button.new()
	stop_jitter_button.text = "Stop Jitter Test (K)"
	stop_jitter_button.pressed.connect(_on_stop_jitter_test)
	vbox.add_child(stop_jitter_button)
	
	results_jitter_button = Button.new()
	results_jitter_button.text = "Show Results (L)"
	results_jitter_button.pressed.connect(_on_show_jitter_results)
	vbox.add_child(results_jitter_button)
	
	print("✅ UI setup complete")

func setup_jitter_helper():
	# Create jitter test helper
	jitter_helper = JitterTestHelper.new()
	add_child(jitter_helper)
	print("✅ Jitter test helper initialized")

func _process(delta):
	# Update status
	update_status()
	
	# Update FPS counter
	update_fps_counter(delta)

func update_status():
	if not player or not status_label:
		return
	
	var status_text = "Status: Active\n"
	
	# Player position
	if player.has_method("get_player_position"):
		var pos = player.get_player_position()
		status_text += "Position: (%.1f, %.1f, %.1f)\n" % [pos.x, pos.y, pos.z]
	elif "position" in player:
		var pos = player.position
		status_text += "Position: (%.1f, %.1f, %.1f)\n" % [pos.x, pos.y, pos.z]
	
	# Player velocity
	if player.has_method("get_player_velocity"):
		var vel = player.get_player_velocity()
		status_text += "Velocity: (%.1f, %.1f, %.1f)\n" % [vel.x, vel.y, vel.z]
	elif "velocity" in player:
		var vel = player.velocity
		status_text += "Velocity: (%.1f, %.1f, %.1f)\n" % [vel.x, vel.y, vel.z]
	
	# Player state
	if player.has_method("is_player_running"):
		status_text += "Running: %s\n" % player.is_player_running()
	
	if player.has_method("is_player_on_ground"):
		status_text += "Grounded: %s\n" % player.is_player_on_ground()
	elif player.has_method("is_on_floor"):
		status_text += "Grounded: %s\n" % player.is_on_floor()
	
	status_label.text = status_text

func update_fps_counter(delta):
	frame_count += 1
	fps_update_timer += delta
	
	if fps_update_timer >= fps_update_interval:
		fps = frame_count / fps_update_timer
		frame_count = 0
		fps_update_timer = 0.0
		
		if fps_label:
			fps_label.text = "FPS: %.1f" % fps

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_J:
				_on_start_jitter_test()
			KEY_K:
				_on_stop_jitter_test()
			KEY_L:
				_on_show_jitter_results()
			KEY_ESCAPE:
				print("ESC pressed - exiting test")
				get_tree().quit()

func _on_start_jitter_test():
	if jitter_helper:
		jitter_helper.start_jitter_test()
		print("🧪 Jitter test started via UI")

func _on_stop_jitter_test():
	if jitter_helper:
		jitter_helper.stop_jitter_test()
		print("🛑 Jitter test stopped via UI")

func _on_show_jitter_results():
	if jitter_helper:
		jitter_helper.print_test_results()
		print("📊 Jitter results printed via UI")

func _exit_tree():
	print("🔧 PlayerControllerTest cleaning up...")
	
	# Clean up jitter helper
	if jitter_helper:
		jitter_helper.stop_jitter_test()
	
	print("✅ Test cleanup complete")
