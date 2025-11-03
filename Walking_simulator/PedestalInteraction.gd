extends CulturalInteractableObject

@onready var light_bulb = get_node("LightBulb")

func _interact ():
	light_bulb.visible = true
	can_interact = false
