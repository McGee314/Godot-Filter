extends Control

# Splash screen configuration
@export var splash_duration: float = 3.0  # How long to show the splash screen
@export var fade_in_duration: float = 1.0  # Fade in duration
@export var fade_out_duration: float = 1.0  # Fade out duration
@export var main_menu_scene: String = "res://Scenes/MainMenu/MainMenu.tscn"

# Node references
@onready var splash_image: TextureRect = $SplashImage
@onready var fade_animation: AnimationPlayer = $FadeAnimation

# Animation names
const FADE_IN_ANIM = "fade_in"
const FADE_OUT_ANIM = "fade_out"

func _ready():
	print("SplashScreen: Initializing splash screen")
	GameLogger.info("SplashScreen: ===== SPLASH SCREEN STARTING =====")
	
	# Set initial state
	splash_image.modulate.a = 0.0
	
	# Create animations
	setup_animations()
	
	# Start the splash screen sequence
	start_splash_sequence()

func setup_animations():
	# Create fade in animation
	var fade_in_anim = Animation.new()
	var track_index = fade_in_anim.add_track(Animation.TYPE_VALUE)
	fade_in_anim.track_set_path(track_index, "SplashImage:modulate:a")
	fade_in_anim.length = fade_in_duration
	
	var key_index = fade_in_anim.track_insert_key(track_index, 0.0, 0.0)
	fade_in_anim.track_insert_key(track_index, fade_in_duration, 1.0)
	
	# Create fade out animation
	var fade_out_anim = Animation.new()
	track_index = fade_out_anim.add_track(Animation.TYPE_VALUE)
	fade_out_anim.track_set_path(track_index, "SplashImage:modulate:a")
	fade_out_anim.length = fade_out_duration
	
	key_index = fade_out_anim.track_insert_key(track_index, 0.0, 1.0)
	fade_out_anim.track_insert_key(track_index, fade_out_duration, 0.0)
	
	# Add animations to animation player using the correct method for Godot 4.x
	if fade_animation.has_animation_library(""):
		fade_animation.get_animation_library("").add_animation(FADE_IN_ANIM, fade_in_anim)
		fade_animation.get_animation_library("").add_animation(FADE_OUT_ANIM, fade_out_anim)
	else:
		# Fallback: create animation library if it doesn't exist
		fade_animation.add_animation_library("", AnimationLibrary.new())
		fade_animation.get_animation_library("").add_animation(FADE_IN_ANIM, fade_in_anim)
		fade_animation.get_animation_library("").add_animation(FADE_OUT_ANIM, fade_out_anim)
	
	GameLogger.info("SplashScreen: Animations setup complete")

func start_splash_sequence():
	GameLogger.info("SplashScreen: Starting splash sequence")
	
	# Start with fade in
	fade_animation.play("fade_in")
	
	# Wait for fade in to complete, then show splash, then fade out
	await fade_animation.animation_finished
	
	# Show splash for the specified duration
	await get_tree().create_timer(splash_duration).timeout
	
	# Fade out
	fade_animation.play("fade_out")
	
	GameLogger.info("SplashScreen: Splash sequence completed")

func _on_fade_animation_finished(anim_name: String):
	if anim_name == "fade_out":
		GameLogger.info("SplashScreen: Fade out completed, transitioning to main menu")
		transition_to_main_menu()

func transition_to_main_menu():
	GameLogger.info("SplashScreen: Transitioning to main menu: " + main_menu_scene)
	
	# Change to main menu scene
	var result = get_tree().change_scene_to_file(main_menu_scene)
	
	if result != OK:
		GameLogger.error("SplashScreen: Failed to transition to main menu: " + str(result))
		# Fallback to main scene if main menu fails
		get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
	else:
		GameLogger.info("SplashScreen: Successfully transitioned to main menu")

# Allow skipping splash screen with any key or mouse click
func _input(event):
	if event is InputEventKey and event.pressed:
		skip_splash_screen()
	elif event is InputEventMouseButton and event.pressed:
		skip_splash_screen()

func skip_splash_screen():
	GameLogger.info("SplashScreen: Splash screen skipped by user input")
	transition_to_main_menu()
