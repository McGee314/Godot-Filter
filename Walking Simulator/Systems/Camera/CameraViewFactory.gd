class_name CameraViewFactory
extends Node

## Camera View Factory (SOLID: Dependency Inversion + Factory Pattern)
## Creates appropriate camera view instances based on view type

enum ViewType {
	PLAYER_VIEW,
	FAR_SIDE_VIEW,
	CANOPY_VIEW
	# Future: TOP_DOWN_VIEW, DEBUG_VIEW, CINEMATIC_VIEW
}

static func create_view(view_type: ViewType) -> CameraViewBase:
	"""Create a camera view instance based on type"""
	match view_type:
		ViewType.PLAYER_VIEW:
			return PlayerCameraView.new()
		ViewType.FAR_SIDE_VIEW:
			return FarSideCameraView.new()
		ViewType.CANOPY_VIEW:
			return CanopyCameraView.new()
		_:
			push_error("Unknown camera view type: " + str(view_type))
			return null

static func get_view_name(view_type: ViewType) -> String:
	"""Get display name for a view type"""
	match view_type:
		ViewType.PLAYER_VIEW:
			return "Player View"
		ViewType.FAR_SIDE_VIEW:
			return "Far Side View"
		ViewType.CANOPY_VIEW:
			return "Canopy View"
		_:
			return "Unknown View"

static func get_view_description(view_type: ViewType) -> String:
	"""Get description for a view type"""
	match view_type:
		ViewType.PLAYER_VIEW:
			return "Normal third-person player following camera"
		ViewType.FAR_SIDE_VIEW:
			return "High overview perspective for terrain and path visualization"
		ViewType.CANOPY_VIEW:
			return "Above forest level view following player movement"
		_:
			return "Unknown view type"

static func get_all_view_types() -> Array[ViewType]:
	"""Get all available view types"""
	return [
		ViewType.PLAYER_VIEW,
		ViewType.FAR_SIDE_VIEW,
		ViewType.CANOPY_VIEW
	]

static func get_view_key_binding(view_type: ViewType) -> String:
	"""Get key binding for a view type"""
	match view_type:
		ViewType.PLAYER_VIEW:
			return "Key 1"
		ViewType.FAR_SIDE_VIEW:
			return "Key 2"
		ViewType.CANOPY_VIEW:
			return "Key 3"
		_:
			return "No key"
