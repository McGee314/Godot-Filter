class_name BaseInputProcessor
extends Node

# Base class for all input processing components
# Provides consistent input handling with safety checks and OOP structure

# Input state tracking
var is_input_active: bool = true
var is_being_destroyed: bool = false

# Mouse motion input
var mouse_motion_input: Vector2 = Vector2.ZERO
var last_mouse_motion: Vector2 = Vector2.ZERO

# Input processing flags
var process_mouse_motion: bool = true
var process_keyboard_input: bool = true
var process_mouse_buttons: bool = true

# Mouse mode tracking
var current_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func _ready():
	# Set up default behavior for all input processors
	GameLogger.debug("BaseInputProcessor: _ready() called for " + name)
	
	# Initialize mouse mode
	current_mouse_mode = Input.mouse_mode
	
	# Call the child's custom ready function
	_on_input_processor_ready()

func _exit_tree():
	# CRITICAL: Automatic cleanup to prevent !is_inside_tree() errors
	GameLogger.debug("BaseInputProcessor: _exit_tree() called for " + name)
	
	# Mark as being destroyed to prevent any further operations
	is_being_destroyed = true
	is_input_active = false
	
	# Call child's custom cleanup
	_on_input_processor_cleanup()
	
	GameLogger.debug("BaseInputProcessor: Cleanup complete for " + name)

func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		GameLogger.debug("BaseInputProcessor: _notification(PREDELETE) called for " + name)
		# Force cleanup before deletion
		is_being_destroyed = true

# Virtual functions that child classes should override
func _on_input_processor_ready():
	# Override this in child classes for custom initialization
	pass

func _on_input_processor_cleanup():
	# Override this in child classes for custom cleanup
	pass

# Safe input handling wrapper
func safe_set_input_as_handled():
	# Safe wrapper for set_input_as_handled() with all necessary checks
	if is_inside_tree() and is_instance_valid(self) and not is_being_destroyed:
		var viewport = get_viewport()
		if viewport and is_instance_valid(viewport):
			viewport.set_input_as_handled()
			return true
		else:
			GameLogger.warning("BaseInputProcessor: Invalid viewport when trying to set input as handled for " + name)
	else:
		GameLogger.warning("BaseInputProcessor: Cannot set input as handled - node not in tree or being destroyed for " + name)
	return false

# Input state management
func activate_input_processing():
	if not is_being_destroyed:
		is_input_active = true
		set_process_input(true)
		set_process_unhandled_input(true)

func deactivate_input_processing():
	is_input_active = false
	set_process_input(false)
	set_process_unhandled_input(false)

# Safety check functions
func is_input_processor_valid() -> bool:
	return is_inside_tree() and is_instance_valid(self) and not is_being_destroyed

func can_process_input() -> bool:
	return is_input_processor_valid() and is_input_active

func can_process_unhandled_input() -> bool:
	return is_input_processor_valid() and is_input_active

# Override input functions with safety checks
func _input(event):
	# Safety check before processing input
	if not can_process_input():
		return
	
	# Call child's input handling
	_on_input_processor_input(event)

func _unhandled_input(event):
	# Safety check before processing unhandled input
	if not can_process_unhandled_input():
		return
	
	# Process mouse motion events consistently
	if process_mouse_motion and event is InputEventMouseMotion:
		_handle_mouse_motion(event)
		return
	
	# Process keyboard events
	if process_keyboard_input and event is InputEventKey:
		_handle_keyboard_input(event)
		return
	
	# Process mouse button events
	if process_mouse_buttons and event is InputEventMouseButton:
		_handle_mouse_button_input(event)
		return
	
	# Call child's unhandled input handling for other events
	_on_input_processor_unhandled_input(event)

# Virtual input functions for child classes
func _on_input_processor_input(_event): # Prefixed for unused parameter warning
	# Override this in child classes for custom input handling
	pass

func _on_input_processor_unhandled_input(_event): # Prefixed for unused parameter warning
	# Override this in child classes for custom unhandled input handling
	pass

# Standard mouse motion handling
func _handle_mouse_motion(event: InputEventMouseMotion):
	# Store the mouse motion for child classes to use
	mouse_motion_input = event.relative
	last_mouse_motion = event.relative
	
	# Call child's mouse motion handler
	_on_mouse_motion(event)
	
	# Set input as handled to prevent propagation
	safe_set_input_as_handled()

# Standard keyboard input handling
func _handle_keyboard_input(event: InputEventKey):
	# Call child's keyboard handler
	_on_keyboard_input(event)

# Standard mouse button input handling
func _handle_mouse_button_input(event: InputEventMouseButton):
	# Call child's mouse button handler
	_on_mouse_button_input(event)

# Virtual functions for specific input types
func _on_mouse_motion(_event: InputEventMouseMotion):
	# Override this in child classes for custom mouse motion handling
	pass

func _on_keyboard_input(_event: InputEventKey):
	# Override this in child classes for custom keyboard handling
	pass

func _on_mouse_button_input(_event: InputEventMouseButton):
	# Override this in child classes for custom mouse button handling
	pass

# Public getter methods for input state
func get_mouse_motion_input() -> Vector2:
	return mouse_motion_input

func get_last_mouse_motion() -> Vector2:
	return last_mouse_motion

func clear_mouse_motion_input():
	mouse_motion_input = Vector2.ZERO

# Mouse mode control
func set_mouse_mode(mode: Input.MouseMode):
	if not is_being_destroyed:
		current_mouse_mode = mode
		Input.mouse_mode = mode

func get_mouse_mode() -> Input.MouseMode:
	return current_mouse_mode

func toggle_mouse_mode():
	if not is_being_destroyed:
		if current_mouse_mode == Input.MOUSE_MODE_CAPTURED:
			set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Utility functions for child classes
func log_input_action(action: String):
	# Safe logging for input actions
	if is_input_processor_valid():
		GameLogger.debug("BaseInputProcessor: " + action + " for " + name)

func warn_input_action(action: String):
	# Safe warning logging for input actions
	GameLogger.warning("BaseInputProcessor: " + action + " for " + name)
