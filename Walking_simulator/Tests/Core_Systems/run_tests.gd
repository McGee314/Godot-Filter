extends Node

# Simple test runner for our cultural systems
# This can be run from the command line or from within Godot

func _ready():
	print("Starting Cultural Systems Tests...")
	run_all_tests()

func run_all_tests():
	var test_results = []
	
	# Test Global state management
	test_results.append(test_global_basic_functionality())
	
	# Test Cultural Item system
	test_results.append(test_cultural_item_system())
	
	# Test Region data
	test_results.append(test_region_data())
	
	# Test Session progress
	test_results.append(test_session_progress())
	
	# Report results
	print("\n=== TEST RESULTS ===")
	var passed = 0
	var failed = 0
	
	for result in test_results:
		if result["passed"]:
			passed += 1
			print("✅ " + result["test_name"] + " - PASSED")
		else:
			failed += 1
			print("❌ " + result["test_name"] + " - FAILED: " + result["error"])
	
	print("\nTotal: " + str(passed + failed) + " tests")
	print("Passed: " + str(passed))
	print("Failed: " + str(failed))
	
	if failed == 0:
		print("🎉 All tests passed!")
	else:
		print("⚠️  Some tests failed. Check the errors above.")

func _get_global_singleton() -> Node:
	var tree := Engine.get_main_loop()
	if tree and tree is SceneTree:
		var root := (tree as SceneTree).root
		var node := root.get_node_or_null("Global")
		return node
	return null

func _new_global_for_test() -> Node:
	# In headless runs, autoloads should exist; if not, fallback to loading the script
	var autoload_global := _get_global_singleton()
	if autoload_global:
		return autoload_global
	var script := load("res://Global.gd")
	if script:
		return script.new()
	return null

func test_global_basic_functionality() -> Dictionary:
	var result = {"test_name": "Global Basic Functionality", "passed": false, "error": ""}
	
	var global = _new_global_for_test()
	if global == null:
		result["error"] = "Global singleton not available"
		return result
	add_child(global)
	
	# Test region session start
	global.start_region_session("Indonesia Barat")
	if global.current_region != "Indonesia Barat":
		result["error"] = "Region not set correctly"
		global.queue_free()
		return result
	
	# Test artifact collection
	global.collect_artifact("Indonesia Barat", "SotoRecipe")
	if not ("SotoRecipe" in global.collected_artifacts["Indonesia Barat"]):
		result["error"] = "Artifact not collected correctly"
		global.queue_free()
		return result
	
	result["passed"] = true
	global.queue_free()
	
	return result

func test_cultural_item_system() -> Dictionary:
	var result = {"test_name": "Cultural Item System", "passed": false, "error": ""}
	
	var item = CulturalItem.new()
	item.display_name = "Test Item"
	item.cultural_region = "Indonesia Barat"
	item.description = "Test description"
	item.educational_value = 5
	
	if item.display_name != "Test Item":
		result["error"] = "Item name not set correctly"
		return result
	
	if item.cultural_region != "Indonesia Barat":
		result["error"] = "Item region not set correctly"
		return result
	
	var info = item.get_display_info()
	if info["name"] != "Test Item":
		result["error"] = "Item display info not working"
		return result
	
	result["passed"] = true
	
	return result

func test_region_data() -> Dictionary:
	var result = {"test_name": "Region Data", "passed": false, "error": ""}
	
	var global = _new_global_for_test()
	if global == null:
		result["error"] = "Global singleton not available"
		return result
	add_child(global)
	
	# Test Indonesia Barat data
	var barat_data = global.region_data["Indonesia Barat"]
	if barat_data["title"] != "Traditional Market Cuisine":
		result["error"] = "Indonesia Barat title incorrect"
		global.queue_free()
		return result
	
	# Test Indonesia Tengah data
	var tengah_data = global.region_data["Indonesia Tengah"]
	if tengah_data["title"] != "Mount Tambora Historical Experience":
		result["error"] = "Indonesia Tengah title incorrect"
		global.queue_free()
		return result
	
	# Test Indonesia Timur data
	var timur_data = global.region_data["Indonesia Timur"]
	if timur_data["title"] != "Papua Cultural Artifact Collection":
		result["error"] = "Indonesia Timur title incorrect"
		global.queue_free()
		return result
	
	result["passed"] = true
	global.queue_free()
	
	return result

func test_session_progress() -> Dictionary:
	var result = {"test_name": "Session Progress", "passed": false, "error": ""}
	
	var global = _new_global_for_test()
	if global == null:
		result["error"] = "Global singleton not available"
		return result
	add_child(global)
	
	global.start_region_session("Indonesia Barat")
	global.current_session_time = 300.0  # 5 minutes
	
	var progress = global.get_session_progress()
	if abs(progress - 50.0) > 0.1:  # Allow small floating point differences
		result["error"] = "Progress calculation incorrect: " + str(progress)
		global.queue_free()
		return result
	
	var remaining = global.get_remaining_time()
	if abs(remaining - 300.0) > 0.1:
		result["error"] = "Remaining time calculation incorrect: " + str(remaining)
		global.queue_free()
		return result
	
	result["passed"] = true
	global.queue_free()
	
	return result
