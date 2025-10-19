extends Node

# Test script to debug interaction system
# This will help monitor the reinteraction issue

var player: Node = null
var interaction_controller: Node = null
var debug_timer: Timer = null
var frame_count: int = 0

func _ready():
	# Wait a frame to ensure everything is loaded
	await get_tree().process_frame
	
	# Find the player
	player = get_tree().get_first_node_in_group("player")
	if player:
		interaction_controller = player.get_node("InteractionController")
		print("Found player: ", player.name)
		var controller_name = interaction_controller.name if interaction_controller else "NOT FOUND"
	print("Found interaction controller: ", controller_name)
	else:
		print("Player not found!")
		return
	
	# Set up debug timer
	debug_timer = Timer.new()
	add_child(debug_timer)
	debug_timer.wait_time = 1.0  # Log every second
	debug_timer.timeout.connect(_on_debug_timer_timeout)
	debug_timer.start()
	
	print("Interaction debug test started")

func _process(_delta):
	frame_count += 1
	
	# Monitor interaction state every 60 frames (1 second at 60fps)
	if frame_count % 60 == 0 and interaction_controller:
		var current_interactable = interaction_controller.get_current_interactable()
		var is_near = interaction_controller.is_player_near_interactable()
		
		if current_interactable:
			print("Frame ", frame_count, ": Near interactable - ", current_interactable.name, " (can_interact: ", current_interactable.can_interact, ")")
		elif is_near:
			print("Frame ", frame_count, ": Near interactable but current_interactable is null!")
		else:
			print("Frame ", frame_count, ": No interactable in range")

func _on_debug_timer_timeout():
	if interaction_controller:
		print("=== INTERACTION DEBUG REPORT ===")
		var current_interactable = interaction_controller.get_current_interactable()
		var interactable_name = current_interactable.name if current_interactable else "None"
		print("Current interactable: ", interactable_name)
		print("Is near interactable: ", interaction_controller.is_player_near_interactable())
		
		# Access private variables for debugging (if possible)
		if interaction_controller.has_method("get_debug_info"):
			var debug_info = interaction_controller.get_debug_info()
			print("Debug info: ", debug_info)
		
		print("================================")

func _input(event):
	# Test input to reset interaction state
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				if interaction_controller and interaction_controller.has_method("reset_interaction_state"):
					interaction_controller.reset_interaction_state()
					print("Interaction state reset (R key pressed)")
			KEY_C:
				if interaction_controller and interaction_controller.has_method("clear_interaction_history"):
					interaction_controller.clear_interaction_history()
					print("Interaction history cleared (C key pressed)")
			KEY_D:
				print("=== MANUAL DEBUG DUMP ===")
				if interaction_controller:
					print("Current interactable: ", interaction_controller.get_current_interactable())
					print("Is near interactable: ", interaction_controller.is_player_near_interactable())
				print("========================")
