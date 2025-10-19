class_name NPCState
extends RefCounted

# Base class for all NPC states
# Implements State Pattern for NPC behavior management

var state_machine: NPCStateMachine
var npc: CulturalNPC

func _init(machine: NPCStateMachine):
	state_machine = machine
	npc = machine.npc

# State lifecycle methods
func enter():
	# Called when entering this state
	pass

func update(_delta: float):
	# Called every frame while in this state
	pass

func exit():
	# Called when exiting this state
	pass

func handle_input(_event):
	# Called when input is received
	pass

# Helper methods for state transitions
func change_to_idle():
	state_machine.change_state(state_machine.get_idle_state())

func change_to_interacting():
	state_machine.change_state(state_machine.get_interacting_state())

func change_to_walking():
	state_machine.change_state(state_machine.get_walking_state())

func change_to_talking():
	state_machine.change_state(state_machine.get_talking_state())

# Common NPC behaviors
func check_player_proximity() -> bool:
	if not npc.player:
		return false
	
	var distance = npc.position.distance_to(npc.player.position)
	return distance <= npc.interaction_range

func face_player():
	if npc.player:
		var direction = (npc.player.position - npc.position).normalized()
		direction.y = 0  # Keep rotation horizontal
		if direction != Vector3.ZERO:
			npc.look_at(npc.player.position, Vector3.UP)

func get_state_name() -> String:
	return "BaseState"
