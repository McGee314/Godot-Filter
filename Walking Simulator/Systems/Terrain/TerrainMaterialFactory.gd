extends Node

# Phase 1 stub: responsible for producing materials for terrain usage.

class_name TerrainMaterialFactory

func create_basic_material(texture_path: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	if ResourceLoader.exists(texture_path):
		var tex: Texture2D = load(texture_path)
		mat.albedo_texture = tex
	return mat

func create_unlit_material(texture_path: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if ResourceLoader.exists(texture_path):
		var tex: Texture2D = load(texture_path)
		mat.albedo_texture = tex
	return mat

