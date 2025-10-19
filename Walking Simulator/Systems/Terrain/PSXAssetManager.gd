extends Node

# Phase 1 stub: organizes access to PSX assets without modifying existing assets.

class_name PSXAssetManager

var psx_roots := {
	"Papua": "res://Assets/PSX/PSX Nature/",
	"Tambora": "res://Assets/PSX/PSX Nature/",
	"Shared": "res://Assets/PSX/PSX Textures/"
}

func resource_exists(path: String) -> bool:
	return ResourceLoader.exists(path)

func get_region_root(region: String) -> String:
	return psx_roots.get(region, psx_roots["Shared"])

func list_textures_under(root: String) -> Array:
	var result: Array = []
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(root)):
		var dir := DirAccess.open(root)
		if dir:
			dir.list_dir_begin()
			var name = dir.get_next()
			while name != "":
				if not dir.current_is_dir() and name.ends_with(".png"):
					result.append(root + name)
				name = dir.get_next()
			dir.list_dir_end()
	return result

