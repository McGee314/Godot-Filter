extends Node

# Event bus singleton for decoupled communication
# Implements Observer Pattern with priority and filtering

# Event types
enum EventType {
	ARTIFACT_COLLECTED,
	CULTURAL_INFO_LEARNED,
	REGION_COMPLETED,
	NPC_INTERACTION,
	AUDIO_CHANGE,
	UI_UPDATE,
	PROGRESS_UPDATE,
	SESSION_UPDATE
}

# Event structure
class Event:
	var type: EventType
	var data: Dictionary
	var timestamp: float
	var priority: int
	var source: String
	
	func _init(event_type: EventType, event_data: Dictionary = {}, event_priority: int = 0, event_source: String = ""):
		type = event_type
		data = event_data
		timestamp = Time.get_unix_time_from_system()
		priority = event_priority
		source = event_source

# Observer structure
class Observer:
	var node: Node
	var callback: Callable
	var event_types: Array
	var priority: int
	
	func _init(observer_node: Node, observer_callback: Callable, types: Array = [], observer_priority: int = 0):
		node = observer_node
		callback = observer_callback
		event_types = types
		priority = observer_priority

# Event queue and observers
var event_queue: Array = []
var observers: Array = []
var max_queue_size: int = 100

# Statistics
var events_processed: int = 0
var events_dropped: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	_process_event_queue()

# Event emission
func emit_event(event_type: EventType, data: Dictionary = {}, priority: int = 0, source: String = ""):
	var event = Event.new(event_type, data, priority, source)
	
	# Add to queue
	event_queue.append(event)
	
	# Limit queue size
	if event_queue.size() > max_queue_size:
		event_queue.pop_front()
		events_dropped += 1
	
	# Process immediately for high priority events
	if priority > 5:
		_process_event(event)

# Legacy signal compatibility
func emit_artifact_collected(artifact_name: String, region: String):
	emit_event(EventType.ARTIFACT_COLLECTED, {
		"artifact_name": artifact_name,
		"region": region
	}, 1, "artifact_system")

func emit_cultural_info_learned(info: String, region: String):
	emit_event(EventType.CULTURAL_INFO_LEARNED, {
		"info": info,
		"region": region
	}, 1, "info_system")

func emit_region_completed(region: String):
	emit_event(EventType.REGION_COMPLETED, {
		"region": region
	}, 2, "progress_system")

func emit_npc_interaction(npc_name: String, region: String):
	emit_event(EventType.NPC_INTERACTION, {
		"npc_name": npc_name,
		"region": region
	}, 1, "npc_system")

func emit_audio_change(region: String, audio_type: String):
	emit_event(EventType.AUDIO_CHANGE, {
		"region": region,
		"audio_type": audio_type
	}, 3, "audio_system")

func emit_ui_update(update_type: String, data: Dictionary = {}):
	emit_event(EventType.UI_UPDATE, {
		"update_type": update_type,
		"data": data
	}, 4, "ui_system")

func emit_progress_update(progress_data: Dictionary):
	emit_event(EventType.PROGRESS_UPDATE, {
		"progress": progress_data
	}, 2, "progress_system")

func emit_session_update(update_type: String, data: Dictionary = {}):
	emit_event(EventType.SESSION_UPDATE, {
		"update_type": update_type,
		"data": data
	}, 5, "session_system")

# Observer registration
func subscribe(observer: Node, callback: Callable, event_types: Array[EventType] = [], priority: int = 0):
	var new_observer = Observer.new(observer, callback, event_types, priority)
	observers.append(new_observer)
	
	# Sort observers by priority (higher priority first)
	observers.sort_custom(func(a, b): return a.priority > b.priority)

func unsubscribe(observer: Node):
	observers = observers.filter(func(obs): return obs.node != observer)

# Event processing
func _process_event_queue():
	while not event_queue.is_empty():
		var event = event_queue.pop_front()
		_process_event(event)

func _process_event(event: Event):
	events_processed += 1
	
	# Find observers for this event type
	var relevant_observers = observers.filter(func(obs): 
		return obs.event_types.is_empty() or event.type in obs.event_types
	)
	
	# Notify observers
	for observer in relevant_observers:
		if is_instance_valid(observer.node):
			# Call the callback safely
			observer.callback.call(event)
		else:
			# Remove invalid observers
			observers.erase(observer)

# Event filtering and querying
func get_events_by_type(event_type: EventType, limit: int = 10) -> Array[Event]:
	var filtered_events: Array[Event] = []
	
	for event in event_queue:
		if event.type == event_type:
			filtered_events.append(event)
			if filtered_events.size() >= limit:
				break
	
	return filtered_events

func get_events_by_source(source: String, limit: int = 10) -> Array[Event]:
	var filtered_events: Array[Event] = []
	
	for event in event_queue:
		if event.source == source:
			filtered_events.append(event)
			if filtered_events.size() >= limit:
				break
	
	return filtered_events

func get_events_by_priority(min_priority: int, limit: int = 10) -> Array[Event]:
	var filtered_events: Array[Event] = []
	
	for event in event_queue:
		if event.priority >= min_priority:
			filtered_events.append(event)
			if filtered_events.size() >= limit:
				break
	
	return filtered_events

# Statistics and debugging
func get_statistics() -> Dictionary:
	return {
		"events_processed": events_processed,
		"events_dropped": events_dropped,
		"queue_size": event_queue.size(),
		"observer_count": observers.size()
	}

func clear_queue():
	event_queue.clear()

func clear_statistics():
	events_processed = 0
	events_dropped = 0

# Cleanup
func _exit_tree():
	observers.clear()
	event_queue.clear()
