extends Node3D

# Test script for Tambora Hiking Trail
# Validates trail generation, asset placement, and position management

var tambora_trail: TamboraHikingTrail
var test_results: Dictionary = {}

func _ready():
	print("=== Tambora Hiking Trail Test ===")
	print("🔍 Scene name: " + get_tree().current_scene.name)
	print("🔍 Script is running!")
	
	# Check if camera is current
	var camera = get_node_or_null("TestCamera")
	if camera:
		print("📷 Camera found: " + str(camera.get_path()))
		print("📷 Camera current: " + str(camera.current))
		if not camera.current:
			print("⚠️ Camera is not current! Setting it as current...")
			camera.current = true
	else:
		print("❌ Camera not found!")
	
	# Test lighting and visibility with a simple cube
	test_lighting_with_cube()
	
	# Get reference to the trail
	tambora_trail = get_node("TamboraTrail/TamboraHikingTrail")
	if not tambora_trail:
		print("❌ Tambora trail not found")
		return
	
	print("✅ Found Tambora trail: " + str(tambora_trail.get_path()))
	
	# Create missing asset_placer node if it doesn't exist
	var asset_placer = tambora_trail.get_node_or_null("ProceduralAssets")
	if not asset_placer:
		print("⚠️ Asset placer not found, using ensure_asset_placer_exists...")
		asset_placer = tambora_trail.ensure_asset_placer_exists()
		print("✅ Created ProceduralAssetPlacer node via ensure method")
	else:
		print("✅ Found existing ProceduralAssetPlacer")
	
	# Hide the main scene's UI to avoid overlap
	var main_ui = get_node("TamboraTrail/UI")
	if main_ui:
		main_ui.visible = false
		print("✅ Hidden main scene UI")
	else:
		print("⚠️ Main scene UI not found (this is OK)")
	
	# Connect signals
	tambora_trail.trail_generated.connect(_on_trail_generated)
	print("✅ Connected trail signals")
	
	# Setup UI connections
	setup_ui_connections()
	
	print("✅ Test environment ready")
	update_results("✅ Test environment ready\n\n🎯 Tambora Hiking Trail Features:\n• Ground View: Immersive hiking experience\n• Trail Visualization: 6 checkpoints with connecting lines\n• Camera Views: Ground, Close, and Wide\n• Keyboard Shortcuts: 1=Ground, 2=Wide, 3=Close, C=Clear Trail, X=Clear All")
	print("🎯 Try clicking the buttons now!")

func test_lighting_with_cube():
	"""Test if lighting is working by placing a visible test cube"""
	print("🧪 Testing lighting with a test cube...")
	
	# Create a ground plane to help visualize the terrain
	var ground_plane = CSGBox3D.new()
	ground_plane.size = Vector3(1000, 1, 1000)
	ground_plane.position = Vector3(0, -0.5, 0)  # Slightly below ground level
	ground_plane.material = StandardMaterial3D.new()
	ground_plane.material.albedo_color = Color(0.3, 0.5, 0.3, 1)  # Dark green
	ground_plane.name = "GroundPlane"
	
	add_child(ground_plane)
	print("✅ Added ground plane for better terrain visualization")
	
	# Create a simple test cube at ground level to verify lighting works
	var ground_cube = CSGBox3D.new()
	ground_cube.size = Vector3(20, 20, 20)
	ground_cube.position = Vector3(0, 0, 0)  # At ground level
	ground_cube.material = StandardMaterial3D.new()
	ground_cube.material.albedo_color = Color.GREEN
	ground_cube.name = "GroundTestCube"
	
	add_child(ground_cube)
	print("✅ Added ground test cube at (0, 0, 0) - should be visible if lighting works")
	
	# Create a simple test cube to verify lighting works
	var test_cube = CSGBox3D.new()
	test_cube.size = Vector3(10, 10, 10)
	test_cube.position = Vector3(0, 690, 0)  # At trail start elevation
	test_cube.material = StandardMaterial3D.new()
	test_cube.material.albedo_color = Color.RED
	test_cube.name = "TestCube"
	
	add_child(test_cube)
	print("✅ Added test cube at (0, 690, 0) - should be visible if lighting works")
	
	# Also add a cube at the summit to test high elevation visibility
	var summit_cube = CSGBox3D.new()
	summit_cube.size = Vector3(10, 10, 10)
	summit_cube.position = Vector3(0, 2722, 0)  # At trail summit elevation
	summit_cube.material = StandardMaterial3D.new()
	summit_cube.material.albedo_color = Color.BLUE
	summit_cube.name = "SummitTestCube"
	
	add_child(summit_cube)
	print("✅ Added summit test cube at (0, 2722, 0) - should be visible in wide view")
	
	# Add trail path visualization
	create_trail_visualization()

