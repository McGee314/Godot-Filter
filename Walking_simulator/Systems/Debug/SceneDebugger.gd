extends Node3D

# Scene Debugger for identifying interaction and collision issues
# This script will help debug why NPCs and objects aren't working properly

@export var debug_mode: bool = true
@export var show_collision_boxes: bool = true
@export var show_interaction_ranges: bool = true

var debug_meshes: Array[Node3D] = []

func _ready():
	# Respect global debug config
	var enabled = true
	if has_node("/root/DebugConfig"):
		enabled = get_node("/root/DebugConfig").enable_scene_debugger
	if not enabled:
		return
	
	if debug_mode:
		GameLogger.info("SceneDebugger initialized")
		await get_tree().process_frame  # Wait one frame for scene to load
		debug_scene()

func debug_scene():
	# If INFO is disabled, skip entire pass
	if has_node("/root/DebugConfig") and get_node("/root/DebugConfig").log_level < GameLogger.LogLevel.INFO:
		return
	GameLogger.info("=== SCENE DEBUG START ===")
	
	# Debug NPCs
	debug_npcs()
	
	# Debug collision bodies
	debug_collision_bodies()
	
	# Debug interaction areas
	debug_interaction_areas()
	
	# Debug player
	debug_player()
	
	GameLogger.info("=== SCENE DEBUG COMPLETE ===")

func debug_npcs():
	GameLogger.info("--- Debugging NPCs ---")
	var npcs = get_tree().get_nodes_in_group("npc")
	if npcs.is_empty():
		GameLogger.warning("No NPCs found in 'npc' group")
	
	# Find NPCs by searching for CulturalNPC scripts
	var all_nodes = get_all_nodes_in_tree(get_tree().current_scene)
	var cultural_npcs = []
	
	for node in all_nodes:
		if node.has_method("_interact") and node.has_method("setup_npc"):
			cultural_npcs.append(node)
	
	GameLogger.info("Found " + str(cultural_npcs.size()) + " CulturalNPC instances:")
	
	for npc in cultural_npcs:
		GameLogger.info("  - " + npc.name + " (Type: " + str(npc.get_class()) + ")")
		GameLogger.info("    Position: " + str(npc.global_position))
		GameLogger.info("    Can interact: " + str(npc.can_interact))
		GameLogger.info("    Interaction prompt: " + str(npc.interaction_prompt))
		
		# Check if NPC has collision body
		var collision_body = npc.get_node_or_null("NPCCollision")
		if collision_body:
			GameLogger.info("    Has collision body: " + collision_body.name)
		else:
			GameLogger.warning("    Missing collision body!")
		
		# Check if NPC has interaction area
		var interaction_area = npc.get_node_or_null("InteractionArea")
		if interaction_area:
			GameLogger.info("    Has interaction area: " + interaction_area.name)
		else:
			GameLogger.warning("    Missing interaction area!")

func debug_collision_bodies():
	GameLogger.info("--- Debugging Collision Bodies ---")
	var all_nodes = get_all_nodes_in_tree(get_tree().current_scene)
	var collision_bodies = []
	
	for node in all_nodes:
		if node is StaticBody3D or node is CharacterBody3D:
			collision_bodies.append(node)
	
	GameLogger.info("Found " + str(collision_bodies.size()) + " collision bodies:")
	
	for body in collision_bodies:
		GameLogger.info("  - " + body.name + " (Type: " + str(body.get_class()) + ")")
		GameLogger.info("    Position: " + str(body.global_position))
		
		# Check collision shape (recursive)
		if _has_descendant_collision_shape(body):
			GameLogger.info("    Has collision shape (descendant detected)")
		else:
			GameLogger.warning("    Missing collision shape!")

func debug_interaction_areas():
	GameLogger.info("--- Debugging Interaction Areas ---")
	var all_nodes = get_all_nodes_in_tree(get_tree().current_scene)
	var interaction_areas = []
	
	for node in all_nodes:
		if node is Area3D:
			interaction_areas.append(node)
	
	GameLogger.info("Found " + str(interaction_areas.size()) + " interaction areas:")
	
	for area in interaction_areas:
		GameLogger.info("  - " + area.name + " (Parent: " + area.get_parent().name + ")")
		GameLogger.info("    Position: " + str(area.global_position))
		
		# Check collision shape (recursive)
		if _has_descendant_collision_shape(area):
			GameLogger.info("    Has collision shape (descendant detected)")
		else:
			GameLogger.warning("    Missing collision shape!")

func debug_player():
	GameLogger.info("--- Debugging Player ---")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameLogger.info("Player found: " + player.name)
		GameLogger.info("Player position: " + str(player.global_position))
		
		# Check interaction controller
		var interaction_controller = player.get_node_or_null("InteractionController")
		if interaction_controller:
			GameLogger.info("Interaction controller found: " + interaction_controller.name)
			GameLogger.info("RayCast target position: " + str(interaction_controller.target_position))
			
			# Check what the raycast is hitting
			var collider = interaction_controller.get_collider()
			if collider:
				GameLogger.info("RayCast currently hitting: " + collider.name + " (Type: " + str(collider.get_class()) + ")")
			else:
				GameLogger.info("RayCast not hitting anything")
		else:
			GameLogger.error("Interaction controller not found!")
	else:
		GameLogger.error("Player not found!")

func get_all_nodes_in_tree(root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	_get_all_nodes_recursive(root, nodes)
	return nodes

func _get_all_nodes_recursive(node: Node, nodes: Array[Node]):
	nodes.append(node)
	for child in node.get_children():
		_get_all_nodes_recursive(child, nodes)

# Visual debug helpers
func create_debug_sphere(pos: Vector3, color: Color, radius: float = 0.5):
	if not show_interaction_ranges:
		return
	
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2
	mesh_instance.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_transparent = true
	material.albedo_color.a = 0.3
	mesh_instance.material_override = material
	
	mesh_instance.global_position = pos
	add_child(mesh_instance)
	debug_meshes.append(mesh_instance)

func create_debug_box(pos: Vector3, size: Vector3, color: Color):
	if not show_collision_boxes:
		return
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_transparent = true
	material.albedo_color.a = 0.3
	mesh_instance.material_override = material
	
	mesh_instance.global_position = pos
	add_child(mesh_instance)
	debug_meshes.append(mesh_instance)

func _has_descendant_collision_shape(node: Node) -> bool:
	for child in node.get_children():
		if child is CollisionShape3D:
			return true
		if child.get_child_count() > 0 and _has_descendant_collision_shape(child):
			return true
	return false
