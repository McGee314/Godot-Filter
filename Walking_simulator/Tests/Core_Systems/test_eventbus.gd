extends Node

# Test script to verify EventBus autoload functionality
func _ready():
	print("=== EVENTBUS TEST ===")
	print("Testing EventBus autoload functionality...")
	
	# Test if EventBus is available
	if EventBus:
		print("✅ EventBus autoload is working!")
		
		# Test basic event emission
		EventBus.emit_artifact_collected("Test Artifact", "Test Region")
		print("✅ Event emission test passed!")
		
		# Test event types
		print("Event types available:")
		for event_type in EventBus.EventType.values():
			print("  - ", event_type)
		
		# Test statistics
		var stats = EventBus.get_statistics()
		print("EventBus statistics: ", stats)
		
		# Test observer subscription
		EventBus.subscribe(self, _on_test_event, [EventBus.EventType.ARTIFACT_COLLECTED])
		print("✅ Observer subscription test passed!")
		
		# Test event with observer
		EventBus.emit_artifact_collected("Observer Test Artifact", "Test Region")
		
	else:
		print("❌ EventBus autoload failed!")
		push_error("EventBus not found - check autoload configuration")
	
	print("=== END EVENTBUS TEST ===")

func _on_test_event(event):
	print("✅ Observer callback received event: ", event.data)