func create_trail_visualization():
	"""Create visual markers to show the hiking trail path with checkpoints"""
	print("🎯 Creating detailed hiking trail visualization...")
	
	# Define trail checkpoints based on real Tambora hiking data
	var trail_checkpoints = [
		{"name": "Start", "pos": Vector3(0, 690, 0), "color": Color.YELLOW, "description": "Jungle Base (690m)"},
		{"name": "Pos1", "pos": Vector3(1200, 1077, 0), "color": Color.GREEN, "description": "Forest Mid (1077m)"},
		{"name": "Pos2", "pos": Vector3(2400, 1366, 0), "color": Color.BLUE, "description": "Forest High (1366m)"},
		{"name": "Pos3", "pos": Vector3(3200, 1600, 0), "color": Color.CYAN, "description": "Stream Area (1600m)"},
		{"name": "Pos4", "pos": Vector3(4000, 2000, 0), "color": Color.MAGENTA, "description": "Volcanic Mid (2000m)"},
		{"name": "Summit", "pos": Vector3(5000, 2722, 0), "color": Color.ORANGE, "description": "Volcanic Summit (2722m)"}
	]
	
	# Create checkpoint markers
	for i in range(trail_checkpoints.size()):
		var checkpoint = trail_checkpoints[i]
		var marker = CSGBox3D.new()
		marker.size = Vector3(8, 8, 8)
		marker.position = checkpoint.pos
		marker.material = StandardMaterial3D.new()
		marker.material.albedo_color = checkpoint.color
		marker.name = "Checkpoint_" + checkpoint.name
		
		add_child(marker)
		print("✅ Added checkpoint %s (%s) at %s" % [checkpoint.name, checkpoint.description, checkpoint.pos])
	
	# Create connecting trail lines between checkpoints
	for i in range(trail_checkpoints.size() - 1):
		var start_point = trail_checkpoints[i].pos
		var end_point = trail_checkpoints[i + 1].pos
		var distance = start_point.distance_to(end_point)
		var direction = (end_point - start_point).normalized()
		var center = (start_point + end_point) / 2
		
		# Create trail segment line
		var trail_segment = CSGBox3D.new()
		trail_segment.size = Vector3(1, 1, distance)
		trail_segment.position = center
		
		# Orient the line to connect the checkpoints
		trail_segment.look_at_from_position(center, end_point, Vector3.UP)
		
		trail_segment.material = StandardMaterial3D.new()
		trail_segment.material.albedo_color = Color.WHITE
		trail_segment.material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		trail_segment.material.albedo_color.a = 0.4
		trail_segment.name = "TrailSegment_" + str(i)
		
		add_child(trail_segment)
		print("✅ Added trail segment %d connecting %s to %s" % [i, trail_checkpoints[i].name, trail_checkpoints[i + 1].name])
	
	# Create trail info panel
	create_trail_info_panel()
	
	print("✅ Created detailed hiking trail visualization with %d checkpoints" % trail_checkpoints.size())

