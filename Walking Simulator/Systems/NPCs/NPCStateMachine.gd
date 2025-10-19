class_name NPCStateMachine
extends Node

# State Machine for NPCs following State Pattern
# Implements Single Responsibility Principle - each state handles one behavior

# Current state
var current_state: NPCState
var npc: CulturalNPC

# Available states
var idle_state: NPCIdleState
var interacting_state: NPCInteractingState
var walking_state: NPCWalkingState
var talking_state: NPCTalkingState

func _init(npc_reference: CulturalNPC):
	npc = npc_reference
	_setup_states()

func _setup_states():
	# Create state instances
	idle_state = NPCIdleState.new(self)
	interacting_state = NPCInteractingState.new(self)
	walking_state = NPCWalkingState.new(self)
	talking_state = NPCTalkingState.new(self)
	
	# Set initial state
	change_state(idle_state)

func change_state(new_state: NPCState):
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func update(delta: float):
	if current_state:
		current_state.update(delta)

func handle_input(event):
	if current_state:
		current_state.handle_input(event)

# State getters
func get_idle_state() -> NPCState:
	return idle_state

func get_interacting_state() -> NPCState:
	return interacting_state

func get_walking_state() -> NPCState:
	return walking_state

func get_talking_state() -> NPCState:
	return talking_state
