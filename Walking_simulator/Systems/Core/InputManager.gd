extends Node

# Input state
var move_input: Vector2 = Vector2.ZERO
var camera_input: Vector2 = Vector2.ZERO
var jump_pressed: bool = false
var sprint_pressed: bool = false
var inventory_pressed: bool = false
var escape_pressed: bool = false

# Input actions
enum InputAction {
	MOVE_FORWARD,
	MOVE_BACK,
	MOVE_LEFT,
	MOVE_RIGHT,
	JUMP,
	SPRINT,
	INVENTORY,
	ESCAPE,
	INTERACT
}

# Signal for input changes
signal input_changed(action: InputAction, value: Variant)
signal move_input_updated(direction: Vector2)
signal camera_input_updated(rotation: Vector2)

func _ready():
	# Lock mouse initially
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	_process_movement_input()
	_process_action_input()
	_process_mouse_input()

func _process_movement_input():
	var new_move_input = Vector2.ZERO
	
	# Check movement keys using action-based input
	if Input.is_action_pressed("move_forward"):
		new_move_input.y -= 1
		emit_signal("input_changed", InputAction.MOVE_FORWARD, true)
	
	if Input.is_action_pressed("move_back"):
		new_move_input.y += 1
		emit_signal("input_changed", InputAction.MOVE_BACK, true)
	
	if Input.is_action_pressed("move_left"):
		new_move_input.x -= 1
		emit_signal("input_changed", InputAction.MOVE_LEFT, true)
	
	if Input.is_action_pressed("move_right"):
		new_move_input.x += 1
		emit_signal("input_changed", InputAction.MOVE_RIGHT, true)
	
	# Normalize movement input
	if new_move_input != Vector2.ZERO:
		new_move_input = new_move_input.normalized()
	
	if new_move_input != move_input:
		move_input = new_move_input
		emit_signal("move_input_updated", move_input)

func _process_action_input():
	# Jump input
	var new_jump_pressed = Input.is_action_pressed("jump")
	if new_jump_pressed != jump_pressed:
		jump_pressed = new_jump_pressed
		emit_signal("input_changed", InputAction.JUMP, jump_pressed)
	
	# Sprint input
	var new_sprint_pressed = Input.is_action_pressed("sprint")
	if new_sprint_pressed != sprint_pressed:
		sprint_pressed = new_sprint_pressed
		emit_signal("input_changed", InputAction.SPRINT, sprint_pressed)
	
	# Inventory input
	var new_inventory_pressed = Input.is_action_just_pressed("inventory")
	if new_inventory_pressed != inventory_pressed:
		inventory_pressed = new_inventory_pressed
		emit_signal("input_changed", InputAction.INVENTORY, inventory_pressed)
	
	# Escape input
	var new_escape_pressed = Input.is_action_just_pressed("ui_cancel")
	if new_escape_pressed != escape_pressed:
		escape_pressed = new_escape_pressed
		emit_signal("input_changed", InputAction.ESCAPE, escape_pressed)

func _process_mouse_input():
	if camera_input != Vector2.ZERO:
		emit_signal("camera_input_updated", camera_input)
		camera_input = Vector2.ZERO

func _unhandled_input(event):
		
	if event is InputEventMouseMotion:
		camera_input = event.relative

# Public getter methods for other components
func is_jump_pressed() -> bool:
	return jump_pressed

func is_sprint_pressed() -> bool:
	return sprint_pressed

func is_inventory_pressed() -> bool:
	return inventory_pressed

func is_escape_pressed() -> bool:
	return escape_pressed

func get_move_input() -> Vector2:
	return move_input

func get_camera_input() -> Vector2:
	return camera_input

# Mouse mode control
func set_mouse_mode(mode: Input.MouseMode):
	Input.mouse_mode = mode

func toggle_mouse_mode():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
