class_name CulturalItemFactory
extends RefCounted

# Factory Pattern implementation for creating cultural items
# Follows Open/Closed Principle - open for extension, closed for modification

# Item type definitions
enum ItemType {
	ARTIFACT,
	RECIPE,
	TOOL,
	CLOTHING,
	MUSICAL_INSTRUMENT,
	DECORATIVE,
	RITUAL_OBJECT
}

# Registry of item creators
static var _item_creators: Dictionary = {}

# Initialize factory with default item types
static func _static_init():
	_register_default_creators()

# Register a creator function for a specific item type
static func register_creator(item_type: ItemType, creator_func: Callable):
	_item_creators[item_type] = creator_func

# Create an item of the specified type
static func create_item(item_type: ItemType, item_data: Dictionary = {}) -> CulturalItem:
	if not _item_creators.has(item_type):
		push_error("No creator registered for item type: ", item_type)
		return null
	
	var creator = _item_creators[item_type]
	return creator.call(item_data)

# Create item by type string (for configuration-driven creation)
static func create_item_by_string(item_type_string: String, item_data: Dictionary = {}) -> CulturalItem:
	var item_type = _string_to_item_type(item_type_string)
	if item_type == null:
		push_error("Unknown item type string: ", item_type_string)
		return null
	
	return create_item(item_type, item_data)

# Create item from configuration data
static func create_item_from_config(config: Dictionary) -> CulturalItem:
	if not config.has("type"):
		push_error("Item config missing 'type' field")
		return null
	
	var item_type = _string_to_item_type(config.type)
	if item_type == null:
		push_error("Unknown item type in config: ", config.type)
		return null
	
	# Merge config data
	var item_data = config.duplicate()
	item_data.erase("type")  # Remove type from data
	
	return create_item(item_type, item_data)

# Register default creators
static func _register_default_creators():
	# Artifact creator
	register_creator(ItemType.ARTIFACT, func(data: Dictionary) -> CulturalItem:
		var item = CulturalItem.new()
		item.display_name = data.get("display_name", "Ancient Artifact")
		item.description = data.get("description", "A mysterious artifact from the past.")
		item.region = data.get("region", "Unknown")
		item.cultural_significance = data.get("cultural_significance", "This artifact holds great cultural importance.")
		item.icon_path = data.get("icon_path", "")
		item.item_type = "artifact"
		return item
	)
	
	# Recipe creator
	register_creator(ItemType.RECIPE, func(data: Dictionary) -> CulturalItem:
		var item = CulturalItem.new()
		item.display_name = data.get("display_name", "Traditional Recipe")
		item.description = data.get("description", "A traditional recipe passed down through generations.")
		item.region = data.get("region", "Unknown")
		item.cultural_significance = data.get("cultural_significance", "This recipe represents traditional cooking methods.")
		item.icon_path = data.get("icon_path", "")
		item.item_type = "recipe"
		item.recipe_ingredients = data.get("ingredients", [])
		item.recipe_instructions = data.get("instructions", "")
		return item
	)
	
	# Tool creator
	register_creator(ItemType.TOOL, func(data: Dictionary) -> CulturalItem:
		var item = CulturalItem.new()
		item.display_name = data.get("display_name", "Traditional Tool")
		item.description = data.get("description", "A traditional tool used by local craftspeople.")
		item.region = data.get("region", "Unknown")
		item.cultural_significance = data.get("cultural_significance", "This tool represents traditional craftsmanship.")
		item.icon_path = data.get("icon_path", "")
		item.item_type = "tool"
		item.tool_material = data.get("material", "wood")
		item.tool_purpose = data.get("purpose", "general")
		return item
	)
	
	# Clothing creator
	register_creator(ItemType.CLOTHING, func(data: Dictionary) -> CulturalItem:
		var item = CulturalItem.new()
		item.display_name = data.get("display_name", "Traditional Clothing")
		item.description = data.get("description", "Traditional clothing representing local culture.")
		item.region = data.get("region", "Unknown")
		item.cultural_significance = data.get("cultural_significance", "This clothing represents traditional fashion and culture.")
		item.icon_path = data.get("icon_path", "")
		item.item_type = "clothing"
		item.clothing_material = data.get("material", "fabric")
		item.clothing_style = data.get("style", "traditional")
		return item
	)
	
	# Musical instrument creator
	register_creator(ItemType.MUSICAL_INSTRUMENT, func(data: Dictionary) -> CulturalItem:
		var item = CulturalItem.new()
		item.display_name = data.get("display_name", "Traditional Instrument")
		item.description = data.get("description", "A traditional musical instrument.")
		item.region = data.get("region", "Unknown")
		item.cultural_significance = data.get("cultural_significance", "This instrument represents traditional music and culture.")
		item.icon_path = data.get("icon_path", "")
		item.item_type = "musical_instrument"
		item.instrument_type = data.get("instrument_type", "percussion")
		item.instrument_material = data.get("material", "wood")
		return item
	)
	
	# Decorative creator
	register_creator(ItemType.DECORATIVE, func(data: Dictionary) -> CulturalItem:
		var item = CulturalItem.new()
		item.display_name = data.get("display_name", "Decorative Item")
		item.description = data.get("description", "A decorative item with cultural significance.")
		item.region = data.get("region", "Unknown")
		item.cultural_significance = data.get("cultural_significance", "This decorative item represents local artistic traditions.")
		item.icon_path = data.get("icon_path", "")
		item.item_type = "decorative"
		item.decorative_style = data.get("style", "traditional")
		item.decorative_material = data.get("material", "mixed")
		return item
	)
	
	# Ritual object creator
	register_creator(ItemType.RITUAL_OBJECT, func(data: Dictionary) -> CulturalItem:
		var item = CulturalItem.new()
		item.display_name = data.get("display_name", "Ritual Object")
		item.description = data.get("description", "A sacred object used in traditional rituals.")
		item.region = data.get("region", "Unknown")
		item.cultural_significance = data.get("cultural_significance", "This ritual object holds deep spiritual and cultural significance.")
		item.icon_path = data.get("icon_path", "")
		item.item_type = "ritual_object"
		item.ritual_purpose = data.get("purpose", "ceremonial")
		item.ritual_material = data.get("material", "sacred")
		return item
	)

