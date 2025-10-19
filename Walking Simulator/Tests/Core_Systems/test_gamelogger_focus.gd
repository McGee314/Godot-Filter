extends Node

## Test script to verify GameLogger focus configuration
## This script tests that only error calling classes are logged

func _ready():
	GameLogger.info("🧪 Testing GameLogger focus configuration...")
	
	# Test different categories - only errors should appear in console
	GameLogger.info("This info message should be silenced", "General")
	GameLogger.warning("This warning should be silenced", "General")
	GameLogger.debug("This debug message should be silenced", "General")
	
	# Test GraphSystem category - errors should show
	GameLogger.graph_error("🔥 TEST: GraphSystem error - SHOULD APPEAR in console")
	GameLogger.graph_warning("⚠️ TEST: GraphSystem warning - should be silenced")
	
	# Test Terrain3DController category - errors should show  
	GameLogger.terrain_error("🔥 TEST: Terrain3DController error - SHOULD APPEAR in console")
	GameLogger.terrain_warning("⚠️ TEST: Terrain3DController warning - should be silenced")
	
	# Test regular error (should always show)
	GameLogger.error("🔥 TEST: Regular error - SHOULD APPEAR in console")
	
	# Test that file logging still works for all levels
	GameLogger.info("📁 All messages should still be written to log file: %s" % GameLogger.get_log_path())
	
	print("🧪 GameLogger focus test completed - check console and log file")
	print("📁 Log file location: %s" % GameLogger.get_log_path())