func create_trail_info_panel():
	"""Create an informational panel showing trail details"""
	print("📋 Creating trail info panel...")
	
	# Create a 3D text panel (simplified as a colored box with info)
	var info_panel = CSGBox3D.new()
	info_panel.size = Vector3(15, 15, 15)
	info_panel.position = Vector3(2500, 1500, 100)  # Near middle of trail
	info_panel.material = StandardMaterial3D.new()
	info_panel.material.albedo_color = Color(0.2, 0.8, 0.2, 0.8)  # Semi-transparent green
	info_panel.name = "TrailInfoPanel"
	
	add_child(info_panel)
	print("✅ Added trail info panel at middle of trail")

func setup_ui_connections():
	"""Connect UI buttons to test functions"""
	print("🔍 Setting up UI connections...")
	
	# Debug: Check if we can find the UI at all
	var ui_root = get_node_or_null("UI")
	if not ui_root:
		print("❌ UI root not found")
		return
	
	print("✅ UI root found: " + str(ui_root.get_path()))
	
	# Debug: Check TestPanel
	var test_panel = ui_root.get_node_or_null("TestPanel")
	if not test_panel:
		print("❌ TestPanel not found")
		var children_names = []
		for child in ui_root.get_children():
			children_names.append(child.name)
		print("📁 Available children in UI: " + str(children_names))
		return
	
	print("✅ TestPanel found: " + str(test_panel.get_path()))
	
	# Debug: Check VBoxContainer
	var ui = test_panel.get_node_or_null("VBoxContainer")
	if not ui:
		print("❌ VBoxContainer not found")
		var panel_children = []
		for child in test_panel.get_children():
			panel_children.append(child.name)
		print("📁 Available children in TestPanel: " + str(panel_children))
		return
	
	print("✅ VBoxContainer found: " + str(ui.get_path()))
	var vbox_children = []
	for child in ui.get_children():
		vbox_children.append(child.name)
	print("📁 Available children in VBoxContainer: " + str(vbox_children))
	
	# Get buttons with error checking
	var test_trail_btn = ui.get_node_or_null("Button")
	var test_assets_btn = ui.get_node_or_null("Button2")
	var test_positions_btn = ui.get_node_or_null("Button3")
	var show_stats_btn = ui.get_node_or_null("Button4")
	var debug_btn = ui.get_node_or_null("Button5")
	var close_view_btn = ui.get_node_or_null("Button6")
	var wide_view_btn = ui.get_node_or_null("Button7")
	var test_psx_btn = ui.get_node_or_null("Button8")
	var test_advanced_placement_btn = ui.get_node_or_null("Button9")
	var clear_trail_btn = ui.get_node_or_null("Button10")
	var clear_all_btn = ui.get_node_or_null("Button11")
	
	# Connect buttons with validation
	print("🔗 Connecting buttons...")
	
	if test_trail_btn:
		print("✅ Found trail generation button: " + str(test_trail_btn.get_path()))
		test_trail_btn.pressed.connect(_on_test_trail_generation)
		print("✅ Connected trail generation button signal")
	else:
		print("❌ Trail generation button not found")
		var button_children = []
		for child in ui.get_children():
			button_children.append(child.name)
		print("🔍 Looking for 'Button' in children: " + str(button_children))
	
	if test_assets_btn:
		print("✅ Found asset placement button: " + str(test_assets_btn.get_path()))
		test_assets_btn.pressed.connect(_on_test_asset_placement)
		print("✅ Connected asset placement button signal")
	else:
		print("❌ Asset placement button not found")
		var button2_children = []
		for child in ui.get_children():
			button2_children.append(child.name)
		print("🔍 Looking for 'Button2' in children: " + str(button2_children))
	
	if test_positions_btn:
		print("✅ Found position activation button: " + str(test_positions_btn.get_path()))
		test_positions_btn.pressed.connect(_on_test_position_activation)
		print("✅ Connected position activation button signal")
	else:
		print("❌ Position activation button not found")
		var button3_children = []
		for child in ui.get_children():
			button3_children.append(child.name)
		print("🔍 Looking for 'Button3' in children: " + str(button3_children))
	
	if show_stats_btn:
		print("✅ Found asset statistics button: " + str(show_stats_btn.get_path()))
		show_stats_btn.pressed.connect(_on_show_asset_statistics)
		print("✅ Connected asset statistics button signal")
	else:
		print("❌ Asset statistics button not found")
		var button4_children = []
		for child in ui.get_children():
			button4_children.append(child.name)
		print("🔍 Looking for 'Button4' in children: " + str(button4_children))
	
	if debug_btn:
		print("✅ Found debug button: " + str(debug_btn.get_path()))
		debug_btn.pressed.connect(debug_button_test)
		print("✅ Connected debug button signal")
	else:
		print("❌ Debug button not found")
		var button5_children = []
		for child in ui.get_children():
			button5_children.append(child.name)
		print("🔍 Looking for 'Button5' in children: " + str(button5_children))
	
	if close_view_btn:
		print("✅ Found ground view button: " + str(close_view_btn.get_path()))
		close_view_btn.pressed.connect(_on_ground_view)
		print("✅ Connected ground view button signal")
	else:
		print("❌ Ground view button not found")
	
	if wide_view_btn:
		print("✅ Found wide view button: " + str(wide_view_btn.get_path()))
		wide_view_btn.pressed.connect(_on_wide_view)
		print("✅ Connected wide view button signal")
	else:
		print("❌ Wide view button not found")
	
	if test_psx_btn:
		print("✅ Found test PSX asset button: " + str(test_psx_btn.get_path()))
		test_psx_btn.pressed.connect(_on_test_psx_asset)
		print("✅ Connected test PSX asset button signal")
	else:
		print("❌ Test PSX asset button not found")
	
	if test_advanced_placement_btn:
		print("✅ Found advanced placement button: " + str(test_advanced_placement_btn.get_path()))
		test_advanced_placement_btn.pressed.connect(test_advanced_placement_algorithms)
		print("✅ Connected advanced placement button signal")
	else:
		print("❌ Advanced placement button not found")
		var button9_children = []
		for child in ui.get_children():
			button9_children.append(child.name)
		print("🔍 Looking for 'Button9' in children: " + str(button9_children))
	
	if clear_trail_btn:
		print("✅ Found clear trail button: " + str(clear_trail_btn.get_path()))
		clear_trail_btn.pressed.connect(clear_trail_visualization)
		print("✅ Connected clear trail button signal")
	else:
		print("❌ Clear trail button not found")
	
	if clear_all_btn:
		print("✅ Found clear all button: " + str(clear_all_btn.get_path()))
		clear_all_btn.pressed.connect(clear_all_test_elements)
		print("✅ Connected clear all button signal")
	else:
		print("❌ Clear all button not found")
	
	# Test button connections
	print("🧪 Testing button connections...")
	if test_trail_btn:
		print("✅ Trail button found and connected")
		print("🔍 Button properties:")
		print("   - Visible: %s" % test_trail_btn.visible)
		print("   - Disabled: %s" % test_trail_btn.disabled)
		print("   - Text: %s" % test_trail_btn.text)
		# Test the connection by calling the function directly
		print("🧪 Calling function directly to test...")
		_on_test_trail_generation()
	else:
		print("❌ Trail button not found")
	
	# Final verification
	print("🔧 Running final debug test...")
	debug_button_test()

