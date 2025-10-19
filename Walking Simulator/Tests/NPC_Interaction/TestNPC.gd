class_name TestNPC
extends CulturalInteractableObject

@export var npc_name: String = "TestNPC"
@export var interaction_range: float = 3.0

# Simple dialogue state for testing
var dialogue_active: bool = false
var dialogue_cooldown: float = 3.0
var last_dialogue_time: float = 0.0
var dialogue_just_ended: bool = false
var dialogue_end_time: float = 0.0
var dialogue_cooldown_duration: float = 3.0

func _ready():
	# Add to NPC group for InteractionController to find
	add_to_group("npc")
	
	# Set up basic properties
	interaction_prompt = "Talk to " + npc_name
	can_interact = true
	
	# Set up interaction area
	setup_interaction_area()
	
	GameLogger.info("TestNPC initialized: " + npc_name)

func setup_interaction_area():
	# Create an Area3D for interaction detection
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
	
	# Connect signals for interaction detection
	interaction_area.body_entered.connect(_on_player_entered_area)
	interaction_area.body_exited.connect(_on_player_exited_area)
	
	GameLogger.debug("TestNPC " + npc_name + " interaction area set up with radius: " + str(interaction_range))

func _on_player_entered_area(body: Node3D):
	if body is CharacterBody3D and body.is_in_group("player"):
		GameLogger.info("Player entered interaction range of " + npc_name)
		show_interaction_available()

func _on_player_exited_area(body: Node3D):
	if body is CharacterBody3D and body.is_in_group("player"):
		GameLogger.info("Player exited interaction range of " + npc_name)
		hide_interaction_available()

func show_interaction_available():
	# Visual feedback when player is in range
	if has_node("NPCModel"):
		var model = get_node("NPCModel")
		if model and model is CSGCylinder3D:
			# Create or get material for CSGCylinder3D
			if not model.material:
				model.material = StandardMaterial3D.new()
			model.material.albedo_color = Color(1.2, 1.2, 1.0)  # Slight yellow tint

func hide_interaction_available():
	# Remove visual feedback when player leaves range
	if has_node("NPCModel"):
		var model = get_node("NPCModel")
		if model and model is CSGCylinder3D:
			# Reset material color
			if model.material:
				model.material.albedo_color = Color.WHITE

func _interact():
	# Simple interaction for testing
	var current_time = Time.get_unix_time_from_system()
	
	if dialogue_active:
		GameLogger.info("Dialogue already active, ignoring interaction")
		return
	
	if current_time - last_dialogue_time < dialogue_cooldown:
		var remaining = dialogue_cooldown - (current_time - last_dialogue_time)
		GameLogger.info("Interaction blocked - cooldown active (remaining: " + str(remaining) + "s)")
		return
	
	# Start simple dialogue
	dialogue_active = true
	can_interact = false
	last_dialogue_time = current_time
	
	# Display dialogue in game UI
	display_dialogue_ui()
	
	GameLogger.info("=== DIALOGUE STARTED ===")
	GameLogger.info("NPC: Hello! I'm " + npc_name + ". How can I help you?")
	GameLogger.info("Options:")
	GameLogger.info("1. Ask about the weather")
	GameLogger.info("2. Ask about the game")
	GameLogger.info("3. Say goodbye")
	GameLogger.info("Press 1, 2, or 3 to respond...")
	
	# Set up input handling for dialogue
	call_deferred("_setup_dialogue_input")

