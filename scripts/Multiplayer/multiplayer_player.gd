class_name MultiplayerPlayer
extends Node2D
@onready var input_synchronizer: MultiplayerSynchronizer = %input_synchronizer



@onready var player_hand: Node2D = $player_hand

@onready var current_hand_display: Label = $Control/current_hand
@onready var score_display: Label = $Control/Score
@onready var player_role_marker_position: Node2D = $player_role_marker_position
@onready var mouse_window_detection: Node = $mouse_window_detection
var discarding = false
enum HandState {point,grab}
var display_name : String
@onready var curr_hand_state = 0
var max_hand_size = 5
var current_hand_size = 0

var discard_count = 2

var current_slots = []

var starting_health = 100
var remaining_health : int

var current_chips : Array[Chip]
const CHIP = preload("res://Scenes/chip.tscn")
@onready var ready_text: Label = $Control/ready_text

var starting_mana = 0
var current_mana : int

var active_turn = false

var empty_slots = 5


@onready var hand_cursor: HandCursor = $Hand_Cursor

const CARD_SLOT = preload("res://Scenes/card_slot.tscn")
var selected_cards : Array[Card]
var hand_to_play : Array[Card]
var current_hand : Array[Card] 
var number_of_cards_selected = 0
var screen_size

signal player_added


@onready var button_container = $Control

@export var player_id := 1:
	set(id):
		player_id = id
		%input_synchronizer.set_multiplayer_authority(id)
		
@export var is_ready: bool = false:
	set(value):
		is_ready = value
		update_ready_display()

var direction : Vector2
var player_position : int


func _ready() -> void:
	if multiplayer.get_unique_id() != player_id:
		%Control.visible = false
		%Control.mouse_filter =Control.MOUSE_FILTER_IGNORE
		%mini_avatar.visible = false
		%Avatar.visible = true
	else:
		%mini_avatar.visible = true
		%Avatar.visible = false
		
	screen_size = get_viewport_rect().size
	player_added.emit(self)
	current_hand = []
	curr_hand_state = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	update_ready_display()
	
	

func _physics_process(delta: float) -> void:
	
	
	if multiplayer.is_server():
		update_input(delta) 
		

 
func _input(event: InputEvent) -> void:
	if multiplayer.get_unique_id() == player_id:

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				#print("player %s requesting click" % player_id)
				#player_request_click.emit(player_id,%input_synchronizer.player_mouse_cursor_position)
				#send a request to the server for a click of the mouse. 
				
				%input_synchronizer.click()
			else:	
				%input_synchronizer.unclick()

func update_input(_delta):
	#hand_cursor.global_position += %input_synchronizer.player_mouse_cursor_direction
	#is_ready = %input_synchronizer.is_ready
	hand_cursor.global_position = %input_synchronizer.player_mouse_cursor_position
	
	#also transfer clicking code from cardmanager over here
	
func get_current_hand():
	var hand = []
	for slot in get_slots():
		hand.append(slot.stored_cards[0])
	return hand
			
func get_slots():
	return player_hand.get_children()
	
func get_current_slot_target_pos():
	for slot in get_slots():
		if slot.stored_cards.size() == 0:
			return slot.global_position
			
func add_slot():
	var new_slot = CARD_SLOT.instantiate()
	current_slots.push_front(new_slot)
	player_hand.add_child(new_slot)
	current_hand_size += 1
	new_slot.global_position = player_hand.global_position
	return new_slot

func remove_slot(slot):
	current_hand_size -= 1
	current_slots.erase(slot)
	slot.queue_free()

func handle_hand_slots(delta):
	# Calculate the center position in local space (relative to player)
	var local_center_x = -700 + (current_slots.size() * 125)
	
	for i in current_slots.size():
		# Calculate each card's position in local space
		var local_x_offset = local_center_x - (i * 140)
		var local_target_pos = Vector2(local_x_offset, 0)
		
		# Convert local position to global space, applying player's rotation
		var global_target_pos = to_global(local_target_pos)
		
		current_slots[i].global_position = lerp(
			current_slots[i].global_position,
			global_target_pos,
			delta * 10
		)
		
		# Rotate cards to match player orientation
		current_slots[i].global_rotation = global_rotation
		
func _on_ready_button_pressed() -> void:
	
	if multiplayer.get_unique_id() == player_id:
		print("player ready button pressed")
		if !is_ready:
			request_player_ready.rpc()
		else:
			request_player_unready.rpc()






@rpc ("any_peer","call_local", "reliable")
func request_player_ready():
	if multiplayer.is_server():
		print("player : ", player_id, " is ready")
		set_player_ready.rpc(true)
		#ready_text.text = str( "ready? : ", is_ready)

	
@rpc ("any_peer","call_local", "reliable")
func request_player_unready():
	if multiplayer.is_server():
		print("player : ", player_id, " is not ready")
		set_player_ready.rpc(false)
		#ready_text.text = str( "ready? : ", is_ready)

@rpc("any_peer", "call_local", "reliable")
func set_player_ready(ready_state: bool):
	is_ready = ready_state
	# This will automatically call the setter and update_ready_display()

func update_ready_display():
	if ready_text:
		ready_text.text = "READY: " + str(is_ready)
	
	# Optional: Visual feedback like color change
		if is_ready:
			ready_text.modulate = Color.GREEN
		else:
			ready_text.modulate = Color.WHITE
	



	
#@rpc("any_peer","reliable")	
#func request_player_ready():
	#print("player ready requested")
	#if multiplayer.is_server():
		#server_player_ready.rpc()
	#else:
		#request_player_ready.rpc_id(1)
#
#
#@rpc("any_peer", "call_local", "reliable")	
#func server_player_ready():
	#if multiplayer.is_server():	
		#if !is_ready:
			#print("player : ", player_id, " is ready")
			#is_ready = true
#
		#else:
			#print("player : ", player_id, " is not ready")
			#is_ready = false
