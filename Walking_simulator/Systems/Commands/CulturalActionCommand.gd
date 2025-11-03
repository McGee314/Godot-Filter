class_name CulturalActionCommand
extends RefCounted

# Base class for all cultural action commands
# Implements the Command Pattern for undo/redo functionality

# Command metadata
var timestamp: float
var region: String
var player_id: String

func _init():
	timestamp = Time.get_unix_time_from_system()
	player_id = "player"  # Could be extended for multiplayer

# Execute the command
func execute() -> bool:
	push_error("execute() must be implemented by subclass")
	return false

# Undo the command
func undo() -> bool:
	push_error("undo() must be implemented by subclass")
	return false

# Get command description for UI
func get_description() -> String:
	push_error("get_description() must be implemented by subclass")
	return ""

# Get command type for categorization
func get_command_type() -> String:
	push_error("get_command_type() must be implemented by subclass")
	return ""

# Check if command can be undone
func can_undo() -> bool:
	return true

# Get command data for serialization
func get_command_data() -> Dictionary:
	return {
		"timestamp": timestamp,
		"region": region,
		"player_id": player_id,
		"type": get_command_type()
	}

# Set command data from serialization
func set_command_data(data: Dictionary):
	if data.has("timestamp"):
		timestamp = data.timestamp
	if data.has("region"):
		region = data.region
	if data.has("player_id"):
		player_id = data.player_id
