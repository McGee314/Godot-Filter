class_name BasicCookingGameAssets
extends Node

# Basic cooking game assets using simple 3D shapes
# This will be replaced with student assets later

# Basic cooking equipment shapes
var cooking_equipment: Dictionary = {
	"pot": {
		"shape": "cylinder",
		"size": Vector3(0.5, 0.3, 0.5),
		"color": Color(0.7, 0.7, 0.7),
		"position": Vector3(0, 0, 0)
	},
	"cutting_board": {
		"shape": "box",
		"size": Vector3(0.8, 0.1, 0.6),
		"color": Color(0.6, 0.4, 0.2),
		"position": Vector3(1, 0, 0)
	},
	"knife": {
		"shape": "box",
		"size": Vector3(0.3, 0.05, 0.05),
		"color": Color(0.8, 0.8, 0.9),
		"position": Vector3(1.2, 0.1, 0)
	},
	"bowl": {
		"shape": "cylinder",
		"size": Vector3(0.4, 0.2, 0.4),
		"color": Color(0.9, 0.9, 0.9),
		"position": Vector3(-1, 0, 0)
	},
	"spoon": {
		"shape": "box",
		"size": Vector3(0.2, 0.05, 0.05),
		"color": Color(0.7, 0.7, 0.7),
		"position": Vector3(-1.2, 0.1, 0)
	}
}

# Basic ingredient shapes
var ingredients: Dictionary = {
	"beef": {
		"shape": "box",
		"size": Vector3(0.2, 0.1, 0.2),
		"color": Color(0.6, 0.3, 0.3),
		"position": Vector3(0, 0.2, 0)
	},
	"rice": {
		"shape": "box",
		"size": Vector3(0.15, 0.05, 0.15),
		"color": Color(0.9, 0.9, 0.8),
		"position": Vector3(0.3, 0.2, 0)
	},
	"vegetables": {
		"shape": "box",
		"size": Vector3(0.1, 0.1, 0.1),
		"color": Color(0.3, 0.7, 0.3),
		"position": Vector3(-0.3, 0.2, 0)
	},
	"spices": {
		"shape": "cylinder",
		"size": Vector3(0.05, 0.1, 0.05),
		"color": Color(0.8, 0.6, 0.2),
		"position": Vector3(0, 0.2, 0.3)
	}
}

# Basic cooking station setup
func create_basic_cooking_station(parent: Node3D) -> Node3D:
	"""Create a basic cooking station with simple 3D shapes"""
	var cooking_station = Node3D.new()
	cooking_station.name = "BasicCookingStation"
	parent.add_child(cooking_station)
	
	# Create cooking equipment
	for equipment_name in cooking_equipment:
		var equipment_data = cooking_equipment[equipment_name]
		var equipment = create_basic_shape(equipment_data)
		equipment.name = equipment_name
		cooking_station.add_child(equipment)
	
	# Create ingredient containers
	for ingredient_name in ingredients:
		var ingredient_data = ingredients[ingredient_name]
		var ingredient = create_basic_shape(ingredient_data)
		ingredient.name = ingredient_name
		cooking_station.add_child(ingredient)
	
	GameLogger.info("✅ Created basic cooking station with 3D shapes")
	return cooking_station

func create_basic_shape(shape_data: Dictionary) -> Node3D:
	"""Create a basic 3D shape from data"""
	var shape_node = Node3D.new()
	
	# Create mesh based on shape type
	var mesh_instance = MeshInstance3D.new()
	match shape_data.shape:
		"box":
			var box_mesh = BoxMesh.new()
			box_mesh.size = shape_data.size
			mesh_instance.mesh = box_mesh
		"cylinder":
			var cylinder_mesh = CylinderMesh.new()
			cylinder_mesh.top_radius = shape_data.size.x
			cylinder_mesh.bottom_radius = shape_data.size.x
			cylinder_mesh.height = shape_data.size.y
			mesh_instance.mesh = cylinder_mesh
		"sphere":
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = shape_data.size.x
			sphere_mesh.height = shape_data.size.y
			mesh_instance.mesh = sphere_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = shape_data.color
	material.roughness = 0.7
	material.metallic = 0.1
	mesh_instance.material_override = material
	
	# Set position
	shape_node.position = shape_data.position
	shape_node.add_child(mesh_instance)
	
	return shape_node

func get_equipment_shape(equipment_name: String) -> Dictionary:
	"""Get equipment shape data"""
	if equipment_name in cooking_equipment:
		return cooking_equipment[equipment_name]
	return {}

func get_ingredient_shape(ingredient_name: String) -> Dictionary:
	"""Get ingredient shape data"""
	if ingredient_name in ingredients:
		return ingredients[ingredient_name]
	return {}

func add_equipment(equipment_name: String, shape_data: Dictionary):
	"""Add new equipment to the database"""
	cooking_equipment[equipment_name] = shape_data

func add_ingredient(ingredient_name: String, shape_data: Dictionary):
	"""Add new ingredient to the database"""
	ingredients[ingredient_name] = shape_data

# Static methods for easy access
static func create_quick_cooking_station(parent: Node3D) -> Node3D:
	"""Static method to quickly create a cooking station"""
	var assets = BasicCookingGameAssets.new()
	return assets.create_basic_cooking_station(parent)

static func get_equipment_list() -> Array[String]:
	"""Get list of available equipment"""
	var assets = BasicCookingGameAssets.new()
	return assets.cooking_equipment.keys()

static func get_ingredient_list() -> Array[String]:
	"""Get list of available ingredients"""
	var assets = BasicCookingGameAssets.new()
	return assets.ingredients.keys()
