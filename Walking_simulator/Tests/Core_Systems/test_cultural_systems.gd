extends Node

# Test our cultural systems
# Run with: gut.gd --test-script=res://Tests/test_cultural_systems.gd

func _ready():
	run_tests()

func test_global_state_management():
	# Test Global state management (Global is an autoload)
	
	# Test region session start
	Global.start_region_session("Indonesia Barat")
	if Global.current_region != "Indonesia Barat":
		print("FAILED: Region not set correctly")
		return
	if Global.current_session_time != 0.0:
		print("FAILED: Session time not reset")
		return
	if "Indonesia Barat" not in Global.visited_regions:
		print("FAILED: Region not added to visited regions")
		return
	
	# Test artifact collection
	Global.collect_artifact("Indonesia Barat", "SotoRecipe")
	if "SotoRecipe" not in Global.collected_artifacts["Indonesia Barat"]:
		print("FAILED: Artifact not collected")
		return
	
	# Test cultural knowledge
	Global.add_cultural_knowledge("Indonesia Barat", "Traditional market culture")
	if "Traditional market culture" not in Global.cultural_knowledge["Indonesia Barat"]:
		print("FAILED: Cultural knowledge not added")
		return
	
	print("PASSED: Global state management test")

func test_cultural_item_system():
	# Test CulturalItem resource
	var item = CulturalItem.new()
	item.display_name = "Test Item"
	item.cultural_region = "Indonesia Barat"
	item.description = "Test description"
	item.educational_value = 5
	
	if item.display_name != "Test Item":
		print("FAILED: Item display name not set correctly")
		return
	if item.cultural_region != "Indonesia Barat":
		print("FAILED: Item cultural region not set correctly")
		return
	if item.educational_value != 5:
		print("FAILED: Item educational value not set correctly")
		return
	
	# Test item display info
	var info = item.get_display_info()
	if info["name"] != "Test Item":
		print("FAILED: Item display info name incorrect")
		return
	if info["region"] != "Indonesia Barat":
		print("FAILED: Item display info region incorrect")
		return
	
	print("PASSED: Cultural item system test")

func test_global_signals():
	# Test GlobalSignals (GlobalSignals is an autoload)
	
	# Test signal emission (we can't easily test signal emission in unit tests,
	# but we can test that the signals exist)
	if GlobalSignals == null:
		print("FAILED: GlobalSignals not available")
		return
	
	print("PASSED: Global signals test")

func test_region_data():
	# Test region data structure (Global is an autoload)
	
	# Test Indonesia Barat data
	var barat_data = Global.region_data["Indonesia Barat"]
	if barat_data["title"] != "Traditional Market Cuisine":
		print("FAILED: Indonesia Barat title incorrect")
		return
	if barat_data["duration"] != 600.0:
		print("FAILED: Indonesia Barat duration incorrect")
		return
	if "Soto" not in barat_data["foods"]:
		print("FAILED: Indonesia Barat foods missing Soto")
		return
	
	# Test Indonesia Tengah data
	var tengah_data = Global.region_data["Indonesia Tengah"]
	if tengah_data["title"] != "Mount Tambora Historical Experience":
		print("FAILED: Indonesia Tengah title incorrect")
		return
	if tengah_data["duration"] != 900.0:
		print("FAILED: Indonesia Tengah duration incorrect")
		return
	
	# Test Indonesia Timur data
	var timur_data = Global.region_data["Indonesia Timur"]
	if timur_data["title"] != "Papua Cultural Artifact Collection":
		print("FAILED: Indonesia Timur title incorrect")
		return
	if timur_data["duration"] != 1200.0:
		print("FAILED: Indonesia Timur duration incorrect")
		return
	
	print("PASSED: Region data test")

func test_session_progress():
	# Test session progress calculation (Global is an autoload)
	
	Global.start_region_session("Indonesia Barat")
	
	# Simulate time passing
	Global.current_session_time = 300.0  # 5 minutes
	
	var progress = Global.get_session_progress()
	if abs(progress - 50.0) > 0.1:  # Allow small floating point differences
		print("FAILED: Progress calculation incorrect: " + str(progress))
		return
	
	var remaining = Global.get_remaining_time()
	if abs(remaining - 300.0) > 0.1:
		print("FAILED: Remaining time calculation incorrect: " + str(remaining))
		return
	
	print("PASSED: Session progress test")

func test_exhibition_data_persistence():
	# Test save/load functionality (Global is an autoload)
	
	# Add some test data
	Global.start_region_session("Indonesia Barat")
	Global.collect_artifact("Indonesia Barat", "SotoRecipe")
	Global.add_cultural_knowledge("Indonesia Barat", "Test knowledge")
	
	# Save data
	Global.save_exhibition_data()
	
	# Reset data
	Global.reset_exhibition_data()
	if Global.current_region != "":
		print("FAILED: Current region not reset")
		return
	if Global.visited_regions.size() != 0:
		print("FAILED: Visited regions not reset")
		return
	if Global.collected_artifacts.size() != 0:
		print("FAILED: Collected artifacts not reset")
		return
	
	# Load data back
	Global.load_exhibition_data()
	if "Indonesia Barat" not in Global.visited_regions:
		print("FAILED: Region not loaded back")
		return
	if "SotoRecipe" not in Global.collected_artifacts["Indonesia Barat"]:
		print("FAILED: Artifact not loaded back")
		return
	if "Test knowledge" not in Global.cultural_knowledge["Indonesia Barat"]:
		print("FAILED: Knowledge not loaded back")
		return
	
	print("PASSED: Exhibition data persistence test")

# Helper function to create test cultural item
func create_test_cultural_item(name: String, region: String) -> CulturalItem:
	var item = CulturalItem.new()
	item.display_name = name
	item.cultural_region = region
	item.description = "Test description for " + name
	item.educational_value = 1
	item.rarity = "Common"
	return item

# Simple test runner
func run_tests():
	print("Running Cultural Systems Tests...")
	
	test_global_state_management()
	test_cultural_item_system()
	test_global_signals()
	test_region_data()
	test_session_progress()
	test_exhibition_data_persistence()
	
	print("All tests completed!")
