class_name CulturalCommandManager
extends Node

# Command history
var undo_stack: Array[CulturalActionCommand] = []
var redo_stack: Array[CulturalActionCommand] = []

# Maximum history size
@export var max_history_size: int = 50

# System references
var inventory_system: CulturalInventory

# Signals
signal command_executed(command: CulturalActionCommand)
signal command_undone(command: CulturalActionCommand)
signal command_redone(command: CulturalActionCommand)
signal history_changed(undo_count: int, redo_count: int)

func _ready():
	# Connect to global signals for automatic command creation
	GlobalSignals.on_collect_artifact.connect(_on_artifact_collected)
	
	# Find inventory system
	find_inventory_system()

func find_inventory_system():
	# Try to find the inventory system in the scene tree
	var scene_tree = get_tree()
	if scene_tree and scene_tree.current_scene:
		# Look for CulturalInventory in the current scene
		var inventory = _find_inventory_in_tree(scene_tree.current_scene)
		if inventory:
			inventory_system = inventory
			print("Command Manager: Found inventory system")
		else:
			print("Command Manager: Inventory system not found")

func _find_inventory_in_tree(node: Node) -> CulturalInventory:
	if not node:
		return null
	
	# Check if this node is the inventory system
	if node is CulturalInventory:
		return node
	
	# Search children
	for child in node.get_children():
		var result = _find_inventory_in_tree(child)
		if result:
			return result
	
	return null

func set_inventory_system(inventory: CulturalInventory):
	inventory_system = inventory
	print("Command Manager: Inventory system set manually")

func execute_command(command: CulturalActionCommand) -> bool:
	if not command:
		push_error("Cannot execute null command")
		return false
	
	# Set inventory system reference for CollectArtifactCommand
	if command is CollectArtifactCommand and inventory_system:
		command.set_inventory_system(inventory_system)
	
	# Execute the command
	if command.execute():
		# Add to undo stack
		undo_stack.push_front(command)
		
		# Clear redo stack when new command is executed
		redo_stack.clear()
		
		# Limit history size
		if undo_stack.size() > max_history_size:
			undo_stack.pop_back()
		
		# Emit signals
		emit_signal("command_executed", command)
		emit_signal("history_changed", undo_stack.size(), redo_stack.size())
		
		print("Command executed: ", command.get_description())
		return true
	else:
		push_error("Failed to execute command: ", command.get_description())
		return false

func undo_command() -> bool:
	if undo_stack.is_empty():
		print("No commands to undo")
		return false
	
	var command = undo_stack.pop_front()
	
	# Set inventory system reference for CollectArtifactCommand
	if command is CollectArtifactCommand and inventory_system:
		command.set_inventory_system(inventory_system)
	
	if command.undo():
		# Add to redo stack
		redo_stack.push_front(command)
		
		# Emit signals
		emit_signal("command_undone", command)
		emit_signal("history_changed", undo_stack.size(), redo_stack.size())
		
		print("Command undone: ", command.get_description())
		return true
	else:
		# If undo failed, put command back in undo stack
		undo_stack.push_front(command)
		push_error("Failed to undo command: ", command.get_description())
		return false

func redo_command() -> bool:
	if redo_stack.is_empty():
		print("No commands to redo")
		return false
	
	var command = redo_stack.pop_front()
	
	# Set inventory system reference for CollectArtifactCommand
	if command is CollectArtifactCommand and inventory_system:
		command.set_inventory_system(inventory_system)
	
	if command.execute():
		# Add back to undo stack
		undo_stack.push_front(command)
		
		# Emit signals
		emit_signal("command_redone", command)
		emit_signal("history_changed", undo_stack.size(), redo_stack.size())
		
		print("Command redone: ", command.get_description())
		return true
	else:
		# If redo failed, put command back in redo stack
		redo_stack.push_front(command)
		push_error("Failed to redo command: ", command.get_description())
		return false

func can_undo() -> bool:
	return not undo_stack.is_empty()

func can_redo() -> bool:
	return not redo_stack.is_empty()

func get_undo_count() -> int:
	return undo_stack.size()

func get_redo_count() -> int:
	return redo_stack.size()

func clear_history():
	undo_stack.clear()
	redo_stack.clear()
	emit_signal("history_changed", 0, 0)
	print("Command history cleared")

func get_command_history() -> Array[CulturalActionCommand]:
	return undo_stack.duplicate()

func get_redo_history() -> Array[CulturalActionCommand]:
	return redo_stack.duplicate()

# Save/load command history for session persistence
func save_history() -> Dictionary:
	var history_data = {
		"undo_stack": [],
		"redo_stack": []
	}
	
	# Save undo stack
	for command in undo_stack:
		history_data.undo_stack.append(command.get_command_data())
	
	# Save redo stack
	for command in redo_stack:
		history_data.redo_stack.append(command.get_command_data())
	
	return history_data

func load_history(history_data: Dictionary):
	clear_history()
	
	# Load undo stack
	if history_data.has("undo_stack"):
		for command_data in history_data.undo_stack:
			var command = _create_command_from_data(command_data)
			if command:
				undo_stack.append(command)
	
	# Load redo stack
	if history_data.has("redo_stack"):
		for command_data in history_data.redo_stack:
			var command = _create_command_from_data(command_data)
			if command:
				redo_stack.append(command)
	
	emit_signal("history_changed", undo_stack.size(), redo_stack.size())

# Event handlers
func _on_artifact_collected(artifact_name: String, region: String):
	# Don't create commands for undo operations
	if artifact_name.begins_with("UNDO_"):
		return
	
	# Create collect artifact command
	var command = CollectArtifactCommand.create(artifact_name, region)
	
	# Set inventory system reference
	if inventory_system:
		command.set_inventory_system(inventory_system)
	
	execute_command(command)

# Helper methods
func _create_command_from_data(command_data: Dictionary) -> CulturalActionCommand:
	if not command_data.has("type"):
		push_error("Command data missing type")
		return null
	
	match command_data.type:
		"collect_artifact":
			var command = CollectArtifactCommand.new("", "")
			command.set_command_data(command_data)
			
			# Set inventory system reference
			if inventory_system:
				command.set_inventory_system(inventory_system)
			
			return command
		_:
			push_error("Unknown command type: ", command_data.type)
			return null

# Input handling for undo/redo
func _input(event):
	if event.is_action_pressed("undo"):
		undo_command()
	elif event.is_action_pressed("redo"):
		redo_command()
