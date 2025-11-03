class_name CulturalNPC
extends CulturalInteractableObject

@export var npc_name: String
@export var cultural_region: String
@export var npc_type: String = "Guide"  # Guide, Vendor, Historian
@export var dialogue_data: Array[Dictionary] = []
@export var interaction_range: float = 3.0
@export var npc_model: PackedScene

# NPC behavior using State Pattern
var state_machine: NPCStateMachine
var player_distance: float = 0.0
var player: CharacterBody3D

# Dialogue state tracking
var dialogue_just_ended: bool = false
var dialogue_end_time: float = 0.0
var dialogue_cooldown_duration: float = 3.0  # Seconds to wait before allowing new dialogue
var dialogue_history: Array = []  # Track dialogue history for navigation

# Cultural knowledge
var cultural_topics: Array[String] = []
var current_topic: String = ""



# Safe input handling for NPC
func safe_set_input_as_handled():
	# Simple wrapper for set_input_as_handled()
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()
		return true
	return false

func _ready():
	setup_npc()
	connect_signals()
	find_player()
	
	# Initialize state machine
	state_machine = NPCStateMachine.new(self)
	
	# Initialize dialogue data if empty
	if dialogue_data.is_empty():
		setup_default_dialogue()
	
	if has_node("/root/DebugConfig") and not get_node("/root/DebugConfig").enable_npc_debug:
		return
	GameLogger.debug("NPC Ready: " + name)
	GameLogger.info("CulturalNPC initialized: " + npc_name + " (Type: " + npc_type + ")")

func find_player():
	# Find the player in the scene tree
	var scene_tree = get_tree()
	if scene_tree:
		# Look for the player node by group first
		var player_node = scene_tree.get_first_node_in_group("player")
		if player_node and player_node is CharacterBody3D:
			player = player_node
			GameLogger.info("NPC " + npc_name + " found player: " + player.name)
		else:
			# Try to find by searching through the scene tree
			player_node = _find_player_in_tree(scene_tree.current_scene)
			
			if player_node and player_node is CharacterBody3D:
				player = player_node
				GameLogger.info("NPC " + npc_name + " found player by search: " + player.name)
			else:
				GameLogger.warning("NPC " + npc_name + " could not find player")

# Helper function to recursively search for player
func _find_player_in_tree(node: Node) -> Node:
	if not node:
		return null
	
	# Check if this node is the player (CharacterBody3D in player group)
	if node is CharacterBody3D and node.is_in_group("player"):
		return node
	
	# Search children
	for child in node.get_children():
		var result = _find_player_in_tree(child)
		if result:
			return result
	
	return null

func setup_npc():
	# Add to NPC group for InteractionController to find
	add_to_group("npc")
	
	# Set up interaction prompt
	interaction_prompt = "Talk to " + npc_name
	
	# Set interaction range (3 meters by default)
	interaction_range = 3.0
	
	# Load NPC model if provided
	if npc_model:
		var model_instance = npc_model.instantiate()
		add_child(model_instance)
	
	# Set up cultural topics based on region and type
	setup_cultural_topics()
	
	# Add interaction area for better detection
	setup_interaction_area()
	
	GameLogger.debug("NPC " + npc_name + " setup complete - Interaction range: " + str(interaction_range))

func setup_interaction_area():
	# Create an Area3D for better interaction detection
	var interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = interaction_range
	collision_shape.shape = sphere_shape
	interaction_area.add_child(collision_shape)
	
	# Set collision layers to detect player (layer 1)
	interaction_area.collision_layer = 0  # Don't collide with anything
	interaction_area.collision_mask = 1   # Detect objects on layer 1 (player)
	
	# Add to NPC
	add_child(interaction_area)
	
	# Connect signals for better interaction detection
	interaction_area.body_entered.connect(_on_player_entered_area)
	interaction_area.body_exited.connect(_on_player_exited_area)
	
	GameLogger.debug("NPC " + npc_name + " interaction area set up with radius: " + str(interaction_range))

func _on_player_entered_area(body: Node3D):
	if body is CharacterBody3D and body.is_in_group("player"):
		GameLogger.info("Player entered interaction range of " + npc_name)
		# Visual feedback - could add a glow effect here
		show_interaction_available()

func _on_player_exited_area(body: Node3D):
	if body is CharacterBody3D and body.is_in_group("player"):
		GameLogger.info("Player exited interaction range of " + npc_name)
		# Hide visual feedback
		hide_interaction_available()

func show_interaction_available():
	# Add visual feedback when player is in range
	if has_node("NPCModel"):
		var model = get_node("NPCModel")
		if model:
			# Check if the model supports modulate property
			if model.has_method("set_modulate") or model.has_signal("modulate_changed"):
				# Add a subtle glow effect
				model.modulate = Color(1.2, 1.2, 1.0)  # Slight yellow tint
			else:
				# For nodes that don't support modulate, create a visual indicator
				_create_interaction_indicator()

func hide_interaction_available():
	# Remove visual feedback when player leaves range
	if has_node("NPCModel"):
		var model = get_node("NPCModel")
		if model:
			# Check if the model supports modulate property
			if model.has_method("set_modulate") or model.has_signal("modulate_changed"):
				model.modulate = Color.WHITE
			else:
				# Remove visual indicator
				_remove_interaction_indicator()

func _create_interaction_indicator():
	# Create a visual indicator for interaction availability
	var indicator = get_node_or_null("InteractionIndicator")
	if not indicator:
		# Wait until we're in the scene tree before creating the indicator
		if not is_inside_tree():
			# Schedule creation for next frame when we're in the tree
			call_deferred("_create_interaction_indicator")
			return
		
		indicator = CSGSphere3D.new()
		indicator.name = "InteractionIndicator"
		indicator.radius = 0.3
		
		# Use position instead of global_position to avoid timing issues
		indicator.position = Vector3(0, 2, 0)  # Above the NPC
		
		# Create material for the indicator
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.YELLOW
		material.emission_enabled = true
		material.emission = Color.YELLOW
		material.emission_energy = 0.5
		indicator.material = material
		
		add_child(indicator)
		GameLogger.debug("Created interaction indicator for " + npc_name)

