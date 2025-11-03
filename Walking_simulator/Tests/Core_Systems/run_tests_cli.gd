extends SceneTree

func _initialize():
	print("[CLI] Starting Cultural Systems Tests...")
	var test_script: Script = load("res://Tests/run_tests.gd")
	if test_script == null:
		push_error("[CLI] Failed to load run_tests.gd")
		quit(1)
		return

	var test_node: Node = test_script.new()
	get_root().add_child(test_node)
	await process_frame

	if not test_node.has_method("run_all_tests"):
		push_error("[CLI] run_all_tests() not found in run_tests.gd")
		quit(1)
		return

	# Execute tests
	test_node.run_all_tests()

	# Allow prints to flush and any async to settle
	await process_frame
	await process_frame

	print("[CLI] Tests finished.")
	quit(0)

