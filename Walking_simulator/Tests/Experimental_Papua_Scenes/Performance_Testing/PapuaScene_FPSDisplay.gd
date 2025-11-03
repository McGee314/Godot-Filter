extends Control

@onready var fps_label: Label = $FPSLabel
@onready var fps_timer: Timer = $FPSUpdateTimer

var frame_count: int = 0
var fps: float = 0.0
var fps_update_interval: float = 0.5

func _ready():
	# Connect timer signal
	fps_timer.timeout.connect(_on_fps_timer_timeout)
	
	# Set timer interval
	fps_timer.wait_time = fps_update_interval
	
	GameLogger.info("FPS Display initialized")

func _process(_delta):
	frame_count += 1

func _on_fps_timer_timeout():
	# Calculate FPS
	fps = frame_count / fps_update_interval
	
	# Update label with color coding
	var color = Color.WHITE
	if fps >= 60:
		color = Color.GREEN
	elif fps >= 30:
		color = Color.YELLOW
	else:
		color = Color.RED
	
	fps_label.text = "FPS: " + str(int(fps))
	fps_label.modulate = color
	
	# Log FPS to file for debugging
	GameLogger.debug("FPS: " + str(int(fps)) + " (Performance: " + ("Excellent" if fps >= 60 else "Good" if fps >= 30 else "Poor") + ")")
	
	# Reset frame count
	frame_count = 0