func _remove_interaction_indicator():
	# Remove the visual indicator
	var indicator = get_node_or_null("InteractionIndicator")
	if indicator:
		indicator.queue_free()
		GameLogger.debug("Removed interaction indicator for " + npc_name)

func connect_signals():
	# Connect to both GlobalSignals and EventBus for compatibility
	GlobalSignals.on_npc_interaction.connect(_on_npc_interaction)
	
	# Connect to EventBus (autoload singleton)
	if EventBus:
		EventBus.subscribe(self, _on_event_bus_npc_interaction, [EventBus.EventType.NPC_INTERACTION])

func _process(delta):
	if player:
		player_distance = position.distance_to(player.position)
	
	# Update state machine
	if state_machine:
		state_machine.update(delta)

func _interact():
	# Trust the InteractionController's RayCast detection (like PedestalInteraction.gd)
	# The InteractionController only calls _interact() when player is in range
	if not can_interact:
		GameLogger.debug("Interaction blocked - can_interact is false for " + npc_name)
		return
	
	# Check if dialogue just ended and we're still in cooldown
	if dialogue_just_ended:
		var current_time = Time.get_unix_time_from_system()
		if current_time - dialogue_end_time < dialogue_cooldown_duration:
			GameLogger.debug("Interaction blocked - dialogue cooldown active for " + npc_name + " (time remaining: " + str(dialogue_cooldown_duration - (current_time - dialogue_end_time)) + "s)")
			return
		else:
			dialogue_just_ended = false
			# Reset can_interact to allow new interaction after cooldown
			can_interact = true
			GameLogger.debug("Dialogue cooldown expired, allowing interaction for " + npc_name)
		
	GameLogger.info("Starting interaction with " + npc_name)
	
	# Visual feedback for interaction
	show_interaction_feedback()
	
	# Change to interacting state
	if state_machine:
		state_machine.change_state(state_machine.get_interacting_state())
	
	# Emit interaction event
	emit_interaction_event()
	
	# Start dialogue with visual UI
	start_visual_dialogue()
	
	# Disable interaction temporarily to prevent spam during active dialogue
	can_interact = false
	GameLogger.debug("Interaction disabled during dialogue for " + npc_name)

func start_visual_dialogue():
	# Get initial dialogue
	var initial_dialogue = get_initial_dialogue()
	if initial_dialogue.is_empty():
		GameLogger.warning("No dialogue data found for " + npc_name)
		return
	
	# Display dialogue UI
	display_dialogue_ui(initial_dialogue)
	
	# Set up input handling for dialogue choices
	call_deferred("_setup_dialogue_input_handling")

