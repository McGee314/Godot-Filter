class_name InventorySlot
extends Panel

@onready var item_icon: TextureRect = $ItemIcon
@onready var item_label: Label = $ItemLabel
@onready var quantity_label: Label = $QuantityLabel

var item: CulturalItem = null
var quantity: int = 0
var inventory: CulturalInventory

func _ready():
	# Connect right-click signal for item inspection
	gui_input.connect(_on_gui_input)

func set_item(new_item: CulturalItem):
	item = new_item
	
	if item:
		# Set item icon
		if item.icon:
			item_icon.texture = item.icon
			item_icon.visible = true
		else:
			item_icon.visible = false
		
		# Set item label
		item_label.text = item.display_name
		item_label.visible = true
		
		# Set quantity (most cultural items are unique)
		quantity = 1
		quantity_label.text = str(quantity)
		quantity_label.visible = quantity > 1
		
		# Set tooltip
		tooltip_text = "Right-click to view cultural information"
		
		# Change background color based on rarity
		set_rarity_color(item.rarity)
	else:
		# Clear slot
		item_icon.visible = false
		item_label.visible = false
		quantity_label.visible = false
		tooltip_text = ""
		modulate = Color.WHITE

func set_rarity_color(rarity: String):
	match rarity:
		"Common":
			modulate = Color.WHITE
		"Uncommon":
			modulate = Color.GREEN
		"Rare":
			modulate = Color.BLUE
		"Legendary":
			modulate = Color.PURPLE
		_:
			modulate = Color.WHITE

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if item:
				show_item_info()

func show_item_info():
	if not item:
		return
	
	# Show cultural information
	var info_data = item.get_display_info()
	info_data["description"] = item.description
	info_data["significance"] = item.cultural_significance
	
	GlobalSignals.on_show_cultural_info.emit(info_data)
	
	# Play audio description if available
	if item.audio_description:
		GlobalSignals.on_play_cultural_audio.emit("artifact_description", item.cultural_region)

func add_item():
	if item:
		quantity += 1
		quantity_label.text = str(quantity)
		quantity_label.visible = quantity > 1

func remove_item():
	if item and quantity > 0:
		quantity -= 1
		quantity_label.text = str(quantity)
		quantity_label.visible = quantity > 1
		
		if quantity <= 0:
			set_item(null)