func _on_test_trail_generation():
	"""Test trail generation functionality"""
	print("🎯 BUTTON CLICKED: Test Trail Generation")
	print("Testing trail generation...")
	
	if not tambora_trail:
		update_results("❌ Trail not found")
		return
	
	# Test trail generation
	tambora_trail.generate_trail_path()
	
	# Check if trail path was generated
	if tambora_trail.trail_path.size() > 0:
		test_results["trail_generation"] = true
		update_results("✅ Trail generated with %d points" % tambora_trail.trail_path.size())
	else:
		test_results["trail_generation"] = false
		update_results("❌ Trail generation failed")

func _on_test_asset_placement():
	"""Test asset placement functionality"""
	print("🎯 BUTTON CLICKED: Test Asset Placement")
	print("Testing asset placement...")
	
	if not tambora_trail:
		update_results("❌ Trail not found")
		return
	
	# Test asset placement
	tambora_trail.place_assets_along_trail()
	
	# Check if assets were placed
	var asset_placer = tambora_trail.get_node("ProceduralAssets")
	if asset_placer and asset_placer.get_asset_count() > 0:
		test_results["asset_placement"] = true
		update_results("✅ Assets placed: %d total" % asset_placer.get_asset_count())
	else:
		test_results["asset_placement"] = false
		update_results("❌ Asset placement failed")