func display_dialogue_ui(dialogue: Dictionary):
	# Add to dialogue history
	dialogue_history.append(dialogue)
	
	# Create a beautiful vintage-style dialogue UI
	var dialogue_ui = get_node_or_null("DialogueUI")
	if not dialogue_ui:
		dialogue_ui = Control.new()
		dialogue_ui.name = "DialogueUI"
		dialogue_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dialogue_ui.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(dialogue_ui)
		
		# Create background with vintage texture
		var background = ColorRect.new()
		background.color = Color(0.05, 0.05, 0.08, 0.9)
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dialogue_ui.add_child(background)
		
		# Create main dialogue panel with vintage styling
		var dialogue_panel = Panel.new()
		dialogue_panel.name = "DialoguePanel"
		dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		dialogue_panel.offset_left = -500
		dialogue_panel.offset_top = -300
		dialogue_panel.offset_right = 500
		dialogue_panel.offset_bottom = 300
		
		# Create vintage panel style with Bezier curves
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color(0.1, 0.15, 0.25, 0.95)  # Dark blue vintage color
		panel_style.border_color = Color(0.8, 0.75, 0.6, 1.0)  # Vintage cream border
		panel_style.border_width_left = 3
		panel_style.border_width_top = 3
		panel_style.border_width_right = 3
		panel_style.border_width_bottom = 3
		panel_style.corner_radius_top_left = 15
		panel_style.corner_radius_top_right = 15
		panel_style.corner_radius_bottom_left = 15
		panel_style.corner_radius_bottom_right = 15
		panel_style.shadow_color = Color(0, 0, 0, 0.3)
		panel_style.shadow_size = 8
		panel_style.shadow_offset = Vector2(4, 4)
		dialogue_panel.add_theme_stylebox_override("panel", panel_style)
		
		dialogue_ui.add_child(dialogue_panel)
		
		# Create vintage header with icon and title
		var header_container = HBoxContainer.new()
		header_container.name = "HeaderContainer"
		header_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		header_container.offset_left = 20
		header_container.offset_top = 15
		header_container.offset_right = -20
		header_container.offset_bottom = 70
		header_container.add_theme_constant_override("separation", 15)
		dialogue_panel.add_child(header_container)
		
		# Create chat bubble icon using 2D primitives
		var chat_icon = Control.new()
		chat_icon.name = "ChatIcon"
		chat_icon.custom_minimum_size = Vector2(40, 40)
		chat_icon.draw.connect(_draw_chat_icon.bind(chat_icon))
		header_container.add_child(chat_icon)
		
		# Create title label with vintage styling
		var title_label = Label.new()
		title_label.name = "TitleLabel"
		title_label.text = "DIALOG\nHISTORY"
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 18)
		title_label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6, 1.0))
		title_label.add_theme_constant_override("line_spacing", 2)
		header_container.add_child(title_label)
		
		# Add spacer to push next icon to right
		var header_spacer = Control.new()
		header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_container.add_child(header_spacer)
		
		# Create next arrow icon
		var next_icon = Control.new()
		next_icon.name = "NextIcon"
		next_icon.custom_minimum_size = Vector2(30, 30)
		next_icon.draw.connect(_draw_next_icon.bind(next_icon))
		header_container.add_child(next_icon)
		
		# Create message area with vintage styling
		var message_container = VBoxContainer.new()
		message_container.name = "MessageContainer"
		message_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		message_container.offset_left = 30
		message_container.offset_top = 90
		message_container.offset_right = -30
		message_container.offset_bottom = -80
		message_container.add_theme_constant_override("separation", 15)
		dialogue_panel.add_child(message_container)
		
		# Create NPC name label with vintage styling
		var npc_name_label = Label.new()
		npc_name_label.name = "NPCNameLabel"
		npc_name_label.text = npc_name
		npc_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		npc_name_label.add_theme_font_size_override("font_size", 24)
		npc_name_label.add_theme_color_override("font_color", Color(1, 0.8, 0.4, 1.0))  # Golden color
		message_container.add_child(npc_name_label)
		
		# Create message text with vintage styling
		var message_text = RichTextLabel.new()
		message_text.name = "MessageText"
		message_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
		message_text.bbcode_enabled = true
		message_text.fit_content = true
		message_text.add_theme_font_size_override("normal_font_size", 20)
		message_text.add_theme_color_override("default_color", Color(0.9, 0.85, 0.7, 1.0))  # Vintage cream text
		message_text.add_theme_constant_override("line_spacing", 4)
		message_container.add_child(message_text)
		
		# Create options container with vintage styling
		var options_container = VBoxContainer.new()
		options_container.name = "OptionsContainer"
		options_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		options_container.offset_left = 30
		options_container.offset_top = -150
		options_container.offset_right = -30
		options_container.offset_bottom = -60
		options_container.add_theme_constant_override("separation", 8)
		dialogue_panel.add_child(options_container)
		
		# Create navigation buttons with vintage styling
		var nav_container = HBoxContainer.new()
		nav_container.name = "NavigationContainer"
		nav_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
		nav_container.offset_left = 20
		nav_container.offset_top = -50
		nav_container.offset_right = 180
		nav_container.offset_bottom = -20
		nav_container.add_theme_constant_override("separation", 10)
		dialogue_panel.add_child(nav_container)
		
		# Create back button with vintage styling
		var back_button = Button.new()
		back_button.name = "BackButton"
		back_button.text = "← Back (←)"
		back_button.custom_minimum_size = Vector2(100, 30)
		back_button.pressed.connect(_on_back_button_pressed)
		nav_container.add_child(back_button)
		
		# Create close button with vintage styling
		var close_button = Button.new()
		close_button.name = "CloseButton"
		close_button.text = "Close (→/C)"
		close_button.custom_minimum_size = Vector2(100, 30)
		close_button.pressed.connect(_on_close_button_pressed)
		nav_container.add_child(close_button)
		
		# Style the buttons with vintage appearance
		_style_vintage_button(back_button)
		_style_vintage_button(close_button)
		
		# Create keyboard controls indicator
		var controls_label = Label.new()
		controls_label.name = "ControlsLabel"
		controls_label.text = "Controls: [1-3] Choose option, [←] Back, [→/C] Close, [X] Exit Dialog, [Space] Skip animation"
		controls_label.add_theme_font_size_override("font_size", 12)
		controls_label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6, 0.8))
		controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		controls_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		controls_label.offset_left = 20
		controls_label.offset_top = -30
		controls_label.offset_right = -20
		controls_label.offset_bottom = -10
		dialogue_panel.add_child(controls_label)
	
	# Update dialogue content
	var message_text_node = dialogue_ui.get_node("DialoguePanel/MessageContainer/MessageText")
	var options_container_node = dialogue_ui.get_node("DialoguePanel/OptionsContainer")
	
	if message_text_node:
		var text_content = dialogue.get("message", "Hello! How can I help you?")
		GameLogger.debug("Displaying dialog text: " + text_content)
		# Use typewriter animation to prevent accidental fast clicking
		start_typewriter_animation(message_text_node, "[i]" + text_content + "[/i]")
	else:
		GameLogger.warning("MessageText node not found in dialog UI")
	
	# Clear and add options with vintage styling
	if options_container_node:
		# Clear existing options
		for child in options_container_node.get_children():
			child.queue_free()
		
		var options = dialogue.get("options", [])
		
		# Add numbered options with vintage styling
		for i in range(options.size()):
			var option = options[i]
			var option_button = Button.new()
			option_button.text = str(i + 1) + ". " + option.get("text", "Option " + str(i + 1))
			option_button.custom_minimum_size = Vector2(0, 35)
			option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			# Style with vintage appearance
			_style_vintage_button(option_button)
			
			# Connect button press
			option_button.pressed.connect(_handle_dialogue_choice.bind(i))
			
			options_container_node.add_child(option_button)
	
	dialogue_ui.visible = true
	GameLogger.info("=== DIALOGUE STARTED ===")
	GameLogger.info("NPC: " + dialogue.get("message", "Hello!"))

func _setup_dialogue_input_handling():
	# CRITICAL: Check if we're still valid before creating timer
	if not is_inside_tree() or not is_instance_valid(self):
		GameLogger.warning("CulturalNPC: Cannot setup input handling - node not in tree or invalid")
		return
	
	# Enhanced debug logging for input handling setup
	if has_node("/root/DebugConfig") and get_node("/root/DebugConfig").enable_npc_input_debug:
		GameLogger.debug("CulturalNPC: Setting up input handling for " + npc_name + " - is_inside_tree: " + str(is_inside_tree()) + ", is_instance_valid: " + str(is_instance_valid(self)))
	
	# Clean up any existing timer first
	var existing_timer = get_node_or_null("DialogueInputTimer")
	if existing_timer:
		existing_timer.stop()
		existing_timer.queue_free()
		GameLogger.debug("CulturalNPC: Cleaned up existing input timer")
	
	# Create a timer to check for input during dialogue
	var input_timer = Timer.new()
	input_timer.name = "DialogueInputTimer"
	input_timer.wait_time = 0.1  # Check every 0.1 seconds
	
	# Connect with a lambda that includes safety checks
	input_timer.timeout.connect(func():
		# CRITICAL: Check if we're still valid before processing
		if not is_instance_valid(self) or not is_inside_tree():
			GameLogger.warning("CulturalNPC: Timer fired but node no longer valid or scene being destroyed, cleaning up")
			if is_instance_valid(input_timer):
				input_timer.stop()
				input_timer.queue_free()
			return
		
		# Enhanced debug logging for timer execution
		if has_node("/root/DebugConfig") and get_node("/root/DebugConfig").enable_timer_debug:
			GameLogger.debug("CulturalNPC: Input timer fired for " + npc_name + " - is_inside_tree: " + str(is_inside_tree()) + ", is_instance_valid: " + str(is_instance_valid(self)))
		
		# Call the actual input check function
		_check_dialogue_input()
	)
	
	add_child(input_timer)
	input_timer.start()
	GameLogger.debug("CulturalNPC: Created new input timer with safety checks")

