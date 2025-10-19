# TopengWebcamController.gd
extends Control

@onready var webcam_feed = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed
@onready var camera_status_label = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/CameraStatusLabel
@onready var mask_display = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/MaskOverlay/MaskDisplay
@onready var mask_info_label = $MainContainer/InfoContainer/MaskInfoLabel
@onready var status_label = $MainContainer/InfoContainer/StatusLabel
@onready var fps_label = $MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/FPSLabel

# Webcam Manager - will be loaded manually
var webcam_manager: Node = null
var webcam_frames_received: int = 0
var frame_count := 0
var fps := 0.0
var last_time := 0.0

func _ready() -> void:
	print("=== TopengWebcamController._ready() ===")
	print("Scene tree ready, setting up webcam...")
	last_time = Time.get_ticks_msec()   # init untuk FPS

	# Verify node paths (debug)
	print("webcam_feed path exists: ", has_node("MainContainer/WebcamContainer/WebcamPanel/WebcamFeed"))
	print("camera_status_label path exists: ", has_node("MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/CameraStatusLabel"))
	print("fps_label path exists: ", has_node("MainContainer/WebcamContainer/WebcamPanel/WebcamFeed/FPSLabel"))
	
	setup_webcam_manager()
	setup_mask_display()
	display_mask_info()
	
	# If a custom mask was selected, send it to the server
	# (This handles cases where user came from TopengCustomizationScene but server wasn't ready yet)
	if Global.selected_mask_type == "custom":
		print("Custom mask detected in Global, will send to server after a short delay...")
		# Wait a moment for server connection to be established
		await get_tree().create_timer(1.0).timeout
		send_custom_mask_from_global()


func setup_webcam_manager() -> void:
	"""Setup WebcamManagerUDP for real webcam"""
	print("=== Setting up WebcamManagerUDP ===")

	# Verify nodes are available
	if webcam_feed == null:
		print("❌ ERROR: webcam_feed node not found!")
		return

	if camera_status_label == null:
		print("❌ ERROR: camera_status_label node not found!")
		return

	# Setup placeholder image first
	setup_webcam_placeholder()

	# Candidate paths — adjusted to realistic project layout (use the Walking Simulator path first)
	var candidates := [
		"res://Walking Simulator/Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd",
		"res://Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd"
	]

	var webcam_script: Script = null
	for path in candidates:
		var s = load(path)
		if s and s is Script:
			webcam_script = s
			print("✅ Loaded WebcamManagerUDP from: ", path)
			break

	# last resort: try the explicit path used earlier if needed
	if webcam_script == null:
		var alt = "res://Walking Simulator/Scenes/EthnicityDetection/WebcamClient/WebcamManagerUDP.gd"
		var s2 = load(alt)
		if s2 and s2 is Script:
			webcam_script = s2
			print("✅ Loaded WebcamManagerUDP from alt: ", alt)

	if webcam_script == null:
		print("❌ ERROR: Could not find WebcamManagerUDP.gd in candidate paths. Please adjust path.")
		camera_status_label.text = "❌ Script not found"
		camera_status_label.modulate = Color(1,0,0,0.9)
		return

	# Instantiate and add as child (so it gets _process etc.)
	webcam_manager = webcam_script.new()
	if webcam_manager == null:
		print("❌ ERROR: Failed to instantiate WebcamManagerUDP")
		camera_status_label.text = "❌ Instantiation error"
		camera_status_label.modulate = Color(1,0,0,0.9)
		return

	add_child(webcam_manager)
	print("Created WebcamManagerUDP instance and added to scene tree")

	# Connect signals (use Callable for Godot 4)
	# frame_received(texture)
	if webcam_manager.has_signal("frame_received"):
		var err = webcam_manager.connect("frame_received", Callable(self, "_on_webcam_frame_received"))
		if err == OK:
			print("✅ Connected frame_received signal")
		else:
			print("⚠️ Could not connect frame_received signal (err=%s)" % str(err))
	else:
		print("⚠️ Webcam manager has no 'frame_received' signal")

	# connection_changed(connected: bool)
	if webcam_manager.has_signal("connection_changed"):
		var err2 = webcam_manager.connect("connection_changed", Callable(self, "_on_webcam_connection_changed"))
		if err2 == OK:
			print("✅ Connected connection_changed signal")
		else:
			print("⚠️ Could not connect connection_changed signal (err=%s)" % str(err2))
	else:
		print("⚠️ Webcam manager has no 'connection_changed' signal")

	# error_message(message: String)
	if webcam_manager.has_signal("error_message"):
		var err3 = webcam_manager.connect("error_message", Callable(self, "_on_webcam_error"))
		if err3 == OK:
			print("✅ Connected error_message signal")
		else:
			print("⚠️ Could not connect error_message signal (err=%s)" % str(err3))
	else:
		print("⚠️ Webcam manager has no 'error_message' signal")

	# Update status UI
	camera_status_label.text = "🔗 Menghubungkan ke UDP webcam server (port 8888)..."
	camera_status_label.modulate = Color(1, 1, 0, 0.9)

	# Try connecting to webcam server (the method exists in WebcamManagerUDP.gd)
	if webcam_manager.has_method("connect_to_webcam_server"):
		print("Attempting UDP connection to webcam server...")
		# call it deferred so this setup finishes and any signals can be connected first
		webcam_manager.call_deferred("connect_to_webcam_server")
		print("Called connect_to_webcam_server() (deferred)")
	else:
		print("⚠️ WebcamManagerUDP instance does not have connect_to_webcam_server() method")
		camera_status_label.text = "❌ No connect method"
		camera_status_label.modulate = Color(1,0,0,0.9)


