extends Node

# Test script to verify NPC interaction fix
# This will help confirm that the reinteraction issue is resolved

var player: Node = null
var interaction_controller: Node = null
var debug_timer: Timer = null
var test_results: Array = []

func _ready():
	# Wait a frame to ensure everything is loaded
	await get_tree().process_frame
	
	# Find the player and interaction controller
	player = get_tree().get_first_node_in_group("player")
	if player:
		interaction_controller = player.get_node("InteractionController")
		print("✓ Found player: ", player.name)
		var controller_name = interaction_controller.name if interaction_controller else "NOT FOUND"
	print("✓ Found interaction controller: ", controller_name)
	else:
		print("✗ Player not found!")
		return
	
	# Find all NPCs
	var npcs = get_tree().get_nodes_in_group("npc")
	print("✓ Found ", npcs.size(), " NPCs in scene")
	
	for npc in npcs:
		print("  - NPC: ", npc.name, " (Type: ", npc.npc_type, ")")
		var interaction_area = npc.get_node_or_null("InteractionArea")
		if interaction_area:
			print("    ✓ Has interaction area")
		else:
			print("    ✗ Missing interaction area")
	
	# Set up debug timer
	debug_timer = Timer.new()
	add_child(debug_timer)
	debug_timer.wait_time = 2.0  # Check every 2 seconds
	debug_timer.timeout.connect(_on_debug_timer_timeout)
	debug_timer.start()
	
	print("=== NPC Interaction Fix Test Started ===")
	print("Instructions:")
	print("1. Move near an NPC")
	print("2. Press E to interact")
	print("3. Complete dialogue and say goodbye")
	print("4. Try to interact again immediately")
	print("5. Wait 3 seconds and try again")
	print("Expected: No reinteraction until 3 seconds pass")

func _on_debug_timer_timeout():
	if not interaction_controller:
		return
	
	var debug_info = interaction_controller.get_debug_info()
	print("=== Interaction State ===")
	print("Current interactable: ", debug_info.current_interactable)
	print("Is near interactable: ", debug_info.is_near_interactable)
	print("NPCs in range: ", debug_info.npcs_in_range.size())
			var nearest_npc_name = debug_info.nearest_npc if debug_info.nearest_npc else "None"
		print("Nearest NPC: ", nearest_npc_name)
	print("Time since last interaction: ", debug_info.time_since_last_interaction, "s")
	print("Interaction cooldown: ", debug_info.interaction_cooldown, "s")
	print("Min reinteraction delay: ", debug_info.min_reinteraction_delay, "s")
	print("========================")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			print("=== E Key Pressed ===")
			if interaction_controller:
				var debug_info = interaction_controller.get_debug_info()
				print("Attempting interaction with: ", debug_info.current_interactable)
				var can_interact_status = debug_info.can_interact if debug_info.can_interact else "Unknown"
		print("Can interact: ", can_interact_status)
		elif event.keycode == KEY_R:
			print("=== Test Results ===")
			for result in test_results:
				print(result)