func _check_dialogue_input():
	# Enhanced debug logging for input check
	if has_node("/root/DebugConfig") and get_node("/root/DebugConfig").enable_tree_debug:
		GameLogger.debug("CulturalNPC: Input check for " + npc_name + " - is_inside_tree: " + str(is_inside_tree()) + ", is_instance_valid: " + str(is_instance_valid(self)))
	
	# CRITICAL: Check if we're still in the tree before ANY processing
	if not is_inside_tree() or not is_instance_valid(self):
		GameLogger.warning("CulturalNPC: Node not in tree, invalid, or scene being destroyed during input check, cleaning up")
		var input_timer = get_node_or_null("DialogueInputTimer")
		if input_timer:
			input_timer.stop()
			input_timer.queue_free()
		return
	
	# Additional safety check - ensure we have a valid viewport
	var viewport = get_viewport()
	if not viewport or not is_instance_valid(viewport):
		GameLogger.warning("CulturalNPC: No valid viewport during input check, cleaning up")
		var input_timer = get_node_or_null("DialogueInputTimer")
		if input_timer:
			input_timer.stop()
			input_timer.queue_free()
		return
	
	# Check if dialogue UI exists and is visible
	var dialogue_ui = get_node_or_null("DialogueUI")
	if not dialogue_ui or not dialogue_ui.visible:
		# Clean up timer if dialogue is not active
		var input_timer = get_node_or_null("DialogueInputTimer")
		if input_timer:
			input_timer.stop()
			input_timer.queue_free()
		return
	
	# Get current dialogue from history (most recent)
	var current_dialogue = dialogue_history.back() if dialogue_history.size() > 0 else get_initial_dialogue()
	var options = current_dialogue.get("options", [])
	
	# Check for number keys 1-N
	for i in range(options.size()):
		if Input.is_action_just_pressed("dialogue_choice_" + str(i + 1)) or Input.is_key_pressed(KEY_1 + i):
			_handle_dialogue_choice(i)
			# Consume the input to prevent it from bubbling up to menu system
			safe_set_input_as_handled()
			return
	
	# Check for X key to close dialogue
	if Input.is_action_just_pressed("dialogue_cancel") or Input.is_key_pressed(KEY_X):
		# Exit dialogue with X
		GameLogger.info("Dialogue cancelled with X key")
		end_visual_dialogue()
		# Consume the input to prevent it from bubbling up to menu system
		safe_set_input_as_handled()
		return
	
	# Check for back button (Left Arrow)
	if Input.is_action_just_pressed("dialogue_back") or Input.is_key_pressed(KEY_LEFT):
		_on_back_button_pressed()
		# Consume the input to prevent it from bubbling up to menu system
		safe_set_input_as_handled()
		return
	
	# Check for close button (Right Arrow or C key)
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_C):
		_on_close_button_pressed()
		# Consume the input to prevent it from bubbling up to menu system
		safe_set_input_as_handled()
		return

func handle_dialogue_option(option: Dictionary):
	"""Handle dialogue option selection (for compatibility with CookingGameNPC)"""
	var action = option.get("action", "")
	var consequence = option.get("consequence", "")
	var next_dialogue_id = option.get("next_dialogue", "")
	
	GameLogger.info("Player selected dialogue option: " + option.get("text", "Unknown"))
	
	# Handle common actions
	if action == "end_dialogue":
		end_visual_dialogue()
		return
	
	# Handle consequence and next dialogue like the original system
	_process_dialogue_consequence(consequence, next_dialogue_id, option)

func _process_dialogue_consequence(consequence: String, next_dialogue_id: String, _option: Dictionary):
	"""Process dialogue consequence and navigation (extracted from _handle_dialogue_choice)"""
	if next_dialogue_id != "":
		# If there's a next dialogue, navigate to it
		var next_dialogue = get_dialogue_by_id(next_dialogue_id)
		if not next_dialogue.is_empty():
			GameLogger.info("Navigating to dialogue: " + next_dialogue_id)
			# Add to dialogue history
			dialogue_history.append(next_dialogue)
			display_dialogue_ui(next_dialogue)
			
			# If there's also a consequence, handle it after navigation
			if consequence == "share_knowledge":
				GameLogger.info("Sharing knowledge after navigation")
				share_cultural_knowledge()
		else:
			GameLogger.warning("Could not find dialogue with id: " + next_dialogue_id)
			# Fall back to consequence handling
			_handle_consequence_only(consequence)
	else:
		# No next dialogue, handle consequence only
		_handle_consequence_only(consequence)

func _handle_consequence_only(consequence: String):
	"""Handle dialogue consequence without navigation"""
	if consequence == "share_knowledge":
		share_cultural_knowledge()
	elif consequence == "end_dialogue":
		end_visual_dialogue()
	# Add other consequence handling as needed