func setup_webcam_placeholder() -> void:
	var w := 640
	var h := 480
	var placeholder_image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	placeholder_image.fill(Color(0.12, 0.14, 0.18, 1.0)) # dark background

	# Draw border rect
	for x in range(w):
		placeholder_image.set_pixel(x, 0, Color(0.3,0.34,0.4,1))
		placeholder_image.set_pixel(x, h-1, Color(0.3,0.34,0.4,1))
	for y in range(h):
		placeholder_image.set_pixel(0, y, Color(0.3,0.34,0.4,1))
		placeholder_image.set_pixel(w-1, y, Color(0.3,0.34,0.4,1))

	var placeholder_texture := ImageTexture.new()
	placeholder_texture.create_from_image(placeholder_image)
	webcam_feed.texture = placeholder_texture


func setup_mask_display() -> void:
	"""Setup the mask overlay display"""
	print("Setting up mask display...")

	# Create a placeholder mask texture (small)
	var mask_image = Image.create(200, 200, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color(0, 0, 0, 0)) # fully transparent

	for x in range(200):
		for y in range(200):
			var d = Vector2(x - 100, y - 100).length()
			if d < 60:
				mask_image.set_pixel(x, y, Color(0.9, 0.7, 0.5, 0.25))

	# Use static constructor for cross-version compatibility
	var mask_texture := ImageTexture.create_from_image(mask_image)
	mask_display.texture = mask_texture


func display_mask_info() -> void:
	"""Display information about the selected mask"""
	var mask_info := ""
	# safe-get selected_mask_type/id using Global if available
	var selected_type: String = ""   # <-- tambahkan tipe String, default kosong
	var selected_id: int = -1        # <-- tambahkan tipe Int, default -1
	# assume Global autoload exists in this project (other scripts reference it)
	# but use get() for safer property access
	if typeof(Global) != TYPE_NIL:
		selected_type = Global.get("selected_mask_type")
		selected_id = Global.get("selected_mask_id")

	if selected_type == "preset":
		mask_info = "Topeng Preset #" + str(selected_id)
		status_label.text = "Status: Menampilkan topeng preset"
	elif selected_type == "custom":
		# safe-get components from Global (use get so missing property yields null)
		var components = null
		if typeof(Global) != TYPE_NIL:
			components = Global.get("custom_mask_components")
		if components != null:
			# assume components has .base, .mata, .mulut (same structure as before)
			mask_info = "Topeng Custom (Base: %d, Mata: %d, Mulut: %d)" % [components.base, components.mata, components.mulut]
		else:
			mask_info = "Topeng Custom"
		status_label.text = "Status: Menampilkan topeng custom"
	else:
		mask_info = "Topeng: Tidak ada yang dipilih"
		status_label.text = "Status: Tidak ada topeng"

	mask_info_label.text = mask_info
	print("Displaying mask info: " + mask_info)

func _on_webcam_frame_received(texture: ImageTexture) -> void:
	if webcam_feed == null:
		return

	webcam_feed.texture = texture
	webcam_frames_received += 1

	# FPS tracking
	frame_count += 1
	var now = Time.get_ticks_msec()
	var elapsed = (now - last_time) / 1000.0
	if elapsed >= 1.0:
		fps = frame_count / elapsed
		fps_label.text = "FPS: %.2f" % fps
		frame_count = 0
		last_time = now

	# Update status label lebih jarang
	if (webcam_frames_received % 30) == 1:
		camera_status_label.text = "📹 Webcam aktif (%d frames)" % webcam_frames_received
		camera_status_label.modulate = Color(0, 1, 0, 0.9)

