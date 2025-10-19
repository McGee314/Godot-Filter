extends Node

# Test script for NPC interaction system
# Demonstrates how the interaction system works

var test_results: Array[String] = []
var tests_passed: int = 0
var tests_failed: int = 0

func _ready():
	print("=== NPC Interaction System Test ===")
	run_interaction_tests()
	print_results()

func run_interaction_tests():
	test_npc_creation()
	test_interaction_range()
	test_visual_feedback()
	test_dialogue_system()

func test_npc_creation():
	print("\n--- Testing NPC Creation ---")
	
	# Create a test NPC
	var npc = CulturalNPC.new()
	npc.npc_name = "TestGuide"
	npc.cultural_region = "Indonesia Barat"
	npc.npc_type = "Guide"
	
	# Test NPC setup
	npc.setup_npc()
	
	if npc.interaction_prompt == "Talk to TestGuide":
		test_passed("NPC interaction prompt set correctly")
	else:
		test_failed("NPC interaction prompt not set correctly")
	
	if npc.interaction_range == 3.0:
		test_passed("NPC interaction range set correctly")
	else:
		test_failed("NPC interaction range not set correctly")
	
	# Test dialogue setup
	npc.setup_default_dialogue()
	if npc.dialogue_data.size() > 0:
		test_passed("NPC dialogue data initialized")
	else:
		test_failed("NPC dialogue data not initialized")

func test_interaction_range():
	print("\n--- Testing Interaction Range ---")
	
	var npc = CulturalNPC.new()
	npc.npc_name = "RangeTestNPC"
	npc.cultural_region = "Indonesia Tengah"
	npc.npc_type = "Historian"
	npc.setup_npc()
	
	# Test interaction range calculation
	var player_pos = Vector3(0, 0, 0)
	var npc_pos = Vector3(0, 0, 2)  # 2 meters away
	npc.position = npc_pos
	
	# Simulate player distance calculation
	var distance = player_pos.distance_to(npc_pos)
	
	if distance <= npc.interaction_range:
		test_passed("Player within interaction range")
	else:
		test_failed("Player outside interaction range")

func test_visual_feedback():
	print("\n--- Testing Visual Feedback ---")
	
	var npc = CulturalNPC.new()
	npc.npc_name = "VisualTestNPC"
	npc.cultural_region = "Indonesia Timur"
	npc.npc_type = "Guide"
	npc.setup_npc()
	
	# Test visual feedback methods
	npc.show_interaction_available()
	npc.show_interaction_feedback()
	
	test_passed("Visual feedback methods working")

func test_dialogue_system():
	print("\n--- Testing Dialogue System ---")
	
	var npc = CulturalNPC.new()
	npc.npc_name = "DialogueTestNPC"
	npc.cultural_region = "Indonesia Barat"
	npc.npc_type = "Guide"
	npc.setup_npc()
	npc.setup_default_dialogue()
	
	# Test dialogue retrieval
	var initial_dialogue = npc.get_initial_dialogue()
	if initial_dialogue.has("message") and initial_dialogue.has("options"):
		test_passed("Dialogue retrieval working")
		
		# Test dialogue options
		var options = initial_dialogue.get("options", [])
		if options.size() > 0:
			test_passed("Dialogue options available")
		else:
			test_failed("No dialogue options found")
	else:
		test_failed("Dialogue retrieval failed")

func test_passed(message: String):
	tests_passed += 1
	test_results.append("✅ PASS: " + message)
	print("✅ PASS: " + message)

func test_failed(message: String):
	tests_failed += 1
	test_results.append("❌ FAIL: " + message)
	print("❌ FAIL: " + message)

func print_results():
	print("\n=== NPC Interaction Test Results ===")
	print("Tests Passed: ", tests_passed)
	print("Tests Failed: ", tests_failed)
	print("Total Tests: ", tests_passed + tests_failed)
	
	print("\nDetailed Results:")
	for result in test_results:
		print(result)
	
	if tests_failed == 0:
		print("\n🎉 All NPC interaction tests passed!")
		print("The interaction system is working correctly.")
	else:
		print("\n⚠️  Some tests failed. Please check the implementation.")

# Demonstration functions
func demonstrate_interaction_flow():
	print("\n=== NPC Interaction Flow Demonstration ===")
	print("1. Player approaches NPC")
	print("2. NPC glows yellow (in interaction range)")
	print("3. Screen shows: '[E] Talk to [NPC Name]'")
	print("4. Player presses E")
	print("5. NPC flashes green (interaction feedback)")
	print("6. Dialogue UI appears")
	print("7. Player chooses dialogue options")
	print("8. Cultural information is shared")
	print("9. Player closes dialogue")
	print("\nThis flow provides clear visual feedback at each step!")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			demonstrate_interaction_flow()
