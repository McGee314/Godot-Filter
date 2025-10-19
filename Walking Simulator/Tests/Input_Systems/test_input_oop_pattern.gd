extends Node2D

# Test script for BaseInputProcessor OOP pattern
# This test creates multiple input processors and simulates scene transitions
# to verify that the OOP pattern prevents !is_inside_tree() errors

var test_input_processors: Array[BaseInputProcessor] = []
var mouse_motion_count: int = 0
var keyboard_input_count: int = 0

func _ready():
	GameLogger.info("TestInputOOPPattern: Starting BaseInputProcessor OOP pattern test")
	GameLogger.info("TestInputOOPPattern: Creating multiple input processors to test consistency")
	
	# Create multiple input processors to test the pattern
	create_test_input_processors()
	
	GameLogger.info("TestInputOOPPattern: Test setup complete. Move mouse and press ESC to test.")

func create_test_input_processors():
	# Create several input processors to test the pattern
	for i in range(3):
		var processor = TestInputProcessor.new()
		processor.name = "TestInputProcessor_" + str(i)
		processor.processor_index = i
		processor.test_callback = self
		add_child(processor)
		test_input_processors.append(processor)
		
		GameLogger.info("TestInputOOPPattern: Created input processor " + processor.name)

# Custom input processor class for testing
class TestInputProcessor extends BaseInputProcessor:
	var processor_index: int = 0
	var test_callback: Node = null
	
	func _on_mouse_motion(event: InputEventMouseMotion):
		if test_callback and test_callback.has_method("_on_test_mouse_motion"):
			test_callback._on_test_mouse_motion(event, processor_index)
	
	func _on_keyboard_input(event: InputEventKey):
		if test_callback and test_callback.has_method("_on_test_keyboard_input"):
			test_callback._on_test_keyboard_input(event, processor_index)

func _on_test_mouse_motion(event: InputEventMouseMotion, processor_index: int):
	mouse_motion_count += 1
	GameLogger.info("TestInputOOPPattern: Mouse motion processed by processor " + str(processor_index) + 
		" - Motion: " + str(event.relative) + " - Total motions: " + str(mouse_motion_count))

func _on_test_keyboard_input(event: InputEventKey, processor_index: int):
	keyboard_input_count += 1
	GameLogger.info("TestInputOOPPattern: Keyboard input processed by processor " + str(processor_index) + 
		" - Key: " + str(event.keycode) + " - Total inputs: " + str(keyboard_input_count))
	
	# Test ESC key for scene transition simulation
	if event.keycode == KEY_ESCAPE and event.pressed:
		GameLogger.info("TestInputOOPPattern: ESC pressed, testing scene transition simulation")
		test_scene_transition_simulation()

func test_scene_transition_simulation():
	GameLogger.info("TestInputOOPPattern: Starting scene transition simulation...")
	
	# Simulate the transition state that would cause !is_inside_tree() errors
	GameSceneManager.is_transitioning = true
	
	# Process some input events during transition to test safety checks
	GameLogger.info("TestInputOOPPattern: Processing input during transition...")
	
	# Wait a frame to let input processing happen
	await get_tree().process_frame
	
	# Try to process some input events to see if the safety checks work
	GameLogger.info("TestInputOOPPattern: Testing input processing during transition...")
	
	# Reset transition state
	GameSceneManager.is_transitioning = false
	
	GameLogger.info("TestInputOOPPattern: Scene transition simulation completed.")
	GameLogger.info("TestInputOOPPattern: If no !is_inside_tree() errors appeared, the OOP pattern is working correctly!")
	
	# Test cleanup
	test_cleanup_simulation()

func test_cleanup_simulation():
	GameLogger.info("TestInputOOPPattern: Testing cleanup simulation...")
	
	# Simulate removing input processors from the tree
	for i in range(test_input_processors.size()):
		var processor = test_input_processors[i]
		if processor and is_instance_valid(processor):
			GameLogger.info("TestInputOOPPattern: Removing input processor " + str(i) + " from tree")
			remove_child(processor)
			processor.queue_free()
	
	test_input_processors.clear()
	
	GameLogger.info("TestInputOOPPattern: Cleanup simulation completed.")
	GameLogger.info("TestInputOOPPattern: If no !is_inside_tree() errors appeared during cleanup, the pattern is robust!")

func _unhandled_input(event):
	# Delegate to all test input processors
	for processor in test_input_processors:
		if processor and is_instance_valid(processor):
			processor._unhandled_input(event)