func _handle_dialogue_choice(choice_index: int):
	# Check if we're still in the tree before processing choice
	if not is_inside_tree() or not is_instance_valid(self):
		GameLogger.warning("CulturalNPC: Node not in tree or invalid during dialogue choice, ignoring")
		return
	
	# Get current dialogue from history (most recent)
	var current_dialogue = dialogue_history.back() if dialogue_history.size() > 0 else get_initial_dialogue()
	var options = current_dialogue.get("options", [])
	
	if choice_index >= options.size():
		return
	
	var selected_option = options[choice_index]
	var consequence = selected_option.get("consequence", "")
	var next_dialogue_id = selected_option.get("next_dialogue", "")
	
	GameLogger.info("Player chose: " + selected_option.get("text", "Option " + str(choice_index + 1)))
	
	# Use the extracted dialogue processing function
	_process_dialogue_consequence(consequence, next_dialogue_id, selected_option)

func update_dialogue_text(new_text: String):
	var dialogue_ui = get_node_or_null("DialogueUI")
	if dialogue_ui:
		var message_text = dialogue_ui.get_node_or_null("DialoguePanel/MessageContainer/MessageText")
		if message_text:
			start_typewriter_animation(message_text, "[i]" + new_text + "[/i]")

func start_typewriter_animation(message_text: RichTextLabel, full_text: String):
	# Check if we're still valid before starting animation
	if not is_inside_tree() or not is_instance_valid(self):
		GameLogger.warning("CulturalNPC: Cannot start typewriter animation - node not in tree or invalid")
		return
	
	GameLogger.debug("Starting typewriter animation for text: " + full_text)
	
	# Remove any existing timer first
	var existing_timer = get_node_or_null("TypewriterTimer")
	if existing_timer:
		existing_timer.stop()
		existing_timer.queue_free()
	
	# Clear the text first
	message_text.text = ""
	
	# Create a new timer
	var typewriter_timer = Timer.new()
	typewriter_timer.name = "TypewriterTimer"
	typewriter_timer.wait_time = 0.05  # Slightly slower for better visibility
	add_child(typewriter_timer)
	
	# Store animation state in the timer to avoid variable scope issues
	typewriter_timer.set_meta("current_char_index", 0)
	typewriter_timer.set_meta("is_bbcode_tag", false)
	typewriter_timer.set_meta("bbcode_tag", "")
	typewriter_timer.set_meta("full_text", full_text)
	typewriter_timer.set_meta("message_text", message_text)
	
	# Connect the timer
	typewriter_timer.timeout.connect(func():
		# Get stored values
		var current_char_index = typewriter_timer.get_meta("current_char_index", 0)
		var is_bbcode_tag = typewriter_timer.get_meta("is_bbcode_tag", false)
		var bbcode_tag = typewriter_timer.get_meta("bbcode_tag", "")
		var stored_full_text = typewriter_timer.get_meta("full_text", "")
		var stored_message_text = typewriter_timer.get_meta("message_text", null)
		
		# Check if the message_text is still valid
		if not is_instance_valid(stored_message_text):
			GameLogger.warning("MessageText is no longer valid, stopping animation")
			typewriter_timer.stop()
			typewriter_timer.queue_free()
			return
			
		# Check for skip animation input (Space or Enter)
		if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
			# Skip to end
			GameLogger.debug("Skipping animation to end")
			stored_message_text.text = stored_full_text
			typewriter_timer.stop()
			typewriter_timer.queue_free()
			return
			
		# Process multiple characters per frame for better performance
		var chars_to_process = 2  # Process 2 characters per frame
		for i in range(chars_to_process):
			if current_char_index >= stored_full_text.length():
				# Animation complete
				GameLogger.debug("Animation complete")
				typewriter_timer.stop()
				typewriter_timer.queue_free()
				return
				
			var current_char = stored_full_text[current_char_index]
			
			# Handle BBCode tags
			if current_char == "[":
				is_bbcode_tag = true
				bbcode_tag = "["
			elif current_char == "]" and is_bbcode_tag:
				bbcode_tag += "]"
				stored_message_text.text += bbcode_tag
				is_bbcode_tag = false
				bbcode_tag = ""
			elif is_bbcode_tag:
				bbcode_tag += current_char
			else:
				# Add regular character
				stored_message_text.text += current_char
			
			current_char_index += 1
			GameLogger.debug("Added character: " + current_char + " (index: " + str(current_char_index) + "/" + str(stored_full_text.length()) + ")")
		
		# Update stored values for next iteration
		typewriter_timer.set_meta("current_char_index", current_char_index)
		typewriter_timer.set_meta("is_bbcode_tag", is_bbcode_tag)
		typewriter_timer.set_meta("bbcode_tag", bbcode_tag)
	)
	
	# Start the animation
	GameLogger.debug("Starting typewriter timer")
	typewriter_timer.start()

func end_visual_dialogue():
	# Check if we're still valid before processing
	if not is_instance_valid(self):
		GameLogger.warning("CulturalNPC: Node invalid during end_visual_dialogue, skipping")
		return
	
	# Hide dialogue UI
	var dialogue_ui = get_node_or_null("DialogueUI")
	if dialogue_ui:
		dialogue_ui.visible = false
	
	# Clean up input timer
	var input_timer = get_node_or_null("DialogueInputTimer")
	if input_timer:
		input_timer.stop()
		input_timer.queue_free()
		GameLogger.debug("CulturalNPC: Input timer cleaned up")
	
	# Clean up typewriter timer if it exists
	var typewriter_timer = get_node_or_null("TypewriterTimer")
	if typewriter_timer:
		typewriter_timer.stop()
		typewriter_timer.queue_free()
		GameLogger.debug("CulturalNPC: Typewriter timer cleaned up")
	
	# Mark dialogue as ended
	mark_dialogue_ended()
	
	GameLogger.info("=== DIALOGUE ENDED ===")

func show_interaction_feedback():
	# Visual feedback when interaction starts
	if has_node("NPCModel"):
		var model = get_node("NPCModel")
		if model:
			# Check if the model supports modulate property
			if model.has_method("set_modulate") or model.has_signal("modulate_changed"):
				# Flash green briefly
				var tween = create_tween()
				tween.tween_property(model, "modulate", Color.GREEN, 0.1)
				tween.tween_property(model, "modulate", Color.WHITE, 0.1)
			else:
				# For nodes that don't support modulate, flash the indicator
				_flash_interaction_indicator()

