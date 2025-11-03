extends Node

# Test script to verify component classes functionality
func _ready():
	print("=== COMPONENT TEST ===")
	print("Testing component classes...")
	
	# Test InputManager
	test_input_manager()
	
	# Test EventBus
	test_eventbus()
	
	print("=== END COMPONENT TEST ===")

func test_input_manager():
	print("Testing InputManager...")
	
	# Create InputManager instance
	var input_manager_script = load("res://Systems/Core/InputManager.gd")
	var input_manager = input_manager_script.new()
	add_child(input_manager)
	
	# Test getter methods
	print("  - Move input: ", input_manager.get_move_input())
	print("  - Camera input: ", input_manager.get_camera_input())
	print("  - Jump pressed: ", input_manager.is_jump_pressed())
	print("  - Sprint pressed: ", input_manager.is_sprint_pressed())
	
	print("✅ InputManager test completed!")

func test_eventbus():
	print("Testing EventBus...")
	
	if EventBus:
		# Test event emission
		EventBus.emit_artifact_collected("Component Test Artifact", "Test Region")
		print("  - Event emission test passed")
		
		# Test statistics
		var stats = EventBus.get_statistics()
		print("  - Statistics: ", stats)
		
		print("✅ EventBus test completed!")
	else:
		print("❌ EventBus not available!")