func _on_test_position_activation():
	"""Test position activation functionality"""
	print("🎯 BUTTON CLICKED: Test Position Activation")
	print("Testing position activation...")
	
	if not tambora_trail:
		update_results("❌ Trail not found")
		return
	
	# Get trail positions
	var positions = tambora_trail.get_node("TrailPositions")
	if not positions:
		update_results("❌ Trail positions not found")
		return
	
	# Test activating each position
	var activated_count = 0
	for position in positions.get_children():
		if position.has_method("activate_position"):
			position.activate_position()
			activated_count += 1
	
	if activated_count > 0:
		test_results["position_activation"] = true
		update_results("✅ Activated %d positions" % activated_count)
	else:
		test_results["position_activation"] = false
		update_results("❌ Position activation failed")

func _on_show_asset_statistics():
	"""Show detailed asset statistics"""
	print("🎯 BUTTON CLICKED: Show Asset Statistics")
	print("Showing asset statistics...")
	
	if not tambora_trail:
		update_results("❌ Trail not found")
		return
	
	var asset_placer = tambora_trail.get_node("ProceduralAssets")
	if not asset_placer:
		update_results("❌ Asset placer not found")
		return
	
	var stats = asset_placer.get_asset_count_by_type()
	var total_assets = asset_placer.get_asset_count()
	
	var stats_text = "📊 Asset Statistics:\n"
	stats_text += "Total: %d\n" % total_assets
	stats_text += "Trees: %d\n" % stats.trees
	stats_text += "Vegetation: %d\n" % stats.vegetation
	stats_text += "Stones: %d\n" % stats.stones
	stats_text += "Debris: %d\n" % stats.debris
	stats_text += "Mushrooms: %d" % stats.mushrooms
	
	update_results(stats_text)

func _on_trail_generated():
	"""Callback when trail is generated"""
	print("Trail generation completed")

func _on_asset_placed(asset_type: String, position: Vector3):
	"""Callback when an asset is placed"""
	print("Asset placed: " + asset_type + " at " + str(position))

func update_results(text: String):
	"""Update the results display"""
	var results_label = get_node_or_null("UI/TestPanel/VBoxContainer/ResultsLabel")
	if results_label:
		results_label.text = text
		print("📝 Updated results display")
	else:
		print("❌ Results label not found - cannot update display")
	print(text)

func get_test_summary() -> Dictionary:
	"""Get summary of test results"""
	return {
		"trail_generation": test_results.get("trail_generation", false),
		"asset_placement": test_results.get("asset_placement", false),
		"position_activation": test_results.get("position_activation", false),
		"total_tests": test_results.size()
	}

