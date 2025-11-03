class_name NPCDialogueSystem
extends RefCounted

# Dialogue system for NPCs
# Implements Single Responsibility Principle - handles only dialogue functionality

var npc: CulturalNPC
var current_dialogue_index: int = 0
var dialogue_data: Array[Dictionary] = []
var is_dialogue_active: bool = false
var current_message: String = ""
var current_options: Array = []  # Changed from Array[Dictionary] to Array to avoid type mismatch
var message_display_timer: float = 0.0
var message_display_duration: float = 3.0

func _init(npc_reference: CulturalNPC):
	npc = npc_reference
	dialogue_data = npc.dialogue_data

func start_dialogue():
	is_dialogue_active = true
	current_dialogue_index = 0
	message_display_timer = 0.0
	
	# Emit dialogue start signal
	EventBus.emit_event(EventBus.EventType.NPC_INTERACTION, {
		"npc_name": npc.npc_name,
		"dialogue_id": "start",
		"action": "dialogue_start"
	}, 2, "dialogue_system")
	
	show_current_dialogue()

func update(delta: float):
	if not is_dialogue_active:
		return
	
	message_display_timer += delta
	
	# Auto-advance dialogue after a certain time
	if message_display_timer >= message_display_duration:
		advance_dialogue()

func show_current_dialogue():
	if current_dialogue_index >= dialogue_data.size():
		# No more dialogue, show default
		show_default_dialogue()
		return
	
	var dialogue = dialogue_data[current_dialogue_index]
	current_message = dialogue.get("message", "")
	current_options = dialogue.get("options", [])
	
	# Emit dialogue update signal
	EventBus.emit_event(EventBus.EventType.UI_UPDATE, {
		"update_type": "dialogue_update",
		"npc_name": npc.npc_name,
		"message": current_message,
		"options": current_options
	}, 3, "dialogue_system")
	
	GameLogger.info(npc.npc_name + ": " + current_message)
	
	# Show options if available
	if current_options.size() > 0:
		for i in range(current_options.size()):
			GameLogger.info(str(i + 1) + ". " + current_options[i].get("text", ""))

func show_default_dialogue():
	var message = get_default_message()
	current_message = message
	current_options = []
	
	# Emit default dialogue signal
	EventBus.emit_event(EventBus.EventType.UI_UPDATE, {
		"update_type": "dialogue_default",
		"npc_name": npc.npc_name,
		"message": message
	}, 3, "dialogue_system")
	
	GameLogger.info(npc.npc_name + ": " + message)

func get_default_message() -> String:
	match npc.npc_type:
		"Guide":
			return "Welcome to " + npc.cultural_region + "! I can guide you through the cultural highlights."
		"Vendor":
			return "Welcome! I sell traditional items from " + npc.cultural_region + "."
		"Historian":
			return "Greetings! I can tell you about the history of " + npc.cultural_region + "."
		_:
			return "Hello! Welcome to " + npc.cultural_region + "."

func advance_dialogue():
	current_dialogue_index += 1
	message_display_timer = 0.0
	
	if current_dialogue_index >= dialogue_data.size():
		# End dialogue
		end_dialogue()
	else:
		show_current_dialogue()

func continue_dialogue():
	advance_dialogue()

func select_choice(choice_index: int):
	if choice_index >= 0 and choice_index < current_options.size():
		var selected_option = current_options[choice_index]
		var next_dialogue_id = selected_option.get("next_dialogue", "")
		
		# Handle choice consequences
		handle_choice_consequence(selected_option)
		
		# Move to next dialogue or end
		if next_dialogue_id != "":
			# Find dialogue with matching ID
			for i in range(dialogue_data.size()):
				if dialogue_data[i].get("id", "") == next_dialogue_id:
					current_dialogue_index = i
					show_current_dialogue()
					return
		
		# If no next dialogue specified, advance normally
		advance_dialogue()

func handle_choice_consequence(option: Dictionary):
	var consequence = option.get("consequence", "")
	
	match consequence:
		"share_knowledge":
			npc.share_cultural_knowledge()
		"give_item":
			# Handle giving item to player
			var item_name = option.get("item_name", "")
			if item_name != "":
				give_item_to_player(item_name)
		"end_conversation":
			end_dialogue()

func give_item_to_player(item_name: String):
	# Create item using factory
	var item_config = {
		"type": "artifact",
		"display_name": item_name,
		"description": "A gift from " + npc.npc_name,
		"region": npc.cultural_region
	}
	
	var item = CulturalItemFactory.create_item_from_config(item_config)
	if item:
		# Emit item given signal
		EventBus.emit_event(EventBus.EventType.ARTIFACT_COLLECTED, {
			"artifact_name": item_name,
			"region": npc.cultural_region,
			"source": "npc_gift",
			"npc_name": npc.npc_name
		}, 2, "dialogue_system")

func end_dialogue():
	is_dialogue_active = false
	
	# Mark dialogue as ended in the NPC
	npc.mark_dialogue_ended()
	
	# Emit dialogue end signal
	EventBus.emit_event(EventBus.EventType.NPC_INTERACTION, {
		"npc_name": npc.npc_name,
		"action": "dialogue_end"
	}, 2, "dialogue_system")
	
	GameLogger.info("Dialogue with " + npc.npc_name + " ended")

func is_active() -> bool:
	return is_dialogue_active
