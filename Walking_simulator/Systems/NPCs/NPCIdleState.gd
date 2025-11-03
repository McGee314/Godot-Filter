class_name NPCIdleState
extends NPCState

# Idle state for NPCs - default behavior when not interacting
# Implements Single Responsibility Principle - handles only idle behavior

var idle_timer: float = 0.0
var idle_duration: float = 5.0
var look_around_timer: float = 0.0
var look_around_duration: float = 3.0

func enter():
	GameLogger.debug(npc.npc_name + " entered idle state")
	npc.interaction_prompt = "Press E to talk to " + npc.npc_name
	idle_timer = 0.0
	look_around_timer = 0.0

func update(delta: float):
	# Check if player is nearby
	if check_player_proximity():
		# Player is close, face them
		face_player()
		
		# Check if player wants to interact
		if Input.is_action_just_pressed("interact"):
			change_to_interacting()
			return
	else:
		# Player is not nearby, do idle behaviors
		perform_idle_behavior(delta)

func perform_idle_behavior(delta: float):
	idle_timer += delta
	look_around_timer += delta
	
	# Look around occasionally
	if look_around_timer >= look_around_duration:
		look_around_timer = 0.0
		perform_look_around()
	
	# Consider walking to a new position
	if idle_timer >= idle_duration:
		idle_timer = 0.0
		if should_start_walking():
			change_to_walking()

func perform_look_around():
	# Simple look around behavior
	var random_rotation = randf_range(-45, 45)
	npc.rotate_y(deg_to_rad(random_rotation))

func should_start_walking() -> bool:
	# 30% chance to start walking
	return randf() < 0.3

func exit():
	GameLogger.debug(npc.npc_name + " exited idle state")

func get_state_name() -> String:
	return "IdleState"
