# WebcamManagerUDP.gd
extends Node

signal frame_received(texture: ImageTexture)
signal connection_changed(connected: bool)
signal error_message(message: String)

var udp_client: PacketPeerUDP
var is_connected: bool = false
var server_host: String = "127.0.0.1"
var server_port: int = 8888

# Optimized frame assembly
var frame_buffers: Dictionary = {}
var last_completed_sequence: int = 0
var frame_timeout: float = 0.5  # seconds

# Optimized performance monitoring
var frame_count: int = 0
var packets_received: int = 0
var frames_completed: int = 0
var frames_dropped: int = 0

# Processing optimization
var max_packets_per_frame: int = 10  # Limit packet processing per frame

# Sequence handling (auto-detect modulus: prefer 16-bit wrap if observed)
const SEQ_MOD_16 := 1 << 16
const SEQ_MOD_32 := 1 << 32
var seq_mod: int = 0  # determined on first packet
var max_outstanding_frames: int = 30  # cap how many partial frames we keep

func _ready():
	udp_client = PacketPeerUDP.new()
	print("🎮 Optimized UDP client ready")

func connect_to_webcam_server():
	if is_connected:
		return

	print("🔄 Connecting to optimized server...")

	var error = udp_client.connect_to_host(server_host, server_port)
	if error != OK:
		_emit_error("UDP setup failed: " + str(error))
		return

	var registration_message = "REGISTER".to_utf8_buffer()
	var send_result = udp_client.put_packet(registration_message)

	if send_result != OK:
		_emit_error("Registration failed: " + str(send_result))
		return

	print("📤 Registration sent...")

	# Optimized waiting with shorter timeout
	var timeout = 0
	var max_timeout = 90  # ~1.5 seconds at 60 fps
	var confirmed = false

	while timeout < max_timeout and not confirmed:
		await get_tree().process_frame
		timeout += 1

		# consume only text ACKs here; binary frames will produce empty string
		if udp_client.get_available_packet_count() > 0:
			var packet = udp_client.get_packet()
			var message = packet.get_string_from_utf8()
			if message == "REGISTERED":
				confirmed = true
				print("✅ Connected to optimized server!")

	if confirmed:
		is_connected = true
		connection_changed.emit(true)
		set_process(true)
		_reset_stats()
	else:
		_emit_error("Connection timeout")
		udp_client.close()

func _process(_delta):
	if not is_connected:
		return

	# Optimized packet processing - limit per frame
	var processed = 0
	while processed < max_packets_per_frame and udp_client.get_available_packet_count() > 0:
		var packet = udp_client.get_packet()
		if packet.size() >= 12:
			packets_received += 1
			process_packet(packet)
		processed += 1

	# Less frequent cleanup
	if packets_received > 0 and packets_received % 30 == 0:
		cleanup_old_frames()

func process_packet(packet: PackedByteArray):
	if packet.size() < 12:
		return

	var sequence_number = bytes_to_int(packet.slice(0, 4))
	var total_packets = bytes_to_int(packet.slice(4, 8))
	var packet_index = bytes_to_int(packet.slice(8, 12))
	var packet_data = packet.slice(12)

	# Quick validation
	if total_packets <= 0 or packet_index >= total_packets:
		return

	# auto-detect sequence modulus on first observed sequence numbers
	if seq_mod == 0:
		# Heuristic: if sequence fits in 16-bit space, prefer 16-bit wrap; else 32-bit
		if sequence_number <= 0xFFFF:
			seq_mod = SEQ_MOD_16
		else:
			seq_mod = SEQ_MOD_32

	# Reject obviously invalid sequence (negative/zero handled as unsigned)
	# Note: we allow sequence_number == 0 (server may use 0) — treat using wrap logic
	# Handle duplicates and out-of-order with wrap-aware comparison
	if last_completed_sequence != 0:
		if sequence_number == last_completed_sequence:
			# duplicate of already completed frame: ignore
			return
		if not _seq_is_newer(sequence_number, last_completed_sequence):
			# older frame (considering wrap): ignore
			return

	# Initialize buffer efficiently
	if sequence_number not in frame_buffers:
		# enforce max outstanding frames to avoid memory blowup
		_purge_if_exceed()
		frame_buffers[sequence_number] = {
			"total_packets": total_packets,
			"received_packets": 0,
			"data_parts": {},
			"timestamp": Time.get_ticks_msec() / 1000.0
		}

	var frame_buffer = frame_buffers[sequence_number]

	# Add packet if new
	if packet_index not in frame_buffer.data_parts:
		frame_buffer.data_parts[packet_index] = packet_data
		frame_buffer.received_packets += 1

		# Check completion
		if frame_buffer.received_packets == frame_buffer.total_packets:
			assemble_and_display_frame(sequence_number)

