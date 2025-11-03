class_name NPCDialogueUI
extends BaseUIComponent

@onready var dialogue_panel: Panel = $DialoguePanel
@onready var npc_label: Label = $DialoguePanel/VBoxContainer/NPCLabel
@onready var dialogue_label: Label = $DialoguePanel/VBoxContainer/DialogueLabel
@onready var options_container: VBoxContainer = $DialoguePanel/VBoxContainer/OptionsContainer
@onready var close_button: Button = $DialoguePanel/VBoxContainer/CloseButton

var current_npc: CulturalNPC
var current_dialogue: Dictionary
var dialogue_options: Array = []  # Changed from Array[Dictionary] to Array to avoid type mismatch
var current_dialogue_id: String = ""

func _on_component_ready():
	# Hide dialogue panel initially
	dialogue_panel.visible = false
	
	# Connect signals
	close_button.pressed.connect(_on_close_button_pressed)
	GlobalSignals.on_npc_interaction.connect(_on_npc_interaction)
	
	# Connect to EventBus (autoload singleton)
	if EventBus:
		EventBus.subscribe(self, _on_event_bus_npc_interaction, [EventBus.EventType.NPC_INTERACTION])
	
	# Set mouse filter to ignore when hidden
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_component_input(event):
	# Only process input when the dialogue UI is visible
	if not visible or not dialogue_panel.visible:
		return
		
	if has_node("/root/DebugConfig") and get_node("/root/DebugConfig").enable_input_debug:
		GameLogger.debug("DialogueUI input received")

	var handled := false
	# Handle dialogue choice keys
	if event.is_action_pressed("dialogue_choice_1") and dialogue_options.size() > 0:
		select_dialogue_option(0)
		handled = true
	elif event.is_action_pressed("dialogue_choice_2") and dialogue_options.size() > 1:
		select_dialogue_option(1)
		handled = true
	elif event.is_action_pressed("dialogue_choice_3") and dialogue_options.size() > 2:
		select_dialogue_option(2)
		handled = true
	elif event.is_action_pressed("dialogue_choice_4") and dialogue_options.size() > 3:
		select_dialogue_option(3)
		handled = true
	elif event.is_action_pressed("dialogue_continue"):
		advance_dialogue()
		handled = true
	elif event.is_action_pressed("dialogue_cancel"):
		hide_dialogue()
		handled = true

	if handled:
		# Consume only when we actually handled a dialogue action
		safe_set_input_as_handled()

func select_dialogue_option(option_index: int):
	if option_index >= 0 and option_index < dialogue_options.size():
		var option = dialogue_options[option_index]
		_on_option_selected(option)

func advance_dialogue():
	# Advance to next dialogue or end conversation
	if current_npc and current_npc.dialogue_system:
		current_npc.dialogue_system.advance_dialogue()
	else:
		hide_dialogue()

func _on_npc_interaction(_npc_name: String, _region: String):
	# DISABLED: Old dialogue system is replaced by new visual dialogue system
	# Find the NPC in the scene
	# var npc = find_npc_by_name(npc_name)
	# if npc:
	# 	start_dialogue_with_npc(npc)
	pass

func _on_event_bus_npc_interaction(_event: EventBus.Event):
	# DISABLED: Old dialogue system is replaced by new visual dialogue system
	# Handle EventBus NPC interaction events
	# var npc_name = event.data.get("npc_name", "")
	# var npc = find_npc_by_name(npc_name)
	# if npc:
	# 	start_dialogue_with_npc(npc)
	pass

func find_npc_by_name(npc_name: String) -> CulturalNPC:
	# Search for NPC in the scene tree
	var scene_tree = get_tree()
	if scene_tree and scene_tree.current_scene:
		return _find_npc_in_tree(scene_tree.current_scene, npc_name)
	return null

