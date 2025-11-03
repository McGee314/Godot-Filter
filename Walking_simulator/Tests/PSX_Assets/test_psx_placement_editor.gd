extends Node3D

# PSX Asset Placement Test for Godot Editor
# This tests placing PSX assets on the terrain

@onready var psx_assets_node: Node3D = $PSXAssets
@onready var status_label: Label = $UI/ControlPanel/VBoxContainer/StatusLabel

var papua_pack: PSXAssetPack
var tambora_pack: PSXAssetPack
var current_pack: PSXAssetPack

func _ready():
	print("=== PSX Asset Placement Test (Editor Mode) ===")
	
	# Connect button signals
	$UI/ControlPanel/VBoxContainer/PlaceTreeButton.pressed.connect(place_random_tree)
	$UI/ControlPanel/VBoxContainer/PlaceStoneButton.pressed.connect(place_random_stone)
	$UI/ControlPanel/VBoxContainer/PlaceVegetationButton.pressed.connect(place_random_vegetation)
	$UI/ControlPanel/VBoxContainer/ClearButton.pressed.connect(clear_all_assets)
	
	# Load PSX asset packs
	load_psx_asset_packs()
	
	update_status("Ready to place PSX assets...")

func load_psx_asset_packs():
	"""Load PSX asset packs"""
	print("Loading PSX asset packs...")
	
	# Load Papua pack
	papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if papua_pack:
		print("✅ Papua PSX asset pack loaded")
		current_pack = papua_pack  # Default to Papua
	else:
		print("❌ Failed to load Papua PSX asset pack")
	
	# Load Tambora pack
	tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if tambora_pack:
		print("✅ Tambora PSX asset pack loaded")
	else:
		print("❌ Failed to load Tambora PSX asset pack")

func place_random_tree():
	"""Place a random tree asset"""
	if not current_pack:
		update_status("❌ No PSX asset pack loaded")
		return
	
	var tree_asset = current_pack.get_random_asset("trees")
	if tree_asset:
		place_asset(tree_asset, "Tree")
		update_status("✅ Placed random tree: " + tree_asset.get_file())
	else:
		update_status("❌ No tree assets available")

func place_random_stone():
	"""Place a random stone asset"""
	if not current_pack:
		update_status("❌ No PSX asset pack loaded")
		return
	
	var stone_asset = current_pack.get_random_asset("stones")
	if stone_asset:
		place_asset(stone_asset, "Stone")
		update_status("✅ Placed random stone: " + stone_asset.get_file())
	else:
		update_status("❌ No stone assets available")

func place_random_vegetation():
	"""Place a random vegetation asset"""
	if not current_pack:
		update_status("❌ No PSX asset pack loaded")
		return
	
	var vegetation_asset = current_pack.get_random_asset("vegetation")
	if vegetation_asset:
		place_asset(vegetation_asset, "Vegetation")
		update_status("✅ Placed random vegetation: " + vegetation_asset.get_file())
	else:
		update_status("❌ No vegetation assets available")

func place_asset(asset_path: String, asset_type: String):
	"""Place an asset at a random position on the terrain"""
	print("Placing " + asset_type + ": " + asset_path)
	
	# Load the asset
	var asset_scene = load(asset_path)
	if not asset_scene:
		print("❌ Failed to load asset: " + asset_path)
		return
	
	# Create instance
	var asset_instance = asset_scene.instantiate()
	if not asset_instance:
		print("❌ Failed to instantiate asset: " + asset_path)
		return
	
	# Set random position
	var random_pos = Vector3(
		randf_range(-10, 10),
		0,
		randf_range(-10, 10)
	)
	asset_instance.position = random_pos
	
	# Add to scene
	psx_assets_node.add_child(asset_instance)
	
	print("✅ Placed " + asset_type + " at position: " + str(random_pos))

func clear_all_assets():
	"""Clear all placed PSX assets"""
	print("Clearing all PSX assets...")
	
	for child in psx_assets_node.get_children():
		child.queue_free()
	
	update_status("✅ Cleared all assets")

func update_status(text: String):
	"""Update the status label"""
	if status_label:
		status_label.text = text
	print("Status: " + text)

func _input(event):
	# Keyboard shortcuts
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_T:
				place_random_tree()
			KEY_S:
				place_random_stone()
			KEY_V:
				place_random_vegetation()
			KEY_C:
				clear_all_assets()
			KEY_1:
				current_pack = papua_pack
				update_status("Switched to Papua pack")
			KEY_2:
				current_pack = tambora_pack
				update_status("Switched to Tambora pack")
			KEY_ESCAPE:
				print("Exiting test mode...")
				get_tree().quit()
