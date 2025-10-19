extends Node3D

# Test script to isolate input handling issues
# This will help us identify the root cause of the !is_inside_tree() error

var input_timer: Timer
var test_counter: int = 0

func _ready():
	GameLogger.info("TestInputHandling: _ready() called")
	setup_input_test()

func setup_input_test():
	GameLogger.info("TestInputHandling: Setting up input test")
	
	# Create a timer to test input handling
	input_timer = Timer.new()
	input_timer.name = "InputTestTimer"
	input_timer.wait_time = 1.0  # Check every second
	input_timer.timeout.connect(_test_input_handling)
	add_child(input_timer)
	
	# Connect button press
	var test_button = get_node("TestUI/TestButton")
	if test_button:
		test_button.pressed.connect(_on_test_button_pressed)
	
	GameLogger.info("TestInputHandling: Input test setup complete")

func _test_input_handling():
	test_counter += 1
	GameLogger.info("TestInputHandling: Input test iteration " + str(test_counter))
	
	# Test if we're still in the tree
	if not is_inside_tree():
		GameLogger.warning("TestInputHandling: WARNING - Node is not in tree!")
		# Clean up timer immediately
		if input_timer and is_instance_valid(input_timer):
			input_timer.stop()
			input_timer.queue_free()
		return
	
	# Additional safety check - ensure we have a valid viewport
	var viewport = get_viewport()
	if not viewport or not is_instance_valid(viewport):
		GameLogger.warning("TestInputHandling: No valid viewport, cleaning up")
		if input_timer and is_instance_valid(input_timer):
			input_timer.stop()
			input_timer.queue_free()
		return
	
	# Test input handling with proper checks
	if Input.is_action_just_pressed("ui_accept"):
		GameLogger.info("TestInputHandling: Enter key pressed")
		# Test input consumption with safety check
		if is_inside_tree() and viewport:
			viewport.set_input_as_handled()
			GameLogger.info("TestInputHandling: Input consumed successfully")
		else:
			GameLogger.warning("TestInputHandling: Cannot consume input - node not in tree or no viewport")

func _on_test_button_pressed():
	GameLogger.info("TestInputHandling: Test button pressed")
	
	# Test creating and destroying timers
	test_timer_lifecycle()

func test_timer_lifecycle():
	GameLogger.info("TestInputHandling: Testing timer lifecycle")
	
	# Create a temporary timer
	var temp_timer = Timer.new()
	temp_timer.name = "TempTimer"
	temp_timer.wait_time = 0.5
	temp_timer.one_shot = true
	
	# Connect with proper error handling
	temp_timer.timeout.connect(func():
		GameLogger.info("TestInputHandling: Temp timer fired")
		# Check if we're still valid
		if is_instance_valid(self) and is_inside_tree():
			GameLogger.info("TestInputHandling: Node still valid and in tree")
		else:
			GameLogger.warning("TestInputHandling: Node no longer valid or not in tree")
		
		# Clean up
		if is_instance_valid(temp_timer):
			temp_timer.queue_free()
	)
	
	add_child(temp_timer)
	temp_timer.start()
	
	GameLogger.info("TestInputHandling: Temp timer created and started")

func _exit_tree():
	GameLogger.info("TestInputHandling: _exit_tree() called")
	
	# Clean up timer
	if input_timer and is_instance_valid(input_timer):
		input_timer.stop()
		input_timer.queue_free()
		GameLogger.info("TestInputHandling: Input timer cleaned up")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		GameLogger.info("TestInputHandling: _notification(PREDELETE) called")
	elif what == NOTIFICATION_READY:
		GameLogger.info("TestInputHandling: _notification(READY) called")
