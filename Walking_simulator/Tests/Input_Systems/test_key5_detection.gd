extends Node

## Test KEY_5 input detection in Papua Terrain3D scene
## Comprehensive debugging to understand why KEY_5 isn't working

func _ready():
	GameLogger.info("🧪 [KEY_5 Detection Test] Starting KEY_5 input detection test...", "GraphSystem")
	
	# Enable all input processing
	set_process_input(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	GameLogger.info("✅ [KEY_5 Detection Test] All input processing enabled", "GraphSystem")
	GameLogger.info("🔍 [KEY_5 Detection Test] Press KEY_5 to test detection...", "GraphSystem")

func _input(event):
	"""Monitor all input events"""
	if event is InputEventKey:
		GameLogger.debug("🎮 [KEY_5 Detection] _input() received: %s (pressed: %s, keycode: %d)" % [
			OS.get_keycode_string(event.keycode), event.pressed, event.keycode
		], "GraphSystem")
		
		if event.keycode == KEY_5 and event.pressed:
			GameLogger.info("🔑 [KEY_5 Detection] KEY_5 DETECTED in _input()!", "GraphSystem")

func _unhandled_input(event):
	"""Monitor unhandled input events"""
	if event is InputEventKey:
		GameLogger.debug("🎮 [KEY_5 Detection] _unhandled_input() received: %s (pressed: %s, keycode: %d)" % [
			OS.get_keycode_string(event.keycode), event.pressed, event.keycode
		], "GraphSystem")
		
		if event.keycode == KEY_5 and event.pressed:
			GameLogger.info("🔑 [KEY_5 Detection] KEY_5 DETECTED in _unhandled_input()!", "GraphSystem")

func _unhandled_key_input(event):
	"""Monitor unhandled key input events"""
	if event is InputEventKey:
		GameLogger.debug("🎮 [KEY_5 Detection] _unhandled_key_input() received: %s (pressed: %s, keycode: %d)" % [
			OS.get_keycode_string(event.keycode), event.pressed, event.keycode
		], "GraphSystem")
		
		if event.keycode == KEY_5 and event.pressed:
			GameLogger.info("🔑 [KEY_5 Detection] KEY_5 DETECTED in _unhandled_key_input()!", "GraphSystem")
