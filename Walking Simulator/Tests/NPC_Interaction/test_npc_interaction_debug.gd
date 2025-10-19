extends Node

# Simple debug script for NPC interaction testing
# This will help monitor the interaction system in the isolated test scene

var player: Node = null
var interaction_controller: Node = null
var test_npc: Node = null
var debug_timer: Timer = null

func _ready():
	# Wait a frame to ensure everything is loaded
	await get_tree().process_frame
	
	# Find the key nodes
	player = get_tree().get_first_node_in_group("player")
	if player:
		interaction_controller = player.get_node("InteractionController")
	else:
		interaction_controller = null
	if get_parent():
		test_npc = get_node("../TestNPC")
	else:
		test_npc = null
	
	print("=== NPC Interaction Test Scene ===")
	var player_name = player.name if player else "NOT FOUND"
	var controller_name = interaction_controller.name if interaction_controller else "NOT FOUND"
	var npc_name = test_npc.name if test_npc else "NOT FOUND"
	print("✓ Player found: ", player_name)
	print("✓ InteractionController found: ", controller_name)
	print("✓ TestNPC found: ", npc_name)
	
	# Check if NPC is in the correct group
	if test_npc:
		print("✓ TestNPC in 'npc' group: ", test_npc.is_in_group("npc"))
		var interaction_area = test_npc.get_node_or_null("InteractionArea")
		print("✓ TestNPC has InteractionArea: ", interaction_area != null)
		if interaction_area:
			print("✓ InteractionArea collision mask: ", interaction_area.collision_mask)
			print("✓ InteractionArea collision layer: ", interaction_area.collision_layer)
	
	# Check player collision settings
	if player:
		print("✓ Player collision layer: ", player.collision_layer)
		print("✓ Player collision mask: ", player.collision_mask)
	
	# Set up debug timer
	debug_timer = Timer.new()
	add_child(debug_timer)
	debug_timer.wait_time = 1.0  # Check every second
	debug_timer.timeout.connect(_on_debug_timer_timeout)
	debug_timer.start()
	
	print("\n=== Test Instructions ===")
	print("1. Use WASD to move around (blue cylinder = player)")
	print("2. Approach the NPC (grey cylinder)")
	print("3. Press E when the interaction prompt appears")
	print("4. Complete the dialogue by pressing 1, 2, or 3")
	print("5. Try to interact again immediately (should be blocked)")
	print("6. Wait 3 seconds and try again (should work)")
	print("7. Move around while near NPC (should not flicker)")
	print("\n=== Starting Test ===")

func _on_debug_timer_timeout():
	if not interaction_controller:
		return
	
	# Get debug info
	var debug_info = interaction_controller.get_debug_info()
	
	print("=== Interaction State ===")
	print("Current interactable: ", debug_info.current_interactable)
	print("Is near interactable: ", debug_info.is_near_interactable)
	print("NPCs in range: ", debug_info.npcs_in_range)
	var nearest_npc_name = debug_info.nearest_npc if debug_info.nearest_npc else "None"
	print("Nearest NPC: ", nearest_npc_name)
	print("Time since last interaction: ", debug_info.time_since_last_interaction, "s")
	print("========================")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			print("=== E Key Pressed ===")
			if interaction_controller:
				var debug_info = interaction_controller.get_debug_info()
				print("Attempting interaction with: ", debug_info.current_interactable)
		elif event.keycode == KEY_R:
			print("=== Test Summary ===")
			print("Press R again to see this summary")
			print("Press E to test interaction")
			print("Use WASD to move around")
		elif event.keycode == KEY_1 or event.keycode == KEY_2 or event.keycode == KEY_3:
			print("=== Dialogue Choice: ", event.keycode - KEY_0, " ===")
