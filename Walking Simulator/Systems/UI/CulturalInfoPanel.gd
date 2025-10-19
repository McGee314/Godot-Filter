class_name CulturalInfoPanel
extends Control

@onready var info_panel: Panel = $InfoPanel
@onready var title_label: Label = $InfoPanel/VBoxContainer/TitleLabel
@onready var region_label: Label = $InfoPanel/VBoxContainer/RegionLabel
@onready var period_label: Label = $InfoPanel/VBoxContainer/PeriodLabel
@onready var description_label: Label = $InfoPanel/VBoxContainer/DescriptionLabel
@onready var significance_label: Label = $InfoPanel/VBoxContainer/SignificanceLabel
@onready var close_button: Button = $InfoPanel/VBoxContainer/CloseButton

func _ready():
	# Hide panel initially
	info_panel.visible = false
	
	# Connect close button
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Connect to global signals
	GlobalSignals.on_show_cultural_info.connect(_on_show_cultural_info)
	GlobalSignals.on_hide_cultural_info.connect(_on_hide_cultural_info)
	
	# Set mouse filter to ignore when panel is hidden
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_show_cultural_info(info_data: Dictionary):
	# Update labels with cultural information
	title_label.text = info_data.get("name", "Unknown Item")
	region_label.text = "Region: " + info_data.get("region", "Unknown")
	period_label.text = "Period: " + info_data.get("period", "Unknown")
	description_label.text = info_data.get("description", "No description available.")
	significance_label.text = "Cultural Significance: " + info_data.get("significance", "No significance data available.")
	
	# Show the panel
	info_panel.visible = true
	
	# Allow mouse input when panel is visible
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Auto-hide after 10 seconds
	await get_tree().create_timer(10.0).timeout
	if info_panel.visible:
		_on_hide_cultural_info()

func _on_hide_cultural_info():
	info_panel.visible = false
	# Ignore mouse input when panel is hidden
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_close_button_pressed():
	_on_hide_cultural_info()