func _find_npc_in_tree(node: Node, npc_name: String) -> CulturalNPC:
	if not node:
		return null
	
	# Check if this node is the NPC we're looking for
	if node is CulturalNPC and node.npc_name == npc_name:
		return node
	
	# Search children
	for child in node.get_children():
		var result = _find_npc_in_tree(child, npc_name)
		if result:
			return result
	
	return null

func start_dialogue_with_npc(npc: CulturalNPC):
	GameLogger.debug("Starting dialogue with NPC: " + npc.npc_name + ", current_npc=" + str(current_npc))
	
	# Don't start new dialogue if we already have one active
	if current_npc != null:
		GameLogger.debug("Dialogue already active, ignoring new start request")
		return
		
	current_npc = npc
	current_dialogue_id = "greeting"  # Start with greeting
	
	# Show dialogue panel
	show_dialogue_panel()
	
	# Load and display initial dialogue
	load_and_display_dialogue()

func show_dialogue_panel():
	dialogue_panel.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Set NPC name
	if current_npc:
		npc_label.text = current_npc.npc_name
	
	# Add keyboard controls indicator
	add_keyboard_controls_indicator()

func add_keyboard_controls_indicator():
	# Create or update keyboard controls label
	var controls_label = dialogue_panel.get_node_or_null("KeyboardControls")
	if not controls_label:
		controls_label = Label.new()
		controls_label.name = "KeyboardControls"
		controls_label.text = "Controls: [1-4] Choose option, [Enter] Continue, [Esc] Cancel"
		controls_label.add_theme_color_override("font_color", Color.YELLOW)
		controls_label.add_theme_font_size_override("font_size", 12)
		dialogue_panel.add_child(controls_label)
	
	# Position the controls label at the bottom
	controls_label.position = Vector2(10, dialogue_panel.size.y - 30)

func load_and_display_dialogue():
	if not current_npc:
		return
	
	# Get dialogue by ID
	var dialogue = current_npc.get_dialogue_by_id(current_dialogue_id)
	if dialogue.is_empty():
		# Fallback to initial dialogue
		dialogue = current_npc.get_initial_dialogue()
	
	# Display dialogue
	display_dialogue(dialogue)

func display_dialogue(dialogue: Dictionary):
	if dialogue.is_empty():
		hide_dialogue()
		return
	
	# Set dialogue text
	dialogue_label.text = dialogue.get("message", "")
	
	# Clear existing options
	clear_options()
	
	# Store dialogue options for keyboard access
	dialogue_options = dialogue.get("options", [])
	
	# Add dialogue options with keyboard indicators
	for i in range(dialogue_options.size()):
		var option = dialogue_options[i]
		add_dialogue_option(option, i + 1)  # Pass option number (1, 2, 3, 4)

func clear_options():
	# Remove all option buttons except the close button
	for child in options_container.get_children():
		if child != close_button:
			child.queue_free()
	
	# Clear stored options
	dialogue_options = []

func add_dialogue_option(option: Dictionary, option_number: int = 0):
	var button = Button.new()
	
	# Add keyboard indicator to button text
	var option_text = option.get("text", "")
	if option_number > 0:
		button.text = "[%d] %s" % [option_number, option_text]
	else:
		button.text = option_text
	
	button.custom_minimum_size = Vector2(200, 40)
	
	# Connect button press
	button.pressed.connect(_on_option_selected.bind(option))
	
	options_container.add_child(button)

func _on_option_selected(option: Dictionary):
	var consequence = option.get("consequence", "")
	var next_dialogue = option.get("next_dialogue", "")
	
	GameLogger.debug("Option selected: " + str(option.get("text", "")) + ", consequence=" + consequence + ", next_dialogue=" + next_dialogue)
	
	# Handle consequence
	match consequence:
		"share_knowledge":
			if current_npc:
				current_npc.share_cultural_knowledge()
		"end_conversation":
			GameLogger.debug("Ending conversation - hiding dialogue")
			hide_dialogue()
			# Mark dialogue as ended in the NPC to prevent reappearing
			if current_npc:
				current_npc.mark_dialogue_ended()
			return
	
	# Handle next dialogue
	if next_dialogue != "":
		GameLogger.debug("Loading next dialogue: " + next_dialogue)
		current_dialogue_id = next_dialogue
		load_and_display_dialogue()
	else:
		GameLogger.debug("No next dialogue - hiding dialogue")
		hide_dialogue()
		# Mark dialogue as ended in the NPC to prevent reappearing
		if current_npc:
			current_npc.mark_dialogue_ended()

