class_name NPCWalkingState
extends NPCState

# Walking state for NPCs - handles movement behavior
# Implements Single Responsibility Principle - handles only walking behavior

var target_position: Vector3
var walk_speed: float = 2.0
var walk_timer: float = 0.0
var max_walk_time: float = 10.0
var reached_target: bool = false

func enter():
	GameLogger.debug(npc.npc_name + " entered walking state")
	set_new_target_position()
	walk_timer = 0.0
	reached_target = false

func update(delta: float):
	# Check if player is nearby (priority over walking)
	if check_player_proximity():
		change_to_idle()
		return
	
	walk_timer += delta
	
	# Check if we've been walking too long
	if walk_timer >= max_walk_time:
		change_to_idle()
		return
	
	# Move towards target
	move_towards_target(delta)
	
	# Check if we've reached the target
	if reached_target:
		change_to_idle()

func set_new_target_position():
	# Set a random target position within a reasonable range
	var current_pos = npc.position
	var random_offset = Vector3(
		randf_range(-5.0, 5.0),
		0.0,
		randf_range(-5.0, 5.0)
	)
	
	target_position = current_pos + random_offset
	
	# Ensure target is within bounds (you might want to add boundary checking)
	GameLogger.debug(npc.npc_name + " walking to: " + str(target_position))

func move_towards_target(delta: float):
	var direction = (target_position - npc.position).normalized()
	direction.y = 0  # Keep movement horizontal
	
	if direction != Vector3.ZERO:
		# Move towards target
		npc.position += direction * walk_speed * delta
		
		# Rotate to face movement direction
		npc.look_at(npc.position + direction, Vector3.UP)
		
		# Check if we're close enough to target
		var distance_to_target = npc.position.distance_to(target_position)
		if distance_to_target < 0.5:
			reached_target = true

func exit():
	GameLogger.debug(npc.npc_name + " exited walking state")

func get_state_name() -> String:
	return "WalkingState"
