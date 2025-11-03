class_name NPCTalkingState
extends NPCState

# Talking state for NPCs - handles dialogue and conversation
# Implements Single Responsibility Principle - handles only talking behavior

var dialogue_system: NPCDialogueSystem
var talking_timer: float = 0.0
var max_talking_time: float = 30.0

func enter():
	GameLogger.debug(npc.npc_name + " entered talking state")
	talking_timer = 0.0
	
	# Face the player
	face_player()
	
	# Initialize dialogue system
	dialogue_system = NPCDialogueSystem.new(npc)
	dialogue_system.start_dialogue()

func update(delta: float):
	# Check if player is still nearby
	if not check_player_proximity():
		end_talking()
		change_to_idle()
		return
	
	# Continue facing player
	face_player()
	
	# Update dialogue system
	if dialogue_system:
		dialogue_system.update(delta)
	
	# Check talking time limit
	talking_timer += delta
	if talking_timer >= max_talking_time:
		end_talking()
		change_to_idle()

func handle_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# End conversation
				end_talking()
				change_to_idle()
			KEY_ENTER, KEY_SPACE:
				# Continue dialogue
				if dialogue_system:
					dialogue_system.continue_dialogue()
			KEY_1, KEY_2, KEY_3, KEY_4:
				# Handle dialogue choices
				if dialogue_system:
					var choice_index = event.keycode - KEY_1
					dialogue_system.select_choice(choice_index)

func end_talking():
	if dialogue_system:
		dialogue_system.end_dialogue()
		dialogue_system = null
	
	# Emit end talking signal
	EventBus.emit_event(EventBus.EventType.NPC_INTERACTION, {
		"npc_name": npc.npc_name,
		"region": npc.cultural_region,
		"action": "end_talking"
	}, 1, "npc_system")

func exit():
	GameLogger.debug(npc.npc_name + " exited talking state")
	end_talking()

func get_state_name() -> String:
	return "TalkingState"