func hide_dialogue():
	GameLogger.debug("Hiding dialogue - panel visible was: " + str(dialogue_panel.visible))
	dialogue_panel.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Reset state
	current_npc = null
	current_dialogue_id = ""
	current_dialogue = {}
	GameLogger.debug("Dialogue hidden - panel visible now: " + str(dialogue_panel.visible))

func _on_close_button_pressed():
	hide_dialogue()
	# Mark dialogue as ended in the NPC to prevent reappearing
	if current_npc:
		current_npc.mark_dialogue_ended()

# Legacy methods for backward compatibility
func show_dialogue(npc_name: String, dialogue_id: String):
	# Find NPC and start dialogue
	var npc = find_npc_by_name(npc_name)
	if npc:
		current_npc = npc
		current_dialogue_id = dialogue_id
		show_dialogue_panel()
		load_and_display_dialogue()

func load_dialogue_data(_npc_name: String, _dialogue_id: String):
	# This is now handled by the NPC's dialogue system
	pass

func get_npc_region(npc_name: String) -> String:
	# Determine region based on NPC name
	match npc_name:
		"MarketGuide":
			return "Indonesia Barat"
		"Historian":
			return "Indonesia Tengah"
		"CulturalGuide":
			return "Indonesia Timur"
		_:
			return "Unknown"

func get_dialogue_message(npc_name: String, region: String) -> String:
	var messages = {
		"MarketGuide": {
			"Indonesia Barat": "Welcome to the traditional market! Here you can find authentic Indonesian street food and cultural artifacts. The market has been a center of trade and culture for generations."
		},
		"Historian": {
			"Indonesia Tengah": "Greetings! I am a historian specializing in the Mount Tambora eruption of 1815. This was one of the most significant volcanic events in human history, affecting global climate for years."
		},
		"CulturalGuide": {
			"Indonesia Timur": "Welcome to Papua! I can guide you through the rich cultural heritage of this region. We have ancient artifacts and traditional customs that have been preserved for centuries."
		}
	}
	
	return messages.get(npc_name, {}).get(region, "Hello! Welcome to " + region + ".")

func get_dialogue_options(npc_name: String, _region: String) -> Array[Dictionary]:
	var options = []
	
	match npc_name:
		"MarketGuide":
			options = [
				{"text": "Tell me about the market history", "action": "market_history"},
				{"text": "What food should I try?", "action": "food_recommendations"},
				{"text": "Show me cultural artifacts", "action": "show_artifacts"}
			]
		"Historian":
			options = [
				{"text": "Tell me about the 1815 eruption", "action": "eruption_details"},
				{"text": "What was the global impact?", "action": "global_impact"},
				{"text": "Show me historical documents", "action": "show_documents"}
			]
		"CulturalGuide":
			options = [
				{"text": "Tell me about the ancient artifacts", "action": "ancient_artifacts"},
				{"text": "What are the traditional customs?", "action": "traditional_customs"},
				{"text": "Show me cultural items", "action": "show_items"}
			]
	
	return options

func _on_component_cleanup():
	# Hide dialogue to prevent any UI updates
	if dialogue_panel:
		dialogue_panel.visible = false
	
	# Reset state
	current_npc = null
	current_dialogue_id = ""
	current_dialogue = {}
	
	GameLogger.debug("NPCDialogueUI: Component cleanup complete")
