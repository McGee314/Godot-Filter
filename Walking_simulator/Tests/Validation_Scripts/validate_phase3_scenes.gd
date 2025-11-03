extends SceneTree

const SCENES := [
	"res://Tests/Terrain3D/test_terrain.tscn",
	"res://Tests/PSX_Assets/test_psx_assets.tscn",
]

func _initialize():
	var ok := true
	for path in SCENES:
		var ps: PackedScene = load(path)
		if ps == null:
			push_error("[PH3] Failed to load: " + path)
			ok = false
			continue
		var inst = ps.instantiate()
		if inst == null:
			push_error("[PH3] Failed to instantiate: " + path)
			ok = false
			continue
		get_root().add_child(inst)
		print("[PH3] OK "+ path)
		inst.queue_free()
	
	await process_frame
	var status = "OK" if ok else "FAILED"
	print("[PH3] Phase 3 scenes status: " + status)
	var exit_code = 0 if ok else 1
	quit(exit_code)

