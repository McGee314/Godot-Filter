extends SceneTree

const SCENES := [
	"res://Tests/Input_Systems/test_phase0_input.tscn",
	"res://Tests/NPC_Interaction/test_phase0_interaction.tscn",
	"res://Tests/UI_Components/test_phase0_ui.tscn",
	"res://Tests/NPC_Interaction/test_phase0_npc_dialogue.tscn",
]

func _initialize():
	var ok := true
	for path in SCENES:
		var ps: PackedScene = load(path)
		if ps == null:
			push_error("[VALIDATE] Failed to load: " + path)
			ok = false
			continue
		var inst = ps.instantiate()
		if inst == null:
			push_error("[VALIDATE] Failed to instantiate: " + path)
			ok = false
			continue
		get_root().add_child(inst)
		print("[VALIDATE] OK "+ path)
		inst.queue_free()
	
	await process_frame
	var status = "OK" if ok else "FAILED"
	print("[VALIDATE] Phase 0 scenes status: " + status)
	var exit_code = 0 if ok else 1
	quit(exit_code)

