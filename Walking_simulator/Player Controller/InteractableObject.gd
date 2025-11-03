class_name CulturalInteractableObject
extends Node3D

@export var interaction_prompt : String
@export var can_interact : bool = true

func _interact():
	print("Override this function.")
