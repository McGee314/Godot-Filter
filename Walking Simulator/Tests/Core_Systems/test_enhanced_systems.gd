extends Node

# Test script for enhanced systems
# Tests NPC dialogue, Event Bus, and Command Manager functionality

var test_results: Array[String] = []
var tests_passed: int = 0
var tests_failed: int = 0

func _ready():
	print("=== Enhanced Systems Test Suite ===")
	run_all_tests()
	print_results()

func run_all_tests():
	test_npc_dialogue_system()
	test_event_bus_system()
	test_command_manager()
	test_integration()

func test_npc_dialogue_system():
	print("\n--- Testing NPC Dialogue System ---")
	
	# Test NPC creation and dialogue setup
	var npc = CulturalNPC.new()
	npc.npc_name = "TestGuide"
	npc.cultural_region = "Indonesia Barat"
	npc.npc_type = "Guide"
	
	# Test dialogue initialization
	npc.setup_default_dialogue()
	
	if npc.dialogue_data.size() > 0:
		test_passed("NPC dialogue data initialized")
		
		# Test dialogue retrieval
		var initial_dialogue = npc.get_initial_dialogue()
		if initial_dialogue.has("message") and initial_dialogue.has("options"):
			test_passed("Dialogue retrieval working")
		else:
			test_failed("Dialogue retrieval failed")
	else:
		test_failed("NPC dialogue data not initialized")

func test_event_bus_system():
	print("\n--- Testing Event Bus System ---")
	
	if EventBus:
		test_passed("Event Bus singleton accessible")
		
		# Test event emission
		var event_received = false
		EventBus.subscribe(self, func(event): event_received = true, [EventBus.EventType.NPC_INTERACTION])
		
		EventBus.emit_npc_interaction("TestNPC", "TestRegion")
		
		# Wait a frame for event processing
		await get_tree().process_frame
		
		if event_received:
			test_passed("Event Bus event emission and subscription working")
		else:
			test_failed("Event Bus event handling failed")
	else:
		test_failed("Event Bus singleton not accessible")

func test_command_manager():
	print("\n--- Testing Command Manager ---")
	
	var command_manager = CulturalCommandManager.new()
	add_child(command_manager)
	
	if command_manager:
		test_passed("Command Manager created")
		
		# Create a mock inventory system for testing
		var mock_inventory = create_mock_inventory()
		command_manager.set_inventory_system(mock_inventory)
		
		# Test command execution
		var test_command = CollectArtifactCommand.new("TestArtifact", "TestRegion")
		test_command.set_inventory_system(mock_inventory)
		var success = command_manager.execute_command(test_command)
		
		if success:
			test_passed("Command execution working")
			
			# Test undo functionality
			if command_manager.can_undo():
				var undo_success = command_manager.undo_command()
				if undo_success:
					test_passed("Command undo working")
				else:
					test_failed("Command undo failed")
			else:
				test_failed("No commands available for undo")
		else:
			test_failed("Command execution failed")
	else:
		test_failed("Command Manager creation failed")

# Helper function to create a mock inventory for testing
func create_mock_inventory() -> CulturalInventory:
	var mock_inventory = MockCulturalInventory.new()
	return mock_inventory

# Mock CulturalInventory class for testing
class MockCulturalInventory extends CulturalInventory:
	var mock_collected_artifacts: Dictionary = {}
	var mock_collected_count: int = 0
	
	func _ready():
		# Override _ready to avoid UI setup in tests
		pass
	
	func add_cultural_artifact(artifact: CulturalItem, region: String):
		if not mock_collected_artifacts.has(region):
			mock_collected_artifacts[region] = []
		mock_collected_artifacts[region].append(artifact.display_name)
		mock_collected_count += 1
		print("Mock inventory: Added artifact ", artifact.display_name, " to region ", region)
	
	func update_display():
		print("Mock inventory: Updated display")
	
	# Override UI-related functions to avoid errors in tests
	func toggle_window(_open: bool):
		pass
	
	func setup_inventory():
		pass
	
	func connect_signals():
		pass

func test_integration():
	print("\n--- Testing System Integration ---")
	
	# Test NPC interaction with Event Bus
	var npc = CulturalNPC.new()
	npc.npc_name = "IntegrationTestNPC"
	npc.cultural_region = "Indonesia Tengah"
	npc.npc_type = "Historian"
	
	var interaction_received = false
	
	if EventBus:
		EventBus.subscribe(self, func(event): 
			if event.data.get("npc_name") == "IntegrationTestNPC":
				interaction_received = true
		, [EventBus.EventType.NPC_INTERACTION])
		
		# Simulate NPC interaction
		npc.emit_interaction_event()
		
		# Wait a frame for event processing
		await get_tree().process_frame
		
		if interaction_received:
			test_passed("NPC-EventBus integration working")
		else:
			test_failed("NPC-EventBus integration failed")
	else:
		test_failed("Event Bus not available for integration test")

func test_passed(message: String):
	tests_passed += 1
	test_results.append("✅ PASS: " + message)
	print("✅ PASS: " + message)

func test_failed(message: String):
	tests_failed += 1
	test_results.append("❌ FAIL: " + message)
	print("❌ FAIL: " + message)

func print_results():
	print("\n=== Test Results ===")
	print("Tests Passed: ", tests_passed)
	print("Tests Failed: ", tests_failed)
	print("Total Tests: ", tests_passed + tests_failed)
	
	print("\nDetailed Results:")
	for result in test_results:
		print(result)
	
	if tests_failed == 0:
		print("\n🎉 All tests passed! Enhanced systems are working correctly.")
	else:
		print("\n⚠️  Some tests failed. Please check the implementation.")
