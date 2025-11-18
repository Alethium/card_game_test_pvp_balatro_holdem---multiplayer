class_name MultiplayerPlayer
extends Node2D


# PLAYER info
var display_name : String

var starting_health = 100
var remaining_health : int

var starting_mana = 0
var current_mana : int

enum HAND_STATE {point,grab}

var direction : Vector2
var player_position : int

@onready var hand_cursor: HandCursor = $Hand_Cursor
@onready var player_hand: Node2D = $player_hand
@onready var curr_hand_state = 0

# player card info
var current_slots = []
var discarding = false
var discard_count = 2
var max_hand_size = 5
var current_hand_size = 0

#player state controls
enum PLAYER_STATE {dealer,in_play,out_of_play}

enum BET_STATE {stay,see,raise,fold,none}
#var bet_state : BET_STATE

var active_turn = false

var empty_slots = 5
var selected_cards : Array[Card]
var hand_to_play : Array[Card]
var current_hand : Array[Card] 
var number_of_cards_selected = 0

@onready var input_synchronizer: MultiplayerSynchronizer = %input_synchronizer

# UI ELEMENTS
@onready var current_hand_display: Label = $Control/Buttons_panel/current_hand
@onready var score_display: Label = $Control/Buttons_panel/Score
@onready var player_role_marker_position: Node2D = $player_role_marker_position
@onready var mouse_window_detection: Node = $mouse_window_detection
@onready var status_text: Label = $Control/Buttons_panel/status_text

var screen_size


var button1_pressed = false
var button2_pressed = false
var button3_pressed = false
var action_button_pressed = false

#@onready var action_btn_text = %Action_Button.text

@onready var action_button: Button = %Action_Button
@onready var button1: Button = %Button1
@onready var button2: Button = %Button2
@onready var button3: Button = %Button3
# connect signals when player joins the game. 

@onready var button_container = $Control


var signals_connected
signal player_added


var current_chips : Array[Chip]
const CHIP = preload("res://Scenes/chip.tscn")
const CARD_SLOT = preload("res://Scenes/card_slot.tscn")

@export var bet_state : BET_STATE = BET_STATE.none :
	set(state):
		bet_state = state


@export var player_id := 1:
	set(id):
		player_id = id
		%input_synchronizer.set_multiplayer_authority(id)
		
@export var is_ready: bool = false:
	set(value):
		is_ready = value
		

@export var has_bet: bool = false:
	set(value):
		has_bet = value
		



func _ready() -> void:
	if multiplayer.get_unique_id() != player_id:
		#%Control.visible = false
		%Control.mouse_filter =Control.MOUSE_FILTER_IGNORE
		%mini_avatar.visible = false
		%Avatar.visible = true
		%external_status.visible = true
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
		
func _on_action_button_pressed() -> void:
	
	if multiplayer.get_unique_id() == player_id:
		#toggle_ready()
		request_action_button_press.rpc()
		print("player action button pressed : ", player_id)


@rpc ("any_peer","call_local", "reliable")
func request_action_button_press():	
	if multiplayer.is_server():
		print("player : ", player_id, " action button pressed : ", action_button_pressed)
		
		if action_button_pressed == false:
			set_action_button_pressed.rpc(true)
		elif action_button_pressed == true:
			set_action_button_pressed.rpc(false)
	return

@rpc("any_peer", "call_local", "reliable")
func set_action_button_pressed(button: bool):
	if multiplayer.is_server():
		action_button_pressed = button
		print("player : ", player_id, " action button pressed : ", action_button_pressed)	
		#set_action_button_text()		
		
		
func _on_button1_pressed() -> void:
	if multiplayer.get_unique_id() == player_id:
		request_button1_press.rpc()
		print("button 1 pressed  from player : " , player_id)
		
@rpc ("any_peer","call_local", "reliable")
func request_button1_press():	
	if multiplayer.is_server():
		print("player : ", player_id, " button 1 pressed : ", button1_pressed)
		
		if button1_pressed == false:
			set_button1_pressed.rpc(true)
		elif button1_pressed == true:
			set_button1_pressed.rpc(false)
	
@rpc("any_peer", "call_local", "reliable")
func set_button1_pressed(button: bool):
	
	button1_pressed = button
	print("player : ", player_id, " button 1 pressed : ", button1_pressed)	







		
