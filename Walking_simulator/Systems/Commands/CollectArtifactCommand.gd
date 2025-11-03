class_name CollectArtifactCommand
extends CulturalActionCommand

# Command data
var artifact_name: String
var artifact_data: Dictionary
var inventory_slot: int = -1

# References to systems
var inventory_system: CulturalInventory
var artifact_world_item: Node3D

func _init(p_artifact_name: String, p_region: String, p_artifact_data: Dictionary = {}):
	super._init()
	self.artifact_name = p_artifact_name
	self.region = p_region
	self.artifact_data = p_artifact_data

# Factory method for creating commands
static func create(p_artifact_name: String, p_region: String, p_artifact_data: Dictionary = {}) -> CollectArtifactCommand:
	return CollectArtifactCommand.new(p_artifact_name, p_region, p_artifact_data)

# Set inventory system reference
func set_inventory_system(inventory: CulturalInventory):
	inventory_system = inventory

func execute() -> bool:
	# Check if inventory system is available
	if not inventory_system:
		push_error("CulturalInventory not set. Call set_inventory_system() first.")
		return false
	
	# Create cultural item from data
	var cultural_item = _create_cultural_item()
	if not cultural_item:
		push_error("Failed to create cultural item")
		return false
	
	# Add to inventory
	inventory_system.add_cultural_artifact(cultural_item, region)
	
	# Find the slot where the item was added
	inventory_slot = _find_item_slot(cultural_item)
	
	# Emit global signal
	GlobalSignals.on_collect_artifact.emit(artifact_name, region)
	
	print("Executed: Collected artifact '", artifact_name, "' from ", region)
	return true

func undo() -> bool:
	if inventory_slot == -1:
		push_error("Cannot undo: No inventory slot recorded")
		return false
	
	# Check if inventory system is available
	if not inventory_system:
		push_error("CulturalInventory not set. Cannot undo.")
		return false
	
	# Remove from inventory
	if inventory_slot >= 0 and inventory_slot < inventory_system.slots.size():
		inventory_system.slots[inventory_slot].set_item(null)
		inventory_system.update_display()
	
	# Remove from collected artifacts
	if inventory_system.collected_artifacts.has(region):
		var artifacts = inventory_system.collected_artifacts[region]
		artifacts.erase(artifact_name)
		inventory_system.collected_count = max(0, inventory_system.collected_count - 1)
	
	# Emit undo signal
	GlobalSignals.on_collect_artifact.emit("UNDO_" + artifact_name, region)
	
	print("Undone: Removed artifact '", artifact_name, "' from ", region)
	return true

func get_description() -> String:
	return "Collected " + artifact_name + " from " + region

func get_command_type() -> String:
	return "collect_artifact"

func get_command_data() -> Dictionary:
	var data = super.get_command_data()
	data["artifact_name"] = artifact_name
	data["artifact_data"] = artifact_data
	data["inventory_slot"] = inventory_slot
	return data

func set_command_data(data: Dictionary):
	super.set_command_data(data)
	if data.has("artifact_name"):
		artifact_name = data.artifact_name
	if data.has("artifact_data"):
		artifact_data = data.artifact_data
	if data.has("inventory_slot"):
		inventory_slot = data.inventory_slot

# Helper methods
func _create_cultural_item() -> CulturalItem:
	# Create a cultural item from the artifact data
	var item = CulturalItem.new()
	
	if artifact_data.has("display_name"):
		item.display_name = artifact_data.display_name
	else:
		item.display_name = artifact_name
	
	if artifact_data.has("description"):
		item.description = artifact_data.description
	
	if artifact_data.has("region"):
		item.region = artifact_data.region
	else:
		item.region = region
	
	if artifact_data.has("cultural_significance"):
		item.cultural_significance = artifact_data.cultural_significance
	
	if artifact_data.has("icon_path"):
		item.icon_path = artifact_data.icon_path
	
	return item

func _find_item_slot(item: CulturalItem) -> int:
	if not inventory_system:
		return -1
	
	# Find the slot where the item was added
	for i in range(inventory_system.slots.size()):
		var slot = inventory_system.slots[i]
		if slot.item and slot.item.display_name == item.display_name:
			return i
	
	return -1
