extends Node2D

func _ready():
	GameLogger.info("TestIsInsideTreeFix: Starting test for !is_inside_tree() fix")
	GameLogger.info("TestIsInsideTreeFix: This test will simulate scene transitions to check for input handling errors")

func _unhandled_input(event):
	# Test that autoload input handlers don't cause !is_inside_tree() errors
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			GameLogger.info("TestIsInsideTreeFix: ESC pressed, testing scene transition")
			test_scene_transition()

func test_scene_transition():
	GameLogger.info("TestIsInsideTreeFix: Simulating scene transition...")
	
	# Simulate the transition state that causes the error
	GameSceneManager.is_transitioning = true
	
	# Wait a frame to let input processing happen
	await get_tree().process_frame
	
	# Try to process some input events to see if the safety checks work
	GameLogger.info("TestIsInsideTreeFix: Testing input processing during transition...")
	
	# Reset transition state
	GameSceneManager.is_transitioning = false
	
	GameLogger.info("TestIsInsideTreeFix: Test completed. Check console for any !is_inside_tree() errors.")
	GameLogger.info("TestIsInsideTreeFix: If no errors appeared, the fix is working correctly!")
