class_name CulturalItem
extends Resource

@export var display_name: String
@export var icon: Texture2D
@export var max_stack_size: int = 1  # Most cultural items are unique
@export var world_item_scene: PackedScene

# Cultural-specific properties
@export var cultural_region: String
@export var historical_period: String
@export var cultural_significance: String
@export var description: String
@export var audio_description: AudioStream

# Exhibition tracking
@export var educational_value: int = 1  # Points for learning
@export var rarity: String = "Common"  # Common, Uncommon, Rare, Legendary

func _on_use(_player) -> bool:
	# Show cultural information when used
	var info_data = {
		"name": display_name,
		"region": cultural_region,
		"period": historical_period,
		"significance": cultural_significance,
		"description": description,
		"audio": audio_description
	}
	# Emit via autoload if available (works in headless and editor)
	var tree := Engine.get_main_loop()
	if tree and tree is SceneTree:
		var root := (tree as SceneTree).root
		var gs = root.get_node_or_null("GlobalSignals")
		if gs:
			gs.on_show_cultural_info.emit(info_data)
	
	# Play audio description if available
	if audio_description:
		var tree2 := Engine.get_main_loop()
		if tree2 and tree2 is SceneTree:
			var root2 := (tree2 as SceneTree).root
			var gs2 = root2.get_node_or_null("GlobalSignals")
			if gs2:
				gs2.on_play_cultural_audio.emit("artifact_description", cultural_region)
	
	return true

func get_display_info() -> Dictionary:
	return {
		"name": display_name,
		"region": cultural_region,
		"period": historical_period,
		"rarity": rarity,
		"educational_value": educational_value
	}
