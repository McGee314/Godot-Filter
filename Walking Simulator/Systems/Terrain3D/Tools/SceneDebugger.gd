extends Node
class_name SceneDebugger

## Simple scene debugger to help diagnose Terrain3D setup issues
## Attach this script to any node to debug scene structure

@export var debug_enabled: bool = true
@export var max_depth: int = 5

func _ready():
	if debug_enabled:
		call_deferred("debug_scene_structure")

func debug_scene_structure():
	"""Debug the scene structure around this node"""
	print("============================================================")
	print("🔍 SCENE DEBUG - Terrain3D Setup Analysis")
	print("============================================================")
	
	print("📍 Current node: %s (%s)" % [get_path(), get_class()])
	print("📍 Parent: %s" % (get_parent().get_path() if get_parent() else "None"))
	print("📍 Root: %s" % get_tree().root.get_path())
	
	print("\n🌳 Scene Tree Structure (depth %d):" % max_depth)
	_print_scene_tree(get_tree().root, 0)
	
	print("\n🔍 Looking for Terrain3D nodes...")
	_find_terrain3d_nodes(get_tree().root)
	
	print("\n🔍 Looking for TerrainController nodes...")
	_find_terrain_controller_nodes(get_tree().root)
	
	print("============================================================")

func _print_scene_tree(node: Node, depth: int):
	"""Print scene tree structure"""
	if depth > max_depth:
		return
	
	var indent = ""
	for i in range(depth):
		indent += "  "
	
	var node_info = "%s%s (%s)" % [indent, node.name, node.get_class()]
	
	# Highlight important nodes
	if node.name.to_lower().contains("terrain"):
		node_info += " ⭐ TERRAIN"
	if node.name.to_lower().contains("player"):
		node_info += " 👤 PLAYER"
	if node.name.to_lower().contains("camera"):
		node_info += " 📹 CAMERA"
	
	print(node_info)
	
	for child in node.get_children():
		_print_scene_tree(child, depth + 1)

func _find_terrain3d_nodes(node: Node):
	"""Find all Terrain3D nodes in the scene"""
	if node.get_class() == "Terrain3D":
		print("✅ Found Terrain3D: %s" % node.get_path())
		print("   - Data Directory: %s" % node.get("data_directory"))
		print("   - Has Material: %s" % (node.get("material") != null))
		print("   - Has Assets: %s" % (node.get("assets") != null))
		print("   - Top Level: %s" % node.get("top_level"))
	
	for child in node.get_children():
		_find_terrain3d_nodes(child)

func _find_terrain_controller_nodes(node: Node):
	"""Find all TerrainController nodes in the scene"""
	if node.get_class() == "Terrain3DController" or node.name.to_lower().contains("terraincontroller"):
		print("✅ Found TerrainController: %s" % node.get_path())
		print("   - Script: %s" % (node.get_script().get_path() if node.get_script() else "None"))
		
		# Check if it has terrain_controller variable
		if node.has_method("get") and node.get("terrain_controller"):
			var tc = node.get("terrain_controller")
			print("   - Has terrain_controller: %s" % tc.get_class())
		else:
			print("   - No terrain_controller found")
	
	for child in node.get_children():
		_find_terrain_controller_nodes(child)

# Input handler for manual debugging
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F9:
			print("\n🔍 Manual Scene Debug Triggered")
			debug_scene_structure()
