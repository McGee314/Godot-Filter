extends RefCounted
class_name Terrain3DControllerFactory

## Factory for creating Terrain3D controllers following SOLID principles
## Factory Pattern: Creates appropriate controller based on terrain type

enum TerrainType {
	PAPUA,
	TAMBORA,
	JAVA_BARAT
}

static func create_controller(terrain_type: TerrainType, parent_node: Node3D) -> Terrain3DBaseController:
	"""Create a terrain controller based on the specified type"""
	match terrain_type:
		TerrainType.PAPUA:
			return _create_papua_controller(parent_node)
		TerrainType.TAMBORA:
			return _create_tambora_controller(parent_node)
		TerrainType.JAVA_BARAT:
			return _create_java_barat_controller(parent_node)
		_:
			GameLogger.error("❌ Unknown terrain type: %s" % terrain_type)
			return null

static func _create_papua_controller(parent_node: Node3D) -> Terrain3DPapuaController:
	"""Create Papua terrain controller"""
	var controller = Terrain3DPapuaController.new()
	controller.name = "PapuaTerrainController"
	parent_node.add_child(controller)
	
	# Connect signals for UI updates
	controller.terrain_initialized.connect(_on_terrain_initialized.bind(controller))
	controller.assets_placed.connect(_on_assets_placed.bind(controller))
	controller.terrain_cleared.connect(_on_terrain_cleared.bind(controller))
	
	GameLogger.info("✅ Created Papua terrain controller")
	return controller

static func _create_tambora_controller(parent_node: Node3D) -> Terrain3DBaseController:
	"""Create Tambora terrain controller - placeholder for future implementation"""
	var controller = Terrain3DBaseController.new()
	controller.name = "TamboraTerrainController"
	parent_node.add_child(controller)
	
	GameLogger.info("✅ Created Tambora terrain controller (placeholder)")
	return controller

static func _create_java_barat_controller(parent_node: Node3D) -> Terrain3DBaseController:
	"""Create Java Barat terrain controller - placeholder for future implementation"""
	var controller = Terrain3DBaseController.new()
	controller.name = "JavaBaratTerrainController"
	parent_node.add_child(controller)
	
	GameLogger.info("✅ Created Java Barat terrain controller (placeholder)")
	return controller

# Signal handlers
static func _on_terrain_initialized(controller: Terrain3DBaseController):
	"""Handle terrain initialization"""
	GameLogger.info("🎉 %s terrain initialized" % controller._get_terrain_type())

static func _on_assets_placed(count: int, controller: Terrain3DBaseController):
	"""Handle assets placed"""
	GameLogger.info("🎯 Placed %d %s assets" % [count, controller._get_terrain_type()])

static func _on_terrain_cleared(controller: Terrain3DBaseController):
	"""Handle terrain cleared"""
	GameLogger.info("🧹 Cleared %s terrain assets" % controller._get_terrain_type())