func debug_button_test():
	"""Debug function to test button functionality manually"""
	print("🔧 MANUAL DEBUG: Testing button functionality")
	
	# Try to find and test each button
	var ui_root = get_node_or_null("UI")
	if not ui_root:
		print("❌ UI root not found in debug test")
		return
	
	var test_panel = ui_root.get_node_or_null("TestPanel")
	if not test_panel:
		print("❌ TestPanel not found in debug test")
		return
	
	var vbox = test_panel.get_node_or_null("VBoxContainer")
	if not vbox:
		print("❌ VBoxContainer not found in debug test")
		return
	
	print("✅ Found UI structure, testing buttons...")
	
	# Test each button
	var buttons = ["Button", "Button2", "Button3", "Button4"]
	for button_name in buttons:
		var button = vbox.get_node_or_null(button_name)
		if button:
			print("✅ Found " + button_name + ": " + str(button.text))
			print("   - Visible: %s" % button.visible)
			print("   - Disabled: %s" % button.disabled)
		else:
			print("❌ %s not found" % button_name)
	
	# Test camera position
	var camera = get_node_or_null("TestCamera")
	if camera:
		print("📷 Camera position: " + str(camera.global_position))
		print("📷 Camera rotation: " + str(camera.global_rotation))
	else:
		print("❌ Camera not found")
	
	# Test trail position and asset placement
	var trail = get_node_or_null("TamboraTrail/TamboraHikingTrail")
	if trail:
		print("🏔️ Trail position: " + str(trail.global_position))
		print("🏔️ Trail children count: " + str(trail.get_child_count()))
		
		# Check ProceduralAssets
		var asset_placer = trail.get_node_or_null("ProceduralAssets")
		if asset_placer:
			print("🎯 Asset placer found, children: " + str(asset_placer.get_child_count()))
			for i in range(asset_placer.get_child_count()):
				var child = asset_placer.get_child(i)
				print("   - Child " + str(i) + ": " + child.name + " at " + str(child.global_position))
				
				# Check if asset is visible
				if child is Node3D:
					print("     - Visible: " + str(child.visible))
					print("     - Scale: " + str(child.scale))
					print("     - Transform: " + str(child.global_transform))
		else:
			print("❌ Asset placer not found")
	else:
		print("❌ Trail not found")
	
	# Test direct function call
	print("🧪 Testing direct function call...")
	_on_test_trail_generation()

func _on_ground_view():
	"""Switch to ground-level camera view for hiking trail experience"""
	print("📷 BUTTON CLICKED: Ground View")
	
	var camera = get_node_or_null("TestCamera")
	if not camera:
		print("❌ Camera not found")
		update_results("❌ Camera not found")
		return
	
	# Ground view: At trail start elevation (690m) for immersive hiking experience
	camera.global_position = Vector3(50, 695, 50)
	camera.look_at(Vector3(200, 690, 0), Vector3.UP)
	
	print("📷 Camera moved to ground view")
	print("   - Position: " + str(camera.global_position))
	print("   - Looking at: (200, 690, 0) - Trail start elevation")
	
	update_results("📷 Camera: Ground View\nPosition: (50, 695, 50)\nHiking trail experience at 690m")

func _on_close_view():
	"""Switch to close-up camera view"""
	print("📷 BUTTON CLICKED: Close View")
	
	var camera = get_node_or_null("TestCamera")
	if not camera:
		print("❌ Camera not found")
		update_results("❌ Camera not found")
		return
	
	# Close view: Near the trail start at 690m elevation, looking at first few assets
	camera.global_position = Vector3(100, 750, 100)
	camera.look_at(Vector3(500, 690, 0), Vector3.UP)
	
	print("📷 Camera moved to close view")
	print("   - Position: " + str(camera.global_position))
	print("   - Looking at: (500, 690, 0) - Trail start elevation")
	
	update_results("📷 Camera: Close View\nPosition: (100, 750, 100)\nLooking at trail start (690m)")

