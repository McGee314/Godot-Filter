class_name CulturalFontManager
extends Node

## Font Manager for Cultural Walking Simulator
## Provides centralized font management and styling

# Font resources (loaded once)
static var header_font: FontFile
static var body_font: FontFile
static var ui_font: FontFile
static var bold_font: FontFile
static var italic_font: FontFile

# Font paths
const HEADER_FONT_PATH = "res://Assets/Fonts/Rooters.ttf"
const BODY_FONT_PATH = "res://Assets/Fonts/GentiumBookPlus-Regular.ttf"
const BODY_BOLD_FONT_PATH = "res://Assets/Fonts/GentiumBookPlus-Bold.ttf"
const BODY_ITALIC_FONT_PATH = "res://Assets/Fonts/GentiumBookPlus-Italic.ttf"
const UI_FONT_PATH = "res://Assets/Fonts/SourceSans3-VariableFont_wght.ttf"

# Color schemes
static var text_colors = {
	"default": Color(0.9, 0.9, 0.9, 1),
	"header": Color(1, 0.9, 0.7, 1),
	"cultural": Color(0.8, 0.9, 1, 1),
	"warning": Color(1, 0.8, 0.6, 1),
	"error": Color(1, 0.6, 0.6, 1),
	"success": Color(0.6, 1, 0.8, 1)
}

static func _static_init():
	"""Load fonts once at startup"""
	load_fonts()

static func load_fonts():
	"""Load all font resources"""
	GameLogger.info("🔤 Loading Cultural Game fonts...")
	
	header_font = load(HEADER_FONT_PATH)
	body_font = load(BODY_FONT_PATH)
	bold_font = load(BODY_BOLD_FONT_PATH)
	italic_font = load(BODY_ITALIC_FONT_PATH)
	ui_font = load(UI_FONT_PATH)
	
	if header_font and body_font and ui_font:
		GameLogger.info("✅ All fonts loaded successfully")
	else:
		GameLogger.error("❌ Failed to load some fonts")

## Font Application Methods

static func apply_header_style(control: Control, size: int = 24, color: String = "header"):
	"""Apply header font style (Rooters)"""
	if header_font:
		control.add_theme_font_override("font", header_font)
		control.add_theme_font_size_override("font_size", size)
		control.add_theme_color_override("font_color", text_colors[color])

static func apply_body_style(control: Control, size: int = 16, color: String = "default"):
	"""Apply body text font style (Gentium Book Plus)"""
	if body_font:
		control.add_theme_font_override("font", body_font)
		control.add_theme_font_size_override("font_size", size)
		control.add_theme_color_override("font_color", text_colors[color])

static func apply_ui_style(control: Control, size: int = 16, color: String = "default"):
	"""Apply UI font style (Source Sans 3)"""
	if ui_font:
		control.add_theme_font_override("font", ui_font)
		control.add_theme_font_size_override("font_size", size)
		control.add_theme_color_override("font_color", text_colors[color])

static func apply_bold_style(control: Control, size: int = 16, color: String = "default"):
	"""Apply bold body font style"""
	if bold_font:
		control.add_theme_font_override("font", bold_font)
		control.add_theme_font_size_override("font_size", size)
		control.add_theme_color_override("font_color", text_colors[color])

static func apply_italic_style(control: Control, size: int = 16, color: String = "default"):
	"""Apply italic body font style"""
	if italic_font:
		control.add_theme_font_override("font", italic_font)
		control.add_theme_font_size_override("font_size", size)
		control.add_theme_color_override("font_color", text_colors[color])

## Specialized Styling Methods

static func style_region_title(label: Label, region_name: String):
	"""Style region title labels"""
	apply_header_style(label, 28, "header")
	label.text = region_name.to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func style_dialogue_text(rich_text: RichTextLabel):
	"""Style dialogue text"""
	apply_body_style(rich_text, 16, "default")
	rich_text.fit_content = true

static func style_cultural_info(label: Label):
	"""Style cultural information text"""
	apply_body_style(label, 16, "cultural")

static func style_menu_button(button: Button):
	"""Style main menu buttons"""
	apply_ui_style(button, 18, "default")
	# Add hover effects
	button.add_theme_color_override("font_hover_color", text_colors["header"])

static func style_npc_name(label: Label, npc_name: String):
	"""Style NPC name labels"""
	apply_bold_style(label, 18, "header")
	label.text = npc_name

## Theme Application Methods

static func apply_cultural_theme_to_scene(scene_root: Node):
	"""Apply cultural theme to an entire scene"""
	GameLogger.info("🎨 Applying cultural theme to scene: %s" % scene_root.name)
	
	# Find and style common UI elements
	var labels = find_nodes_by_type(scene_root, Label)
	var buttons = find_nodes_by_type(scene_root, Button)
	var rich_texts = find_nodes_by_type(scene_root, RichTextLabel)
	
	# Apply default styles
	for label in labels:
		if "title" in label.name.to_lower() or "header" in label.name.to_lower():
			apply_header_style(label)
		else:
			apply_body_style(label)
	
	for button in buttons:
		style_menu_button(button)
	
	for rich_text in rich_texts:
		style_dialogue_text(rich_text)
	
	GameLogger.info("✅ Cultural theme applied to %d labels, %d buttons, %d rich texts" % [labels.size(), buttons.size(), rich_texts.size()])

static func find_nodes_by_type(root: Node, type: Variant) -> Array:
	"""Find all nodes of a specific type in a scene tree"""
	var found_nodes = []
	
	func _recursive_find(node: Node):
		if node is type:
			found_nodes.append(node)
		for child in node.get_children():
			_recursive_find(child)
	
	_recursive_find(root)
	return found_nodes

## Utility Methods

static func get_font_info() -> Dictionary:
	"""Get information about loaded fonts"""
	return {
		"header_font_loaded": header_font != null,
		"body_font_loaded": body_font != null,
		"ui_font_loaded": ui_font != null,
		"bold_font_loaded": bold_font != null,
		"italic_font_loaded": italic_font != null,
		"available_colors": text_colors.keys()
	}

static func validate_fonts() -> bool:
	"""Validate that all required fonts are loaded"""
	var missing_fonts = []
	
	if not header_font:
		missing_fonts.append("header_font")
	if not body_font:
		missing_fonts.append("body_font")
	if not ui_font:
		missing_fonts.append("ui_font")
	
	if missing_fonts.size() > 0:
		GameLogger.error("❌ Missing fonts: %s" % missing_fonts)
		return false
	
	GameLogger.info("✅ All required fonts validated")
	return true