func assemble_and_display_frame(sequence_number: int):
	if sequence_number not in frame_buffers:
		return

	var frame_buffer = frame_buffers[sequence_number]
	var frame_data = PackedByteArray()

	# Quick assembly in-order; drop frame if any packet missing
	for i in range(frame_buffer.total_packets):
		if i in frame_buffer.data_parts:
			frame_data.append_array(frame_buffer.data_parts[i])
		else:
			frames_dropped += 1
			frame_buffers.erase(sequence_number)
			return

	# Completed successfully
	frame_buffers.erase(sequence_number)
	last_completed_sequence = sequence_number
	frames_completed += 1

	display_frame(frame_data)

	# Less frequent logging
	if frames_completed % 60 == 0 and frames_completed > 0:
		var drop_rate = float(frames_dropped) / float(frames_completed + frames_dropped) * 100.0
		print("📊 Frames: %d, Drop rate: %.1f%%" % [frames_completed, drop_rate])

func cleanup_old_frames():
	var current_time = Time.get_ticks_msec() / 1000.0
	var to_remove: Array = []

	for seq_num in frame_buffers.keys():
		if current_time - frame_buffers[seq_num].timestamp > frame_timeout:
			to_remove.append(seq_num)
			frames_dropped += 1

	for seq_num in to_remove:
		frame_buffers.erase(seq_num)

func bytes_to_int(bytes: PackedByteArray) -> int:
	# Expecting 4 bytes (big-endian unsigned)
	if bytes.size() != 4:
		return 0
	return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3]

func display_frame(frame_data: PackedByteArray):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(frame_data)

	if error == OK:
		# Create texture in the recommended cross-version way
		var texture: ImageTexture = ImageTexture.create_from_image(image)
		frame_received.emit(texture)
		frame_count += 1

		# Log only first frame dimensions
		if frame_count == 1:
			print("✅ Video stream active: %dx%d" % [image.get_width(), image.get_height()])
	else:
		print("❌ Frame decode error: ", error)
		# Attempt to free malformed data (defensive)
		frames_dropped += 1

func disconnect_from_server():
	if is_connected:
		var unregister_message = "UNREGISTER".to_utf8_buffer()
		udp_client.put_packet(unregister_message)

	is_connected = false
	udp_client.close()
	frame_buffers.clear()
	connection_changed.emit(false)
	set_process(false)
	_reset_stats()

func _reset_stats():
	frame_count = 0
	packets_received = 0
	frames_completed = 0
	frames_dropped = 0

func get_connection_status() -> bool:
	return is_connected

func _emit_error(message: String):
	print("WebcamManager Error: " + message)
	error_message.emit(message)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		disconnect_from_server()

# ------------------ helper utilities ------------------

func _seq_is_newer(a: int, b: int) -> bool:
	"""
	Wrap-aware "is 'a' newer than 'b'?" comparison.
	Assumes seq_mod has been set (auto-detected). If not set, assume 16-bit wrap.
	"""
	if b == 0:
		return true
	var mod = seq_mod if seq_mod != 0 else SEQ_MOD_16
	var diff = (a - b + mod) % mod
	return diff != 0 and diff < int(mod / 2)

func _purge_if_exceed():
	# If we exceed max_outstanding_frames, purge oldest entries by timestamp
	if frame_buffers.size() <= max_outstanding_frames:
		return

	# Build sortable list of {seq, ts}
	var items: Array = []
	for k in frame_buffers.keys():
		items.append({"seq": k, "ts": frame_buffers[k].timestamp})

	# sort ascending by timestamp using a Callable
	items.sort_custom(Callable(self, "_compare_items_by_ts"))

	var to_remove_count = frame_buffers.size() - max_outstanding_frames
	for i in range(to_remove_count):
		var seq_to_rm = items[i]["seq"]
		if seq_to_rm in frame_buffers:
			frame_buffers.erase(seq_to_rm)
			frames_dropped += 1

func _compare_items_by_ts(a, b):
	if a["ts"] < b["ts"]:
		return -1
	elif a["ts"] > b["ts"]:
		return 1
	return 0
