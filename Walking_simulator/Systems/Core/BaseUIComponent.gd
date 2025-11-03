class_name BaseUIComponent
extends Control

# Base class for all UI components to prevent !is_inside_tree() errors
# All UI components should inherit from this class instead of Control directly

# Component state tracking
var is_component_active: bool = true
var is_being_destroyed: bool = false

# Input handling flags
var input_enabled: bool = true
var unhandled_input_enabled: bool = true

func _ready():
	# Set up default behavior for all UI components
	GameLogger.debug("BaseUIComponent: _ready() called for " + name)
	
	# Ensure proper input handling setup
	setup_input_processing()
	
	# Call the child's custom ready function
	_on_component_ready()

func _exit_tree():
	# CRITICAL: Automatic cleanup to prevent !is_inside_tree() errors
	GameLogger.debug("BaseUIComponent: _exit_tree() called for " + name)
	
	# Mark as being destroyed to prevent any further operations
	is_being_destroyed = true
	is_component_active = false
	
	# Disable all input processing
	disable_input_processing()
	
	# Hide component to prevent any UI updates
	visible = false
	
	# Call child's custom cleanup
	_on_component_cleanup()
	
	GameLogger.debug("BaseUIComponent: Cleanup complete for " + name)

func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		GameLogger.debug("BaseUIComponent: _notification(PREDELETE) called for " + name)
		# Force cleanup before deletion
		is_being_destroyed = true
		disable_input_processing()

# Virtual functions that child classes should override
func _on_component_ready():
	# Override this in child classes for custom initialization
	pass

func _on_component_cleanup():
	# Override this in child classes for custom cleanup
	pass

# Input handling safety functions
func setup_input_processing():
	# Enable input processing with safety checks
	if not is_being_destroyed and is_component_active:
		set_process_input(true)
		set_process_unhandled_input(true)
		input_enabled = true
		unhandled_input_enabled = true

func disable_input_processing():
	# Disable all input processing to prevent !is_inside_tree() errors
	set_process_input(false)
	set_process_unhandled_input(false)
	input_enabled = false
	unhandled_input_enabled = false
	GameLogger.debug("BaseUIComponent: Input processing disabled for " + name)

# Safe input handling wrapper
func safe_set_input_as_handled():
	# Simple wrapper for set_input_as_handled()
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()
		return true
	return false

# Component state management
func activate_component():
	if not is_being_destroyed:
		is_component_active = true
		visible = true
		setup_input_processing()

func deactivate_component():
	is_component_active = false
	visible = false
	disable_input_processing()

# Safety check functions
func is_component_valid() -> bool:
	return is_inside_tree() and is_instance_valid(self) and not is_being_destroyed

func can_process_input() -> bool:
	return is_component_valid() and input_enabled and is_component_active

func can_process_unhandled_input() -> bool:
	return is_component_valid() and unhandled_input_enabled and is_component_active

# Override input functions with safety checks
func _input(event):
	# Safety check before processing input
	if not can_process_input():
		return
	
	# Call child's input handling
	_on_component_input(event)

func _unhandled_input(event):
	# Safety check before processing unhandled input
	if not can_process_unhandled_input():
		return
	
	# Call child's unhandled input handling
	_on_component_unhandled_input(event)

# Virtual input functions for child classes
func _on_component_input(_event):
	# Override this in child classes for custom input handling
	pass

func _on_component_unhandled_input(_event):
	# Override this in child classes for custom unhandled input handling
	pass

# Utility functions for child classes
func log_component_action(action: String):
	# Safe logging for component actions
	if is_component_valid():
		GameLogger.debug("BaseUIComponent: " + action + " for " + name)

func warn_component_action(action: String):
	# Safe warning logging for component actions
	GameLogger.warning("BaseUIComponent: " + action + " for " + name)
