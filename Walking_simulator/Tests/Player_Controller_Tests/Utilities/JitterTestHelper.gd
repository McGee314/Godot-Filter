extends Node3D
class_name JitterTestHelper

## Helper script to test and validate jitter fixes in Godot 4.4.1
## Add this as a child node to your test scene for debugging

@export var test_duration: float = 10.0
@export var log_interval: float = 0.5

var start_time: float
var last_position: Vector3
var position_history: Array[Vector3] = []
var velocity_history: Array[Vector3] = []
var is_testing: bool = false

func _ready():
	print("🔧 JitterTestHelper initialized")
	print("Press J to start jitter test, K to stop, L to print results")
	print("Or use the UI buttons in the test panel")

func _input(_event: InputEvent):
	# Use input actions for better reliability
	if Input.is_action_just_pressed("start_jitter_test"):
		start_jitter_test()
	elif Input.is_action_just_pressed("stop_jitter_test"):
		stop_jitter_test()
	elif Input.is_action_just_pressed("print_jitter_results"):
		print_test_results()

func start_jitter_test():
	## Start monitoring for jitter
	print("🧪 Starting jitter test...")
	GameLogger.info("🧪 Starting jitter test...")
	is_testing = true
	start_time = Time.get_unix_time_from_system()
	position_history.clear()
	velocity_history.clear()
	
	# Get initial position
	var player = get_tree().get_first_node_in_group("player")
	if player:
		last_position = player.global_position
		print("✅ Monitoring player position for jitter")
		GameLogger.info("✅ Monitoring player position for jitter")
	else:
		print("❌ No player found in 'player' group")
		GameLogger.error("❌ No player found in 'player' group")
		is_testing = false

func stop_jitter_test():
	## Stop monitoring and calculate results
	if not is_testing:
		return
	
	print("🛑 Stopping jitter test...")
	GameLogger.info("🛑 Stopping jitter test...")
	is_testing = false
	calculate_jitter_metrics()

var frame_counter = 0

func _process(delta: float):
	if not is_testing:
		return
	
	# Only record data every few frames to reduce performance impact
	frame_counter += 1
	if frame_counter % 3 != 0:  # Record every 3rd frame
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Record position and velocity
	position_history.append(player.global_position)
	velocity_history.append(player.velocity)
	
	# Check for sudden position changes (potential jitter) - less sensitive
	var current_position = player.global_position
	var position_delta = current_position.distance_to(last_position)
	
	# If position change is too large for the time delta, it might be jitter
	if position_delta > 0.5 and delta < 0.01:  # More sensitive threshold
		print("⚠️ Potential jitter detected: Position delta = %.3f in %.3f seconds" % [position_delta, delta])
		GameLogger.warning("⚠️ Potential jitter detected: Position delta = %.3f in %.3f seconds" % [position_delta, delta])
	
	last_position = current_position

func calculate_jitter_metrics():
	## Calculate and display jitter metrics
	if position_history.size() < 2:
		print("❌ Not enough data for jitter analysis")
		return
	
	print("📊 JITTER ANALYSIS RESULTS:")
	print("==================================================")
	GameLogger.info("📊 JITTER ANALYSIS RESULTS:")
	GameLogger.info("==================================================")
	
	# Calculate position variance
	var position_variance = calculate_vector3_variance(position_history)
	print("Position Variance: %.6f" % position_variance)
	GameLogger.info("Position Variance: %.6f" % position_variance)
	
	# Calculate velocity variance
	var velocity_variance = calculate_vector3_variance(velocity_history)
	print("Velocity Variance: %.6f" % velocity_variance)
	GameLogger.info("Velocity Variance: %.6f" % velocity_variance)
	
	# Calculate frame time consistency
	var frame_times = []
	for i in range(1, position_history.size()):
		var time_diff = 1.0 / Engine.get_frames_per_second()
		frame_times.append(time_diff)
	
	var frame_time_variance = calculate_float_variance(frame_times)
	print("Frame Time Variance: %.6f" % frame_time_variance)
	GameLogger.info("Frame Time Variance: %.6f" % frame_time_variance)
	
	# Overall jitter score (lower is better)
	var jitter_score = (position_variance + velocity_variance + frame_time_variance) / 3.0
	print("Overall Jitter Score: %.6f" % jitter_score)
	GameLogger.info("Overall Jitter Score: %.6f" % jitter_score)
	
	# Interpretation
	var interpretation = ""
	if jitter_score < 0.001:
		interpretation = "✅ EXCELLENT: Very smooth movement"
	elif jitter_score < 0.01:
		interpretation = "✅ GOOD: Smooth movement with minor variations"
	elif jitter_score < 0.1:
		interpretation = "⚠️ FAIR: Some jitter detected"
	else:
		interpretation = "❌ POOR: Significant jitter detected"
	
	print(interpretation)
	GameLogger.info(interpretation)
	
	print("==================================================")
	GameLogger.info("==================================================")

func calculate_vector3_variance(data: Array) -> float:
	## Calculate variance of a Vector3 array
	if data.size() < 2:
		return 0.0
	
	# Calculate mean
	var sum = Vector3.ZERO
	for item in data:
		sum += item
	var mean = sum / data.size()
	
	# Calculate variance
	var variance_sum = 0.0
	for item in data:
		var diff = item - mean
		variance_sum += diff.length_squared()
	
	return variance_sum / data.size()

func calculate_float_variance(data: Array) -> float:
	## Calculate variance of a float array
	if data.size() < 2:
		return 0.0
	
	# Calculate mean
	var sum = 0.0
	for item in data:
		sum += item
	var mean = sum / data.size()
	
	# Calculate variance
	var variance_sum = 0.0
	for item in data:
		var diff = item - mean
		variance_sum += diff * diff
	
	return variance_sum / data.size()

func print_test_results():
	## Print current test status
	print("📋 CURRENT TEST STATUS:")
	print("Testing: %s" % ("YES" if is_testing else "NO"))
	print("Data Points: %d" % position_history.size())
	
	if position_history.size() > 0:
		print("Last Position: %s" % position_history[-1])
		print("Last Velocity: %s" % velocity_history[-1])
	
	print("FPS: %.1f" % Engine.get_frames_per_second())
	print("Physics FPS: %d" % Engine.physics_ticks_per_second)