func _flash_interaction_indicator():
	# Flash the interaction indicator briefly
	var indicator = get_node_or_null("InteractionIndicator")
	if indicator:
		var tween = create_tween()
		tween.tween_property(indicator, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
		tween.tween_property(indicator, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
		GameLogger.debug("Flashed interaction indicator for " + npc_name)

func emit_interaction_event():
	# Emit to both systems for compatibility
	GlobalSignals.on_npc_interaction.emit(npc_name, cultural_region)
	
	# Emit to EventBus (autoload singleton)
	if EventBus:
		EventBus.emit_npc_interaction(npc_name, cultural_region)
		GameLogger.info("Emitted NPC interaction event for " + npc_name)
	else:
		GameLogger.error("EventBus not available for " + npc_name)

func setup_default_dialogue():
	# Set up default dialogue based on NPC type and region
	match npc_type:
		"Guide":
			setup_guide_dialogue()
		"Historian":
			setup_historian_dialogue()
		"Vendor":
			setup_vendor_dialogue()
		_:
			setup_generic_dialogue()

func setup_guide_dialogue():
	match cultural_region:
		"Indonesia Barat":
			dialogue_data = [
				{
					"id": "greeting",
					"message": "Selamat datang! Welcome to our traditional market. I can guide you through the rich cultural heritage of Indonesia Barat.",
					"options": [
						{
							"text": "Tell me about the market history",
							"next_dialogue": "market_history",
							"consequence": "share_knowledge"
						},
						{
							"text": "What food should I try?",
							"next_dialogue": "food_recommendations",
							"consequence": "share_knowledge"
						},
						{
							"text": "Goodbye",
							"consequence": "end_conversation"
						}
					]
				},
				{
					"id": "market_history",
					"message": "Traditional markets in Indonesia Barat have been centers of trade and culture for centuries. They represent the heart of community life and preserve our culinary traditions.",
					"options": [
						{
							"text": "Tell me more about the food",
							"next_dialogue": "food_recommendations",
							"consequence": "share_knowledge"
						},
						{
							"text": "Continue exploring",
							"next_dialogue": "greeting"
						},
						{
							"text": "Thank you",
							"consequence": "end_conversation"
						}
					]
				},
				{
					"id": "food_recommendations",
					"message": "You must try Soto, our traditional soup! Also Lotek, a healthy vegetable dish, and Sate for grilled meat. Each has its own unique story and preparation method.",
					"options": [
						{
							"text": "Tell me about market history",
							"next_dialogue": "market_history",
							"consequence": "share_knowledge"
						},
						{
							"text": "Continue exploring",
							"next_dialogue": "greeting"
						},
						{
							"text": "Thank you for the recommendations",
							"consequence": "end_conversation"
						}
					]
				}
			]
		"Indonesia Tengah":
			dialogue_data = [
				{
					"id": "greeting",
					"message": "Welcome to Mount Tambora! I am a historian specializing in the 1815 eruption. This was one of the most significant volcanic events in human history.",
					"options": [
						{
							"text": "Tell me about the 1815 eruption",
							"next_dialogue": "eruption_details",
							"consequence": "share_knowledge"
						},
						{
							"text": "What was the global impact?",
							"next_dialogue": "global_impact",
							"consequence": "share_knowledge"
						},
						{
							"text": "Goodbye",
							"consequence": "end_conversation"
						}
					]
				},
				{
					"id": "eruption_details",
					"message": "The 1815 eruption of Mount Tambora was a VEI-7 event, the most powerful volcanic eruption in recorded history. It ejected over 150 cubic kilometers of material.",
					"options": [
						{
							"text": "What was the global impact?",
							"next_dialogue": "global_impact",
							"consequence": "share_knowledge"
						},
						{
							"text": "Thank you",
							"consequence": "end_conversation"
						}
					]
				},
				{
					"id": "global_impact",
					"message": "The eruption caused the 'Year Without a Summer' in 1816, leading to crop failures, famine, and social unrest worldwide. It affected global climate for years.",
					"options": [
						{
							"text": "Thank you for the history lesson",
							"consequence": "end_conversation"
						}
					]
				}
			]
		"Indonesia Timur":
			dialogue_data = [
				{
					"id": "greeting",
					"message": "Welcome to Papua! I can guide you through the rich cultural heritage of this region. We have ancient artifacts and traditional customs that have been preserved for centuries.",
					"options": [
						{
							"text": "Tell me about the ancient artifacts",
							"next_dialogue": "ancient_artifacts",
							"consequence": "share_knowledge"
						},
						{
							"text": "What are the traditional customs?",
							"next_dialogue": "traditional_customs",
							"consequence": "share_knowledge"
						},
						{
							"text": "Goodbye",
							"consequence": "end_conversation"
						}
					]
				},
				{
					"id": "ancient_artifacts",
					"message": "The megalithic sites in Papua contain ancient artifacts that provide insights into early human settlement. These include stone tools, ceremonial objects, and traditional ornaments.",
					"options": [
						{
							"text": "Tell me about traditional customs",
							"next_dialogue": "traditional_customs",
							"consequence": "share_knowledge"
						},
						{
							"text": "Thank you",
							"consequence": "end_conversation"
						}
					]
				},
				{
					"id": "traditional_customs",
					"message": "Papua's traditional customs include elaborate ceremonies, unique art forms, and distinctive social structures. Each ethnic group has its own unique cultural practices.",
					"options": [
						{
							"text": "Thank you for sharing",
							"consequence": "end_conversation"
						}
					]
				}
			]

func setup_historian_dialogue():
	# Historian-specific dialogue
	setup_guide_dialogue()  # For now, use guide dialogue

func setup_vendor_dialogue():
	# Vendor-specific dialogue
	setup_guide_dialogue()  # For now, use guide dialogue

func setup_generic_dialogue():
	dialogue_data = [
		{
			"id": "greeting",
			"message": "Hello! Welcome to " + cultural_region + ". How can I help you today?",
			"options": [
				{
					"text": "Tell me about this region",
					"consequence": "share_knowledge"
				},
				{
					"text": "Goodbye",
					"consequence": "end_conversation"
				}
			]
		}
	]

func get_dialogue_by_id(dialogue_id: String) -> Dictionary:
	GameLogger.debug("Looking for dialogue with id: " + dialogue_id + " (total dialogues: " + str(dialogue_data.size()) + ")")
	for dialogue in dialogue_data:
		if dialogue.get("id") == dialogue_id:
			GameLogger.debug("Found dialogue: " + dialogue_id)
			return dialogue
	GameLogger.warning("Dialogue not found: " + dialogue_id)
	return {}

func get_initial_dialogue() -> Dictionary:
	if dialogue_data.size() > 0:
		return dialogue_data[0]
	return {}

# Legacy methods for backward compatibility
func start_interaction():
	# This is now handled by the state machine
	if state_machine:
		state_machine.change_state(state_machine.get_interacting_state())

func start_dialogue():
	# This is now handled by the dialogue system
	pass

func show_dialogue_ui(_dialogue: Dictionary):
	# This is now handled by the dialogue system
	pass

func show_default_dialogue():
	# This is now handled by the dialogue system
	pass

func setup_cultural_topics():
	match cultural_region:
		"Indonesia Barat":
			cultural_topics = [
				"Traditional Market Culture",
				"Street Food History", 
				"Sunda and Javanese Traditions"
			]
		"Indonesia Tengah":
			cultural_topics = [
				"Mount Tambora Eruption",
				"Historical Impact",
				"Geological Significance"
			]
		"Indonesia Timur":
			cultural_topics = [
				"Papua Cultural Heritage",
				"Ancient Artifacts",
				"Traditional Customs"
			]

func share_cultural_knowledge():
	if cultural_topics.size() > 0:
		var topic = cultural_topics[randi() % cultural_topics.size()]
		var knowledge = get_knowledge_for_topic(topic)
		
		GlobalSignals.on_learn_cultural_info.emit(knowledge, cultural_region)
		
		# Also emit to EventBus (autoload singleton)
		if EventBus:
			EventBus.emit_cultural_info_learned(knowledge, cultural_region)
		
		GameLogger.info(npc_name + " shares knowledge about: " + topic)

func mark_dialogue_ended():
	dialogue_just_ended = true
	dialogue_end_time = Time.get_unix_time_from_system()
	# Keep can_interact false until cooldown expires or player explicitly presses E again
	can_interact = false
	GameLogger.debug("Dialogue ended for " + npc_name + " - cooldown started, interaction disabled")
	
	# Start a timer to re-enable interaction after cooldown
	var cooldown_timer = get_tree().create_timer(dialogue_cooldown_duration)
	cooldown_timer.timeout.connect(_on_dialogue_cooldown_expired)

func _on_dialogue_cooldown_expired():
	dialogue_just_ended = false
	can_interact = true
	GameLogger.debug("Dialogue cooldown expired for " + npc_name + " - interaction re-enabled")

func get_knowledge_for_topic(topic: String) -> String:
	# This would be loaded from a knowledge database
	var knowledge_data = {
		"Traditional Market Culture": "Traditional markets in Indonesia Barat are vibrant centers of commerce and culture, where local vendors sell everything from fresh produce to traditional crafts.",
		"Street Food History": "Indonesian street food has a rich history dating back centuries, with each region having its own unique culinary traditions.",
		"Sunda and Javanese Traditions": "The Sunda and Javanese people have distinct cultural traditions that have been preserved and passed down through generations.",
		"Mount Tambora Eruption": "The 1815 eruption of Mount Tambora was one of the most powerful volcanic events in recorded history, affecting global climate for years.",
		"Historical Impact": "The Tambora eruption had profound effects on agriculture, leading to the 'Year Without a Summer' in 1816.",
		"Geological Significance": "Mount Tambora's eruption created the largest caldera in Indonesia and changed the landscape dramatically.",
		"Papua Cultural Heritage": "Papua is home to diverse ethnic groups, each with unique cultural practices and traditions.",
		"Ancient Artifacts": "The megalithic sites in Papua contain ancient artifacts that provide insights into early human settlement.",
		"Traditional Customs": "Papua's traditional customs include elaborate ceremonies, unique art forms, and distinctive social structures."
	}
	
	return knowledge_data.get(topic, "Knowledge about " + topic + " is being researched.")

func end_interaction():
	# This is now handled by the state machine
	if state_machine:
		state_machine.change_state(state_machine.get_idle_state())

func _on_npc_interaction(_npc_name_interacted: String, _region: String):
	# This function can be used for additional interaction logic
	if _npc_name_interacted == npc_name:
		GameLogger.info("NPC interaction started with: " + npc_name)

func _on_event_bus_npc_interaction(_event: EventBus.Event):
	# Handle EventBus NPC interaction events
	if _event.data.get("npc_name") == npc_name:
		GameLogger.debug("EventBus NPC interaction with: " + npc_name)

func _on_back_button_pressed():
	# Check if we're still valid before processing
	if not is_inside_tree() or not is_instance_valid(self):
		GameLogger.warning("CulturalNPC: Node not in tree or invalid during back button press, ignoring")
		return
	
	GameLogger.info("Back button pressed - History size: " + str(dialogue_history.size()))
	# Debug: Print all dialogue history
	for i in range(dialogue_history.size()):
		var dialogue = dialogue_history[i]
		GameLogger.debug("History[" + str(i) + "]: " + dialogue.get("id", "unknown"))
	
	# Go back to previous dialogue or close if at beginning
	if dialogue_history.size() > 1:
		dialogue_history.pop_back()  # Remove current
		var previous_dialogue = dialogue_history.back()
		GameLogger.info("Going back to: " + previous_dialogue.get("id", "unknown"))
		display_dialogue_ui(previous_dialogue)
	else:
		GameLogger.info("No more history, closing dialogue")
		end_visual_dialogue()

func _on_close_button_pressed():
	# Check if we're still valid before processing
	if not is_inside_tree() or not is_instance_valid(self):
		GameLogger.warning("CulturalNPC: Node not in tree or invalid during close button press, ignoring")
		return
	
	end_visual_dialogue()

func _draw_chat_icon(control: Control):
	# Draw vintage chat bubble icon using 2D primitives
	var _rect = Rect2(Vector2.ZERO, control.get_size())
	
	# Draw chat bubble body
	control.draw_rect(Rect2(5, 5, 30, 25), Color(0.8, 0.75, 0.6, 1.0), false, 2.0)
	control.draw_rect(Rect2(7, 7, 26, 21), Color(0.1, 0.15, 0.25, 1.0))
	
	# Draw chat bubble tail using Bezier curve
	var points = PackedVector2Array()
	points.append(Vector2(15, 30))
	points.append(Vector2(10, 35))
	points.append(Vector2(8, 32))
	
	# Draw the tail
	for i in range(points.size() - 1):
		control.draw_line(points[i], points[i + 1], Color(0.8, 0.75, 0.6, 1.0), 2.0)

func _draw_next_icon(control: Control):
	# Draw vintage next arrow using 2D primitives
	var center = control.get_size() / 2
	
	# Draw arrow triangle
	var points = PackedVector2Array()
	points.append(Vector2(center.x - 8, center.y - 6))
	points.append(Vector2(center.x + 8, center.y))
	points.append(Vector2(center.x - 8, center.y + 6))
	
	# Fill triangle
	control.draw_colored_polygon(points, Color(0.8, 0.75, 0.6, 1.0))
	
	# Draw border
	control.draw_polyline(points, Color(0.6, 0.55, 0.4, 1.0), 1.0, true)

func _style_vintage_button(button: Button):
	# Create vintage button style
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.2, 0.3, 0.9)
	normal_style.border_color = Color(0.8, 0.75, 0.6, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", normal_style)
	
	# Hover style
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.2, 0.25, 0.35, 0.95)
	hover_style.border_color = Color(1, 0.9, 0.7, 1.0)
	hover_style.border_width_left = 2
	hover_style.border_width_top = 2
	hover_style.border_width_right = 2
	hover_style.border_width_bottom = 2
	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed style
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.1, 0.15, 0.25, 1.0)
	pressed_style.border_color = Color(0.6, 0.55, 0.4, 1.0)
	pressed_style.border_width_left = 2
	pressed_style.border_width_top = 2
	pressed_style.border_width_right = 2
	pressed_style.border_width_bottom = 2
	pressed_style.corner_radius_top_left = 8
	pressed_style.corner_radius_top_right = 8
	pressed_style.corner_radius_bottom_left = 8
	pressed_style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Text styling
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1.0))

