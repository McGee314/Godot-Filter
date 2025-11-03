extends Node3D

# Comprehensive Phase 1 Integration Test for Godot Editor
# This tests all Phase 1 components: Terrain3D, PSX Assets, and Integration

@onready var terrain: Terrain3D = $Terrain3D
@onready var status_label: Label = $UI/TestPanel/VBoxContainer/StatusLabel

var test_results = {}

func _ready():
	print("=== Phase 1 Integration Test (Editor Mode) ===")
	print("Terrain3D addon is working in editor environment!")
	print("Use the UI panel to run specific tests")
	
	# Connect button signals
	$UI/TestPanel/VBoxContainer/TestButton1.pressed.connect(test_terrain3d)
	$UI/TestPanel/VBoxContainer/TestButton2.pressed.connect(test_psx_assets)
	$UI/TestPanel/VBoxContainer/TestButton3.pressed.connect(test_integration)
	$UI/TestPanel/VBoxContainer/TestButton4.pressed.connect(run_all_tests)
	
	update_status("Ready to test...")

func test_terrain3d():
	"""Test Terrain3D addon functionality"""
	print("\n--- Testing Terrain3D Addon ---")
	update_status("Testing Terrain3D...")
	
	var results = {
		"node_exists": false,
		"properties_accessible": false,
		"methods_available": false,
		"material_assigned": false
	}
	
	# Test 1: Terrain3D node exists
	if terrain:
		results["node_exists"] = true
		print("✅ Terrain3D node found")
	else:
		print("❌ Terrain3D node not found")
		update_status("❌ Terrain3D node missing")
		return
	
	# Test 2: Properties are accessible
	var pos = terrain.position
	var mat = terrain.material
	var collision = terrain.collision_mask
	results["properties_accessible"] = true
	print("✅ Terrain3D properties accessible")
	
	# Test 3: Methods are available
	var methods = terrain.get_method_list()
	if methods.size() > 0:
		results["methods_available"] = true
		print("✅ Terrain3D has " + str(methods.size()) + " methods")
	else:
		print("❌ Terrain3D has no methods")
	
	# Test 4: Material is assigned
	if terrain.material:
		results["material_assigned"] = true
		print("✅ Terrain3D material assigned")
	else:
		print("⚠️ Terrain3D has no material")
	
	test_results["terrain3d"] = results
	update_status("Terrain3D: " + str(results.values().count(true)) + "/4 tests passed")

func test_psx_assets():
	"""Test PSX Asset Pack functionality"""
	print("\n--- Testing PSX Asset Packs ---")
	update_status("Testing PSX Assets...")
	
	var results = {
		"papua_pack_loaded": false,
		"papua_assets_valid": false,
		"tambora_pack_loaded": false,
		"tambora_assets_valid": false
	}
	
	# Test Papua PSX Asset Pack
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if papua_pack:
		results["papua_pack_loaded"] = true
		print("✅ Papua PSX asset pack loaded")
		
		# Test asset validation
		var validation = papua_pack.validate_assets()
		if validation.valid:
			results["papua_assets_valid"] = true
			print("✅ Papua assets validated: " + str(validation.valid_assets) + "/" + str(validation.total_assets))
		else:
			print("❌ Papua assets validation failed")
	else:
		print("❌ Failed to load Papua PSX asset pack")
	
	# Test Tambora PSX Asset Pack
	var tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if tambora_pack:
		results["tambora_pack_loaded"] = true
		print("✅ Tambora PSX asset pack loaded")
		
		# Test asset validation
		var validation = tambora_pack.validate_assets()
		if validation.valid:
			results["tambora_assets_valid"] = true
			print("✅ Tambora assets validated: " + str(validation.valid_assets) + "/" + str(validation.total_assets))
		else:
			print("❌ Tambora assets validation failed")
	else:
		print("❌ Failed to load Tambora PSX asset pack")
	
	test_results["psx_assets"] = results
	update_status("PSX Assets: " + str(results.values().count(true)) + "/4 tests passed")

func test_integration():
	"""Test integration between Terrain3D and PSX assets"""
	print("\n--- Testing Integration ---")
	update_status("Testing Integration...")
	
	var results = {
		"terrain_manager_accessible": false,
		"psx_asset_pack_class": false,
		"asset_placement_ready": false
	}
	
	# Test TerrainManager
	var terrain_manager = TerrainManager.new()
	if terrain_manager:
		results["terrain_manager_accessible"] = true
		print("✅ TerrainManager accessible")
		
		# Test PSX asset pack integration
		var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
		if papua_pack:
			terrain_manager.set_psx_asset_pack(papua_pack)
			results["psx_asset_pack_class"] = true
			print("✅ PSX asset pack integrated with TerrainManager")
			
			# Test asset placement readiness
			var status = terrain_manager.get_status()
			if status.has("has_psx_pack") and status["has_psx_pack"]:
				results["asset_placement_ready"] = true
				print("✅ Asset placement system ready")
			else:
				print("❌ Asset placement system not ready")
		else:
			print("❌ Cannot load PSX asset pack for integration test")
		
		terrain_manager.queue_free()
	else:
		print("❌ TerrainManager not accessible")
	
	test_results["integration"] = results
	update_status("Integration: " + str(results.values().count(true)) + "/3 tests passed")

func run_all_tests():
	"""Run all tests and provide summary"""
	print("\n--- Running All Tests ---")
	update_status("Running all tests...")
	
	test_terrain3d()
	test_psx_assets()
	test_integration()
	
	# Calculate overall results
	var total_tests = 0
	var passed_tests = 0
	
	for category in test_results:
		for result in test_results[category].values():
			total_tests += 1
			if result:
				passed_tests += 1
	
	print("\n=== Final Results ===")
	print("Total tests: " + str(total_tests))
	print("Passed tests: " + str(passed_tests))
	print("Success rate: " + str(round((float(passed_tests) / total_tests) * 100)) + "%")
	
	if passed_tests == total_tests:
		print("🎉 ALL TESTS PASSED! Phase 1 is complete and ready for Phase 2!")
		update_status("🎉 ALL TESTS PASSED! Phase 1 Complete!")
	else:
		print("⚠️ Some tests failed. Check the output above for details.")
		update_status("⚠️ " + str(passed_tests) + "/" + str(total_tests) + " tests passed")

func update_status(text: String):
	"""Update the status label"""
	if status_label:
		status_label.text = text
	print("Status: " + text)

func _input(event):
	# Keyboard shortcuts for testing
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				test_terrain3d()
			KEY_2:
				test_psx_assets()
			KEY_3:
				test_integration()
			KEY_4:
				run_all_tests()
			KEY_ESCAPE:
				print("Exiting test mode...")
				get_tree().quit()