func display_dialogue_ui():
	# Create a simple dialogue UI
	var dialogue_ui = get_node_or_null("DialogueUI")
	if not dialogue_ui:
		dialogue_ui = Control.new()
		dialogue_ui.name = "DialogueUI"
		dialogue_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(dialogue_ui)
		
		# Create background
		var background = ColorRect.new()
		background.color = Color(0, 0, 0, 0.7)
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dialogue_ui.add_child(background)
		
		# Create dialogue text
		var dialogue_text = Label.new()
		dialogue_text.name = "DialogueText"
		dialogue_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		dialogue_text.offset_left = -200
		dialogue_text.offset_top = -100
		dialogue_text.offset_right = 200
		dialogue_text.offset_bottom = 100
		dialogue_text.text = "Hello! I'm " + npc_name + ". How can I help you?\n\n1. Ask about the weather\n2. Ask about the game\n3. Say goodbye\n\nPress 1, 2, or 3 to respond...\n\nPress ESC to exit dialogue"
		dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dialogue_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		dialogue_text.add_theme_font_size_override("font_size", 24)
		dialogue_text.add_theme_color_override("font_color", Color.WHITE)
		dialogue_ui.add_child(dialogue_text)
	
	dialogue_ui.visible = true

func _setup_dialogue_input():
	# Set up input handling for dialogue choices
	call_deferred("_setup_dialogue_input_handling")

func _setup_dialogue_input_handling():
	# Create a timer to check for input during dialogue
	var input_timer = Timer.new()
	input_timer.name = "DialogueInputTimer"
	input_timer.wait_time = 0.1  # Check every 0.1 seconds
	input_timer.timeout.connect(_check_dialogue_input)
	add_child(input_timer)
	input_timer.start()

func _check_dialogue_input():
	if not dialogue_active:
		# Clean up timer if dialogue is not active
		var input_timer = get_node_or_null("DialogueInputTimer")
		if input_timer:
			input_timer.queue_free()
		return
	
	# Check for number keys 1-3
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_1):
		_handle_dialogue_response(1)
	elif Input.is_key_pressed(KEY_2):
		_handle_dialogue_response(2)
	elif Input.is_key_pressed(KEY_3):
		_handle_dialogue_response(3)
	elif Input.is_action_just_pressed("ui_cancel") or Input.is_key_pressed(KEY_ESCAPE):
		# Exit dialogue with ESC
		GameLogger.info("Dialogue cancelled with ESC key")
		_end_dialogue()

func _input(event):
	if not dialogue_active:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_handle_dialogue_response(1)
			KEY_2:
				_handle_dialogue_response(2)
			KEY_3:
				_handle_dialogue_response(3)

func _handle_dialogue_response(choice: int):
	match choice:
		1:
			update_dialogue_text("You: How's the weather?\n\nNPC: It's a beautiful day for testing interactions!")
			await get_tree().create_timer(2.0).timeout
			_end_dialogue()
		2:
			update_dialogue_text("You: Tell me about this game\n\nNPC: This is a test scene for NPC interactions!")
			await get_tree().create_timer(2.0).timeout
			_end_dialogue()
		3:
			update_dialogue_text("You: Goodbye!\n\nNPC: See you later!")
			await get_tree().create_timer(2.0).timeout
			_end_dialogue()

func update_dialogue_text(new_text: String):
	var dialogue_ui = get_node_or_null("DialogueUI")
	if dialogue_ui:
		var dialogue_text = dialogue_ui.get_node_or_null("DialogueText")
		if dialogue_text:
			dialogue_text.text = new_text

func _end_dialogue():
	dialogue_active = false
	can_interact = false  # Will be re-enabled after cooldown
	dialogue_just_ended = true
	dialogue_end_time = Time.get_unix_time_from_system()
	
	# Hide dialogue UI
	var dialogue_ui = get_node_or_null("DialogueUI")
	if dialogue_ui:
		dialogue_ui.visible = false
	
	GameLogger.info("=== DIALOGUE ENDED ===")
	GameLogger.info("Cooldown started - interaction disabled for " + str(dialogue_cooldown) + " seconds")
	
	# Re-enable interaction after cooldown
	var cooldown_timer = get_tree().create_timer(dialogue_cooldown)
	cooldown_timer.timeout.connect(_on_cooldown_expired)

func _on_cooldown_expired():
	can_interact = true
	dialogue_just_ended = false
	GameLogger.info("Cooldown expired - interaction re-enabled")
