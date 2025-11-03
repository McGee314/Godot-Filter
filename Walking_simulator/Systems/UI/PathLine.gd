extends Control
class_name PathLine

@export var start_point: Vector2 = Vector2.ZERO
@export var end_point: Vector2 = Vector2.ZERO
@export var line_color: Color = Color.GRAY
@export var line_width: float = 2.0

func _draw():
	draw_line(start_point, end_point, line_color, line_width)