func _on_button2_pressed() -> void:
	if multiplayer.get_unique_id() == player_id:
		request_button2_press.rpc()
		print("button 2 pressed signal sent from player : " , player_id)
		
@rpc ("any_peer","call_local", "reliable")
func request_button2_press():	
	if multiplayer.is_server():
		print("player : ", player_id, " button 2 pressed : ", button2_pressed)
		
		if button2_pressed == false:
			set_button2_pressed.rpc(true)
		elif button2_pressed == true:
			set_button2_pressed.rpc(false)
	
@rpc("any_peer", "call_local", "reliable")
func set_button2_pressed(button: bool):
	
	button2_pressed = button
	print("player : ", player_id, " button 2 pressed : ", button2_pressed)	


		
func _on_button3_pressed() -> void:
	if multiplayer.get_unique_id() == player_id:
		request_button3_press.rpc()
		print("button 3 pressed signal sent from player : " , player_id)
		
@rpc ("any_peer","call_local", "reliable")
func request_button3_press():	
	if multiplayer.is_server():
		print("player : ", player_id, " button 3 pressed : ", button3_pressed)
		
		if button3_pressed == false:
			set_button3_pressed.rpc(true)
		elif button3_pressed == true:
			set_button3_pressed.rpc(false)
	
@rpc("any_peer", "call_local", "reliable")
func set_button3_pressed(button: bool):
	
	button3_pressed = button
	print("player : ", player_id, " button 3 pressed : ", button3_pressed)			







	
@rpc("any_peer", "call_local", "reliable")	
func set_button_text(button,text):
	if button == "action_button":
		%Action_Button.text = text
	
	if button == "button1":
		%Button1.text = text
	
	if button == "button2":
		%Button2.text = text
		
	if button == "button3":
		%Button3.text = text




func toggle_ready():
		print("player : ", player_id, " is ready")			
		
		if !is_ready:
			request_player_ready.rpc()
		else:
			request_player_unready.rpc()



@rpc ("any_peer","call_local", "reliable")
func request_player_ready():
	if multiplayer.is_server():
		print("player : ", player_id, " is ready")
		set_player_ready.rpc(true)
		#status_text.text = str( "ready? : ", is_ready)

@rpc ("any_peer","call_local", "reliable")
func request_player_unready():
	if multiplayer.is_server():
		print("player : ", player_id, " is not ready")
		set_player_ready.rpc(false)
		#status_text.text = str( "ready? : ", is_ready)

@rpc("any_peer", "call_local", "reliable")
func set_player_ready(ready_state: bool):
	is_ready = ready_state
	# This will automatically call the setter and update_ready_display()
@rpc("any_peer", "call_local", "reliable")
func set_player_bet_state(new_bet_state: BET_STATE):
	bet_state = new_bet_state
	
	
func update_ready_display():
	if status_text:
		status_text.text = "READY: " + str(is_ready)
	
	# Optional: Visual feedback like color change
		if is_ready:
			%Avatar.modulate = Color.GREEN
			#%mini_avatar.modulate = Color.GREEN
			status_text.modulate = Color.GREEN
		else:
			status_text.modulate = Color.WHITE
			%Avatar.modulate = Color.WHITE
			#%mini_avatar.modulate = Color.WHITE





@rpc ("any_peer","call_local", "reliable")
func request_player_bet():	
	if multiplayer.is_server():
		print("player : ", player_id, " is betting")
		set_player_bet.rpc(true)
	
@rpc("any_peer", "call_local", "reliable")
func set_player_bet(bet_state: bool):
	has_bet = bet_state	
	%Button1.text = "BET"
	

		
		
		
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


@rpc("any_peer", "call_local", "reliable")			
func clear_community_discards_from_selection():
	#print("removing player %s cards : player id  :  ",% player_id)	
	print(%input_synchronizer.selected_cards)
	%input_synchronizer.selected_cards = %input_synchronizer.selected_cards.filter(
	func(card): return card.owner_id != -1
	)
	
	
@rpc("any_peer", "call_local", "reliable")			
func clear_player_selection():
	#print("removing player %s cards : player id  :  ",% player_id)	
	print(%input_synchronizer.selected_cards)
	%input_synchronizer.selected_cards = []
	
	
	
	
	
	
	
	