func _on_webcam_connection_changed(connected: bool) -> void:
	"""Handle webcam connection status changes"""
	print("Webcam connection changed: ", connected)
	if connected:
		camera_status_label.text = "✅ Webcam terhubung!"
		camera_status_label.modulate = Color(0, 1, 0, 0.9)
		status_label.text = "Status: Webcam siap dengan topeng"
	else:
		camera_status_label.text = "❌ Koneksi webcam terputus"
		camera_status_label.modulate = Color(1, 0, 0, 0.9)
		status_label.text = "Status: Menghubungkan ulang..."


func _on_webcam_error(message: String) -> void:
	"""Handle webcam errors"""
	print("Webcam error: ", message)
	camera_status_label.text = "❌ Error: " + message
	camera_status_label.modulate = Color(1, 0, 0, 0.9)
	status_label.text = "Status: " + message


func _on_pilih_topeng_button_pressed() -> void:
	"""Return to mask selection"""
	print("Pilih Topeng button pressed - returning to mask selection")
	cleanup_resources()
	get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengSelectionScene.tscn")


func _on_menu_utama_button_pressed() -> void:
	"""Return to main menu"""
	print("Menu Utama button pressed - returning to main menu")
	cleanup_resources()
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")


func cleanup_resources() -> void:
	"""Clean up webcam resources"""
	print("Cleaning up webcam resources...")

	if webcam_manager != null:
		# Try to tell the manager to disconnect from the server (if method exists)
		if webcam_manager.has_method("disconnect_from_server"):
			print("Calling webcam_manager.disconnect_from_server()")
			webcam_manager.disconnect_from_server()
		elif webcam_manager.has_method("disconnect_webcam"):
			# older/alternate name if present
			webcam_manager.disconnect_webcam()

		# free and nil the manager node
		webcam_manager.queue_free()
		webcam_manager = null
		print("Webcam manager cleaned up")


func _notification(what: int) -> void:
	"""Handle scene exit cleanup"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		cleanup_resources()


# ------------------ Custom Mask Helper ------------------
func send_custom_mask_from_global() -> void:
	"""
	Send custom mask configuration from Global to the server.
	This is called when the webcam scene loads and a custom mask is already selected.
	"""
	if Global.selected_mask_type != "custom":
		return
	
	var components = Global.custom_mask_components
	if components == null:
		print("⚠️ Custom mask type selected but no components found in Global")
		return
	
	var base_id = components.get("base", 0)
	var mata_id = components.get("mata", 0)
	var mulut_id = components.get("mulut", 0)
	
	print("Sending custom mask from Global to server: Base=%d, Mata=%d, Mulut=%d" % [base_id, mata_id, mulut_id])
	
	# Use the same networking logic as in TopengCustomizationController
	var server_host: String = "127.0.0.1"
	var server_port: int = 8888
	
	var udp = PacketPeerUDP.new()
	var err = udp.connect_to_host(server_host, server_port)
	if err != OK:
		print("❌ Failed to connect UDP to %s:%d (error %d)" % [server_host, server_port, err])
		return
	
	# Format: "SET_CUSTOM_MASK base_id,mata_id,mulut_id"
	var message := "SET_CUSTOM_MASK %d,%d,%d" % [base_id, mata_id, mulut_id]
	var packet := message.to_utf8_buffer()
	var send_err = udp.put_packet(packet)
	if send_err != OK:
		print("❌ Failed to send SET_CUSTOM_MASK packet (error %d)" % send_err)
		udp.close()
		return
	
	print("📤 Sent custom mask to server:", message)
	
	# Wait briefly for acknowledgment (non-blocking)
	for i in range(30):  # Wait up to ~0.5 seconds
		await get_tree().process_frame
		if udp.get_available_packet_count() > 0:
			var response_packet = udp.get_packet()
			var resp := response_packet.get_string_from_utf8()
			if resp != "":
				print("📥 Server response:", resp)
				if resp.begins_with("SET_CUSTOM_MASK_RECEIVED") or resp.begins_with("CUSTOM_MASK_SET:"):
					print("✅ Server acknowledged custom mask")
					break
	
	udp.close()
