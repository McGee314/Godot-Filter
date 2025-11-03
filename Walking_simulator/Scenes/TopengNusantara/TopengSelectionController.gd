# TopengSelectionController.gd
extends Control

@onready var pilih_button = $MainContainer/ButtonContainer/PilihButton

# Mask buttons
@onready var face1_button = $MainContainer/MaskContainer/GridContainer/Face1Container/Face1Button
@onready var face2_button = $MainContainer/MaskContainer/GridContainer/Face2Container/Face2Button
@onready var face3_button = $MainContainer/MaskContainer/GridContainer/Face3Container/Face3Button
@onready var face4_button = $MainContainer/MaskContainer/GridContainer/Face4Container/Face4Button
@onready var face5_button = $MainContainer/MaskContainer/GridContainer/Face5Container/Face5Button
@onready var face6_button = $MainContainer/MaskContainer/GridContainer/Face6Container/Face6Button
@onready var face7_button = $MainContainer/MaskContainer/GridContainer/Face7Container/Face7Button
@onready var custom_button = $MainContainer/MaskContainer/GridContainer/CustomContainer/CustomButton

var selected_mask_id: int = -1
var is_custom_selected: bool = false
var mask_buttons: Array[Button] = []

# ----------------- UDP config (edit if needed) -----------------
var server_host: String = "127.0.0.1"
var server_port: int = 8888

# How many frames to wait for server ack (frames, not seconds).
# At 60 FPS, 60 frames ≈ 1 second; increase if your machine slower.
var mask_ack_timeout_frames: int = 60

# ----------------- Mapping mask id -> filename -----------------
# Adjust filenames to match files in "Webcam Server/mask/" folder.
# You may use subpaths like "c1/e.png" if a mask is in a subfolder.
var mask_files := {
	1: "panji3.png",
	2: "sumatra.png",
	3: "hudoq.png",
	4: "kelana.png",
	5: "prabu.png",
	6: "betawi.png",
	7: "bali.png"	
}
# ----------------------------------------------------------------

func _ready():
	print("=== TopengSelectionController._ready() ===")

	# Store all mask buttons in array for easier management
	mask_buttons = [face1_button, face2_button, face3_button, face4_button, face5_button, face6_button, face7_button, custom_button]

	# Verify all buttons are properly loaded
	for i in range(mask_buttons.size()):
		if mask_buttons[i] == null:
			print("ERROR: Button %d is null!" % (i + 1))
		else:
			print("Button %d loaded successfully" % (i + 1))

	# Initially disable the Pilih button until something is selected
	pilih_button.disabled = true
	print("Pilih button initially disabled: %s" % pilih_button.disabled)

	# Set custom button appearance
	custom_button.text = "+"

	print("Topeng Selection scene initialized")


func _on_face_button_pressed(face_id: int):
	"""Handle preset face button press"""
	print("Face %d button pressed" % face_id)

	selected_mask_id = face_id
	is_custom_selected = false

	# Update button appearances
	update_button_selection()

	# Enable the Pilih button
	pilih_button.disabled = false
	print("Pilih button enabled - disabled status: %s" % pilih_button.disabled)


func _on_custom_button_pressed():
	"""Handle custom button press"""
	print("Custom button pressed")

	selected_mask_id = -1
	is_custom_selected = true

	# Update button appearances
	update_button_selection()

	# Enable the Pilih button
	pilih_button.disabled = false
	print("Pilih button enabled for custom - disabled status: %s" % pilih_button.disabled)


func update_button_selection():
	"""Update visual appearance of buttons to show selection"""
	# Reset all buttons to normal appearance
	for button in mask_buttons:
		button.modulate = Color.WHITE

	# Highlight selected button
	if is_custom_selected:
		custom_button.modulate = Color.GREEN
		print("Custom button highlighted")
	elif selected_mask_id > 0 and selected_mask_id <= 7:
		mask_buttons[selected_mask_id - 1].modulate = Color.GREEN
		print("Face %d button highlighted" % selected_mask_id)


func _on_pilih_button_pressed():
	"""Handle Pilih button press"""
	print("=== Pilih button pressed ===")
	print("is_custom_selected: %s" % is_custom_selected)
	print("selected_mask_id: %d" % selected_mask_id)

	if is_custom_selected:
		print("Going to customization scene")
		# Pass data that this came from custom selection
		Global.selected_mask_type = "custom"
		Global.selected_mask_id = -1
		get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengCustomizationScene.tscn")

	elif selected_mask_id > 0:
		print("Going to webcam scene with mask ID: %d" % selected_mask_id)
		# Pass data that this is a preset mask
		Global.selected_mask_type = "preset"
		Global.selected_mask_id = selected_mask_id

		# --- NEW: send mask command to server and wait briefly for ack (non-blocking)
		if mask_files.has(selected_mask_id):
			var mask_name: String = mask_files[selected_mask_id]
			# send_mask_to_server is async; we await its completion but UI remains responsive
			var ok := await send_mask_to_server(mask_name)
			print("send_mask_to_server returned:", ok)
		else:
			print("⚠️ No filename mapped for mask id %d" % selected_mask_id)

		# Change to webcam scene (stream will reflect mask when server applied it)
		get_tree().change_scene_to_file("res://Scenes/TopengNusantara/TopengWebcamScene.tscn")
	else:
		print("No mask selected - this should not happen")


func _on_back_button_pressed():
	"""Return to main menu"""
	print("Back button pressed - returning to main menu")
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")


# ------------------ Networking helper ------------------
func send_mask_to_server(mask_filename: String) -> bool:
	"""
	Send "SET_MASK <mask_filename>" to UDP server and wait shortly for an ACK.
	This function is asynchronous (caller should `await send_mask_to_server(...)`).
	Returns `true` if server acknowledged (SET_MASK_RECEIVED or MASK_SET:...), otherwise false.
	"""
	var udp := PacketPeerUDP.new()
	var err = udp.connect_to_host(server_host, server_port)
	if err != OK:
		print("❌ UDP connect_to_host failed:", err)
		udp.close()
		return false

	var message := "SET_MASK " + mask_filename
	var send_result = udp.put_packet(message.to_utf8_buffer())
	if send_result != OK:
		print("❌ Failed to send SET_MASK packet:", send_result)
		udp.close()
		return false

	print("📤 Sent to server:", message)

	# wait up to mask_ack_timeout_frames frames for response from server
	var got_ack: bool = false
	var ack_msg: String = ""
	for i in range(mask_ack_timeout_frames):
		# yield for a single frame (non-blocking)
		await get_tree().process_frame
		# check for any response packet
		if udp.get_available_packet_count() > 0:
			var packet = udp.get_packet()
			# match usage in WebcamManagerUDP.gd: packet is PackedByteArray, use get_string_from_utf8()
			var resp := packet.get_string_from_utf8()
			if resp == "":
				continue
			print("📥 Server response:", resp)
			# Check known responses
			if resp.begins_with("SET_MASK_RECEIVED") or resp.begins_with("MASK_SET:"):
				got_ack = true
				ack_msg = resp
				break
			elif resp.begins_with("ERR_"):
				ack_msg = resp
				break
			else:
				# Unknown reply — log and continue waiting briefly
				print("🔍 Unexpected server reply:", resp)

	# cleanup UDP socket
	udp.close()

	if got_ack:
		print("✅ Server acknowledged SET_MASK:", ack_msg)
		return true
	else:
		if ack_msg != "":
			print("⚠️ Server returned error while setting mask:", ack_msg)
		else:
			print("⚠️ No ACK from server for SET_MASK within timeout (%d frames)" % mask_ack_timeout_frames)
		return false
