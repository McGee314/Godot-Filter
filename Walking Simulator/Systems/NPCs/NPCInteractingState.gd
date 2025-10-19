class_name NPCInteractingState
extends NPCState

# Interacting state for NPCs - handles player interaction
# Implements Single Responsibility Principle - handles only interaction behavior

var interaction_start_time: float = 0.0
var dialogue_system: NPCDialogueSystem

func enter():
	GameLogger.debug(npc.npc_name + " entered interacting state")
	interaction_start_time = Time.get_unix_time_from_system()
	
	# Face the player
	face_player()
	
	# Start interaction
	start_interaction()

func update(delta: float):
	# Check if player is still nearby
	if not check_player_proximity():
		# Player moved away, end interaction
		end_interaction()
		change_to_idle()
		return
	
	# Continue facing player
	face_player()
	
	# Handle dialogue updates
	if dialogue_system:
		dialogue_system.update(delta)

func start_interaction():
	# Emit interaction signal
	EventBus.emit_npc_interaction(npc.npc_name, npc.cultural_region)
	
	# Create dialogue system
	dialogue_system = NPCDialogueSystem.new(npc)
	
	# Start dialogue
	dialogue_system.start_dialogue()

func end_interaction():
	# Emit end interaction signal
	EventBus.emit_event(EventBus.EventType.NPC_INTERACTION, {
		"npc_name": npc.npc_name,
		"region": npc.cultural_region,
		"action": "end_interaction"
	}, 1, "npc_system")
	
	# Clean up dialogue system
	if dialogue_system:
		dialogue_system.end_dialogue()
		dialogue_system = null

func handle_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# Player wants to end interaction
				end_interaction()
				change_to_idle()
			KEY_ENTER, KEY_SPACE:
				# Continue dialogue
				if dialogue_system:
					dialogue_system.continue_dialogue()

func exit():
	GameLogger.debug(npc.npc_name + " exited interacting state")
	end_interaction()

func get_state_name() -> String:
	return "InteractingState"