func _on_wide_view():
	"""Switch to wide camera view to see all assets"""
	print("📷 BUTTON CLICKED: Wide View")
	
	var camera = get_node_or_null("TestCamera")
	if not camera:
		print("❌ Camera not found")
		update_results("❌ Camera not found")
		return
	
	# Wide view: High and far back to see the entire trail from 690m to 2722m
	camera.global_position = Vector3(2500, 3000, 2500)
	camera.look_at(Vector3(2500, 1700, 0), Vector3.UP)
	
	print("📷 Camera moved to wide view")
	print("   - Position: " + str(camera.global_position))
	print("   - Looking at: (2500, 1700, 0) - Middle of trail elevation range")
	
	# Debug: Show asset positions
	debug_asset_positions()
	
	update_results("📷 Camera: Wide View\nPosition: (2500, 3000, 2500)\nCan see entire trail (690m-2722m)")

func debug_asset_positions():
	"""Debug function to show where assets are actually placed"""
	print("🔍 DEBUG: Checking asset positions...")
	
	var trail = get_node_or_null("TamboraTrail/TamboraHikingTrail")
	if not trail:
		print("❌ Trail not found for debug")
		return
	
	var asset_placer = trail.get_node_or_null("ProceduralAssets")
	if not asset_placer:
		print("❌ Asset placer not found for debug")
		return
	
	var asset_count = asset_placer.get_child_count()
	print("📊 Total assets placed: " + str(asset_count))
	
	if asset_count > 0:
		print("🎯 Sample asset positions:")
		var sample_count = min(5, asset_count)
		for i in range(sample_count):
			var asset = asset_placer.get_child(i)
			if asset:
				print("   Asset " + str(i) + ": " + asset.name + " at " + str(asset.global_position))
				print("     - Visible: " + str(asset.visible))
				print("     - Scale: " + str(asset.scale))
		
		# Show elevation range
		var min_y = 9999
		var max_y = -9999
		for i in range(asset_count):
			var asset = asset_placer.get_child(i)
			if asset:
				min_y = min(min_y, asset.global_position.y)
				max_y = max(max_y, asset.global_position.y)
		
		print("📏 Asset elevation range: " + str(min_y) + " to " + str(max_y) + " meters")
	else:
		print("❌ No assets found - they may not be visible or placed correctly")

func _on_test_psx_asset():
	"""Test PSX asset loading and placement"""
	print("🧪 Testing PSX asset loading...")
	
	# Load Tambora asset pack
	var asset_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if not asset_pack:
		print("❌ Failed to load Tambora asset pack")
		return
	
	# Get tree assets
	var tree_assets = asset_pack.get_assets_by_category("trees")
	if tree_assets.size() == 0:
		print("❌ No tree assets found")
		return
	
	# Load a random tree
	var tree_path = tree_assets[randi() % tree_assets.size()]
	var tree_scene = load(tree_path)
	
	if tree_scene:
		var tree_instance = tree_scene.instantiate()
		add_child(tree_instance)
		tree_instance.position = Vector3(100, 690, 100)
		tree_instance.scale = Vector3(1.2, 1.2, 1.2)
		print("✅ Placed test PSX tree at (100, 690, 100)")
	else:
		print("❌ Failed to instantiate tree scene")

func test_advanced_placement_algorithms():
	"""Test the new advanced placement algorithms"""
	print("🎯 Testing advanced placement algorithms...")
	
	var asset_placer = get_node_or_null("TamboraTrail/ProceduralAssets")
	if not asset_placer:
		print("❌ Asset placer not found")
		return
	
	# Create test terrain profile
	var test_profile = {
		"vegetation_density": 0.7,
		"tree_types": ["pine"],
		"ground_cover": ["grass", "ferns"],
		"debris_density": 0.4,
		"rock_density": 0.5
	}
	
	var test_center = Vector3(200, 690, 200)
	var test_radius = 30.0
	
	# Test Poisson disk sampling
	print("🔬 Testing Poisson disk sampling...")
	asset_placer.place_assets_with_poisson_disk(test_center, test_radius, 8.0, test_profile)
	
	# Test noise-based placement
	print("🌊 Testing noise-based placement...")
	var noise_center = Vector3(300, 690, 200)
	asset_placer.place_assets_with_noise_field(noise_center, test_radius, test_profile, 0.02)
	
	# Test cluster placement
	print("🌳 Testing cluster placement...")
	var cluster_center = Vector3(400, 690, 200)
	asset_placer.place_assets_in_clusters(cluster_center, test_radius, test_profile, 4)
	
	# Test ecosystem-driven placement
	print("🦋 Testing ecosystem-driven placement...")
	var eco_center = Vector3(500, 690, 200)
	asset_placer.place_ecosystem_driven_assets(eco_center, test_radius, test_profile)
	
	# Test spline-based placement (create a simple path)
	print("🛤️ Testing spline-based placement...")
	var spline_points = PackedVector3Array()
	spline_points.append(Vector3(600, 690, 150))
	spline_points.append(Vector3(650, 700, 200))
	spline_points.append(Vector3(700, 710, 250))
	spline_points.append(Vector3(750, 720, 200))
	asset_placer.place_assets_along_spline(spline_points, 10.0, test_profile, 8.0)
	
	print("✅ All advanced placement algorithms tested!")