func _notification(what: int):
	if what == NOTIFICATION_READY:
		GameLogger.debug("CulturalNPC: _notification(READY) called for " + npc_name)
	elif what == NOTIFICATION_PREDELETE:
		GameLogger.debug("CulturalNPC: _notification(PREDELETE) called for " + npc_name)
		# Force cleanup of all timers before deletion
		for child in get_children():
			if child is Timer and is_instance_valid(child):
				child.stop()
				child.queue_free()
				GameLogger.debug("CulturalNPC: Timer cleaned up in PREDELETE: " + child.name)

func _exit_tree():
	GameLogger.debug("CulturalNPC: _exit_tree() called for " + npc_name)
	

	
	# Enhanced debug logging for cleanup process
	if has_node("/root/DebugConfig") and get_node("/root/DebugConfig").enable_timer_debug:
		GameLogger.debug("CulturalNPC: Starting cleanup for " + npc_name + " - is_inside_tree: " + str(is_inside_tree()) + ", is_instance_valid: " + str(is_instance_valid(self)))
	
	# CRITICAL: Clean up ALL timers immediately to prevent !is_inside_tree() errors
	var input_timer = get_node_or_null("DialogueInputTimer")
	if input_timer and is_instance_valid(input_timer):
		input_timer.stop()
		input_timer.queue_free()
		GameLogger.debug("CulturalNPC: Input timer cleaned up in _exit_tree")
	else:
		GameLogger.debug("CulturalNPC: No input timer found to clean up in _exit_tree")
	
	var typewriter_timer = get_node_or_null("TypewriterTimer")
	if typewriter_timer and is_instance_valid(typewriter_timer):
		typewriter_timer.stop()
		typewriter_timer.queue_free()
		GameLogger.debug("CulturalNPC: Typewriter timer cleaned up in _exit_tree")
	else:
		GameLogger.debug("CulturalNPC: No typewriter timer found to clean up in _exit_tree")
	
	# Clean up ANY other timers that might exist
	for child in get_children():
		if child is Timer and is_instance_valid(child):
			child.stop()
			child.queue_free()
			GameLogger.debug("CulturalNPC: Additional timer cleaned up: " + child.name)
	
	# Also clean up any timers stored in metadata
	var dialogue_ui = get_node_or_null("DialogueUI")
	if dialogue_ui:
		var message_text = dialogue_ui.get_node_or_null("DialoguePanel/MessageContainer/MessageText")
		if message_text and message_text.has_meta("typewriter_timer"):
			var meta_timer = message_text.get_meta("typewriter_timer")
			if meta_timer and is_instance_valid(meta_timer):
				meta_timer.stop()
				meta_timer.queue_free()
				GameLogger.debug("CulturalNPC: Meta timer cleaned up in _exit_tree")
	
	# Disconnect signals to prevent callbacks after node removal
	if GlobalSignals.on_npc_interaction.is_connected(_on_npc_interaction):
		GlobalSignals.on_npc_interaction.disconnect(_on_npc_interaction)
	
	# EventBus cleanup - use proper unsubscribe method
	if EventBus:
		EventBus.unsubscribe(self)
	
	GameLogger.debug("CulturalNPC: Cleanup complete for " + npc_name)
