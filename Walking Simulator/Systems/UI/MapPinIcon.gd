extends Control
class_name MapPinIcon

# Icon types for different POIs
enum IconType {
	FOOD,           # 🍕
	CRAFT,          # 🎨
	CULTURE,        # 🏛️
	HISTORY,        # 📚
	VOLCANO,        # 🌋
	GEOLOGY,        # ⛰️
	ANCIENT,        # 🗿
	ARTIFACT,       # 💎
	VENDOR,         # 🏪
	HISTORIAN,      # 👨‍🏫
	GUIDE,          # 🧭
	PLAYER          # ▶️
}

@export var icon_type: int = 0
@export var icon_color: Color = Color.WHITE

func _draw():
	# Draw map pin shape (teardrop)
	var pin_points = PackedVector2Array([
		Vector2(12, 0),   # Top point
		Vector2(8, 8),    # Top left curve
		Vector2(4, 16),   # Left side
		Vector2(8, 20),   # Bottom left
		Vector2(16, 20),  # Bottom right
		Vector2(20, 16),  # Right side
		Vector2(16, 8),   # Top right curve
	])
	
	# Draw pin outline
	draw_colored_polygon(pin_points, Color.BLACK)
	
	# Draw pin fill
	var fill_points = PackedVector2Array([
		Vector2(12, 1),   # Top point
		Vector2(9, 8),    # Top left curve
		Vector2(5, 16),   # Left side
		Vector2(8, 19),   # Bottom left
		Vector2(16, 19),  # Bottom right
		Vector2(19, 16),  # Right side
		Vector2(16, 8),   # Top right curve
	])
	draw_colored_polygon(fill_points, icon_color)
	
	# Draw icon symbol based on type
	draw_icon_symbol()

func draw_icon_symbol():
	match icon_type:
		IconType.FOOD:
			draw_food_symbol()
		IconType.CRAFT:
			draw_craft_symbol()
		IconType.CULTURE:
			draw_culture_symbol()
		IconType.HISTORY:
			draw_history_symbol()
		IconType.VOLCANO:
			draw_volcano_symbol()
		IconType.GEOLOGY:
			draw_geology_symbol()
		IconType.ANCIENT:
			draw_ancient_symbol()
		IconType.ARTIFACT:
			draw_artifact_symbol()
		IconType.VENDOR:
			draw_vendor_symbol()
		IconType.HISTORIAN:
			draw_historian_symbol()
		IconType.GUIDE:
			draw_guide_symbol()

func draw_food_symbol():
	# Draw a simple food symbol (plate with dots)
	draw_circle(Vector2(12, 12), 3, Color.WHITE)
	draw_circle(Vector2(10, 10), 1, Color.BLACK)
	draw_circle(Vector2(14, 10), 1, Color.BLACK)
	draw_circle(Vector2(12, 14), 1, Color.BLACK)

func draw_craft_symbol():
	# Draw a paintbrush symbol
	draw_line(Vector2(8, 16), Vector2(16, 8), Color.WHITE, 2.0)
	draw_circle(Vector2(16, 8), 2, Color.WHITE)

func draw_culture_symbol():
	# Draw a building symbol
	draw_rect(Rect2(8, 8, 8, 8), Color.WHITE)
	draw_rect(Rect2(10, 10, 2, 2), Color.BLACK)  # Door
	draw_rect(Rect2(12, 10, 2, 2), Color.BLACK)  # Window

func draw_history_symbol():
	# Draw a book symbol
	draw_rect(Rect2(8, 8, 8, 6), Color.WHITE)
	draw_line(Vector2(10, 10), Vector2(14, 10), Color.BLACK, 1.0)
	draw_line(Vector2(10, 12), Vector2(14, 12), Color.BLACK, 1.0)

func draw_volcano_symbol():
	# Draw a triangle for volcano
	var points = PackedVector2Array([
		Vector2(12, 6),   # Top
		Vector2(8, 16),   # Bottom left
		Vector2(16, 16),  # Bottom right
	])
	draw_colored_polygon(points, Color.WHITE)

func draw_geology_symbol():
	# Draw a diamond shape for geology
	var points = PackedVector2Array([
		Vector2(12, 6),   # Top
		Vector2(8, 12),   # Left
		Vector2(12, 18),  # Bottom
		Vector2(16, 12),  # Right
	])
	draw_colored_polygon(points, Color.WHITE)

func draw_ancient_symbol():
	# Draw a simple monument symbol
	draw_rect(Rect2(10, 6, 4, 12), Color.WHITE)
	draw_rect(Rect2(8, 16, 8, 2), Color.WHITE)

func draw_artifact_symbol():
	# Draw a diamond for artifact
	var points = PackedVector2Array([
		Vector2(12, 6),   # Top
		Vector2(8, 12),   # Left
		Vector2(12, 18),  # Bottom
		Vector2(16, 12),  # Right
	])
	draw_colored_polygon(points, Color.WHITE)
	draw_circle(Vector2(12, 12), 1, Color.BLACK)

func draw_vendor_symbol():
	# Draw a shop symbol
	draw_rect(Rect2(8, 8, 8, 8), Color.WHITE)
	draw_line(Vector2(8, 12), Vector2(16, 12), Color.BLACK, 1.0)  # Counter
	draw_circle(Vector2(12, 10), 1, Color.BLACK)  # Vendor

func draw_historian_symbol():
	# Draw a person with book
	draw_circle(Vector2(12, 10), 2, Color.WHITE)  # Head
	draw_rect(Rect2(10, 12, 4, 4), Color.WHITE)   # Body
	draw_rect(Rect2(8, 14, 2, 2), Color.WHITE)    # Book

func draw_guide_symbol():
	# Draw a compass symbol
	draw_circle(Vector2(12, 12), 3, Color.WHITE)
	draw_line(Vector2(12, 9), Vector2(12, 15), Color.BLACK, 1.0)  # N-S
	draw_line(Vector2(9, 12), Vector2(15, 12), Color.BLACK, 1.0)  # E-W