func create_algorithm_demonstration_markers():
	"""Create colored markers to show different algorithm areas"""
	print("🎨 Creating algorithm demonstration markers...")
	
	var algorithms = [
		{"name": "Poisson Disk", "center": Vector3(200, 690, 200), "color": Color.CYAN},
		{"name": "Noise Field", "center": Vector3(300, 690, 200), "color": Color.MAGENTA},
		{"name": "Cluster", "center": Vector3(400, 690, 200), "color": Color.ORANGE},
		{"name": "Ecosystem", "center": Vector3(500, 690, 200), "color": Color.LIME_GREEN},
		{"name": "Spline", "center": Vector3(675, 705, 200), "color": Color.PURPLE}
	]
	
	for algo in algorithms:
		var marker = CSGBox3D.new()
		marker.size = Vector3(3, 10, 3)
		marker.position = algo.center + Vector3(0, 5, 0)
		marker.material = StandardMaterial3D.new()
		marker.material.albedo_color = algo.color
		marker.material.emission = algo.color * 0.3
		marker.name = algo.name + "Marker"
		
		add_child(marker)
		print("✅ Added %s algorithm marker" % algo.name)

func clear_trail_visualization():
	"""Remove all trail visualization elements"""
	GameLogger.info("🧹 Clearing trail visualization...")
	
	var trail_elements: Array[Node] = []
	
	for child in get_children():
		if (child.name.begins_with("Checkpoint_") or 
			child.name.begins_with("TrailSegment_") or 
			child.name == "TrailInfoPanel"):
			trail_elements.append(child)
	
	for element in trail_elements:
		element.queue_free()
	
	GameLogger.info("✅ Cleared %d trail visualization elements" % trail_elements.size())

func clear_all_test_elements():
	"""Clear all test elements including trail visualization and debris"""
	GameLogger.info("🧹 Clearing all test elements...")
	
	var test_elements: Array[Node] = []
	
	for child in get_children():
		if (child.name.begins_with("Checkpoint_") or 
			child.name.begins_with("TrailSegment_") or 
			child.name == "TrailInfoPanel" or
			"debris" in child.name.to_lower() or
			child.name.begins_with("Test") or
			child.name == "GroundPlane"):
			test_elements.append(child)
	
	for element in test_elements:
		element.queue_free()
	
	GameLogger.info("✅ Cleared %d test elements" % test_elements.size())

func _input(event):
	"""Handle input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
			KEY_1:
				print("📷 Keyboard shortcut: Ground View")
				_on_ground_view()
			KEY_2:
				print("📷 Keyboard shortcut: Wide View")
				_on_wide_view()
			KEY_3:
				print("📷 Keyboard shortcut: Close View")
				_on_close_view()
			KEY_C:
				print("🧹 Keyboard shortcut: Clear Trail")
				clear_trail_visualization()
			KEY_X:
				print("🧹 Keyboard shortcut: Clear All")
				clear_all_test_elements()