# Helper method to convert string to item type
static func _string_to_item_type(item_type_string: String) -> ItemType:
	match item_type_string.to_lower():
		"artifact":
			return ItemType.ARTIFACT
		"recipe":
			return ItemType.RECIPE
		"tool":
			return ItemType.TOOL
		"clothing":
			return ItemType.CLOTHING
		"musical_instrument", "instrument":
			return ItemType.MUSICAL_INSTRUMENT
		"decorative":
			return ItemType.DECORATIVE
		"ritual_object", "ritual":
			return ItemType.RITUAL_OBJECT
		_:
			return ItemType.ARTIFACT  # Default to ARTIFACT instead of null

# Get all available item types
static func get_available_item_types() -> Array[ItemType]:
	return _item_creators.keys()

# Get item type names for UI
static func get_item_type_names() -> Array[String]:
	var names: Array[String] = []
	for item_type in _item_creators.keys():
		names.append(_item_type_to_string(item_type))
	return names

# Convert item type to string
static func _item_type_to_string(item_type: ItemType) -> String:
	match item_type:
		ItemType.ARTIFACT:
			return "Artifact"
		ItemType.RECIPE:
			return "Recipe"
		ItemType.TOOL:
			return "Tool"
		ItemType.CLOTHING:
			return "Clothing"
		ItemType.MUSICAL_INSTRUMENT:
			return "Musical Instrument"
		ItemType.DECORATIVE:
			return "Decorative"
		ItemType.RITUAL_OBJECT:
			return "Ritual Object"
		_:
			return "Unknown"

# Create items for a specific region
static func create_region_items(region: String, item_configs: Array[Dictionary]) -> Array[CulturalItem]:
	var items: Array[CulturalItem] = []
	
	for config in item_configs:
		config["region"] = region  # Set region for all items
		var item = create_item_from_config(config)
		if item:
			items.append(item)
	
	return items

# Validate item configuration
static func validate_item_config(config: Dictionary) -> bool:
	if not config.has("type"):
		return false
	
	if not config.has("display_name"):
		return false
	
	# Check if the type is valid by comparing with known types
	var config_type_string = config.type.to_lower()
	var valid_types = ["artifact", "recipe", "tool", "clothing", "musical_instrument", "instrument", "decorative", "ritual_object", "ritual"]
	if not valid_types.has(config_type_string):
		return false
	
	return true
