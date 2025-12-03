class_name MultiplayerPlayer
extends Node2D


# PLAYER info
var display_name : String

var starting_health = 100
var current_health : int = 100
var excess : int = 0
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
var current_score : int = 0
#player state controls
enum PLAYER_STATE {dealer,in_play,out_of_play}
var play_state : PLAYER_STATE = PLAYER_STATE.in_play
enum BET_STATE {stay,see,raise,fold,none}
var current_bet = 0


@onready var health_meter: HealthMeter = $health_meter

#var bet_state : BET_STATE

var empty_slots = 5
var selected_cards = []
var hand_to_play : Array[Card]
var current_hand : Array[Card] 
var number_of_cards_selected = 0

@onready var input_synchronizer: MultiplayerSynchronizer = %input_synchronizer

# UI ELEMENTS
@onready var current_hand_display: Label = $Control/Buttons_panel/current_hand
@onready var score_display: PlayerScoreDisplay = $Control/Score_Display

@onready var player_role_marker_position: Node2D = $player_role_marker_position
@onready var mouse_window_detection: Node = $mouse_window_detection
@onready var status_text: Label = $Control/Buttons_panel/status_text
@onready var hp_label: Label = $health_meter/Label

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


@export var active_player : bool = false:
	set(value):
		active_player = value


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
		hand_cursor.visible = false
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
	 
	hp_label.text = str(current_health)
	
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


func on_player_join():
	if multiplayer.get_unique_id() == player_id:
		print("player_joined : " ,multiplayer.get_unique_id())
		%Game_Status_text.text = "textfuck"
	pass
	
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
func set_button_visibility(button,visible):
	if button == "action_button":
		%Action_Button.visible = visible
	
	if button == "button1":
		%Button1.visible = visible
	
	if button == "button2":
		%Button2.visible = visible
		
	if button == "button3":
		%Button3.visible = visible




	
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

@rpc("any_peer", "call_local", "reliable")	
func set_button_disabled(button,state):
	if button == "action_button":
		%Action_Button.disabled = state
		if state == true:
			%Action_Button.focus_mode = 0
			%Action_Button.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_IGNORE)
			
		else:
			%Action_Button.focus_mode = 1
			%Action_Button.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_STOP)	
	if button == "button1":
		%Button1.disabled = state
		if state == true:
			%Button1.focus_mode = 0
			%Button1.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_IGNORE)
			
		else:
			%Button1.focus_mode = 1
			%Button1.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_STOP)
	
	if button == "button2":
		%Button2.disabled = state
		if state == true:
			%Button2.focus_mode = 0
			%Button1.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_IGNORE)
			
		else:
			%Button2.focus_mode = 1
			%Button1.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_STOP)
		
	if button == "button3":
		%Button3.disabled = state
		if state == true:
			%Button3.focus_mode = 0
			%Button1.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_IGNORE)
			
		else:
			%Button3.focus_mode = 1
			%Button1.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_STOP)



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


@rpc("any_peer", "call_local", "reliable")
func request_player_play_state(new_play_state: String):
	if multiplayer.is_server():
		if new_play_state == "out":
			set_player_play_state(PLAYER_STATE.out_of_play)
		elif new_play_state == "in":
			set_player_play_state(PLAYER_STATE.in_play)
		elif new_play_state == "dealer":
			set_player_play_state(PLAYER_STATE.dealer)
			



	
@rpc("any_peer", "call_local", "reliable")
func set_player_play_state(new_play_state: PLAYER_STATE):
	play_state = new_play_state	

#@rpc ("any_peer","call_local", "reliable")
#func request_player_bet():	
	#if multiplayer.is_server():
		#print("player : ", player_id, " is betting")
		#set_player_bet.rpc(true)
		#
	#
#@rpc("any_peer", "call_local", "reliable")
#func set_player_bet(new_bet_state: bool):
	#has_bet = new_bet_state	
	#%Button1.text = "BET"
	#
	#@rpc ("any_peer","call_local", "reliable")
#func request_player_active():
	#if multiplayer.is_server():
		#print("player : ", player_id, " is active")
		#set_player_active.rpc(true)	
		
	

	
@rpc ("any_peer","call_local", "reliable")
func request_player_active():
	if multiplayer.is_server():
		print("player : ", player_id, " is active")
		set_player_active.rpc(true)	

		
@rpc("any_peer", "call_local", "reliable")
func set_player_active(active_state: bool):
	active_player = active_state	
	if active_state == true:
		%Player_frame_outline.visible = true
	else:
		%Player_frame_outline.visible = false


		#
@rpc("any_peer", "call_local", "reliable")
func update_player_health_bars():
	# This should just trigger a visual update, not calculation
	update_health_bar_visual()		

#player.update_player_health_bar.rpc()


@rpc("any_peer", "call_local", "reliable")
func change_player_health(amount: int):
	if multiplayer.is_server():
		# Only server should calculate health changes
		_calculate_health_change(amount)
		# Sync the updated values to all clients
		sync_health_values.rpc(current_health, excess)
				
func _calculate_health_change(amount: int):
	var diff = starting_health - current_health
	
	# Positive numbers
	if excess == 0:
		if amount > 0:
			if diff > amount:
				current_health += amount
			elif diff < amount:
				current_health = starting_health
				excess += amount - diff
		else:
			# Negative numbers
			if excess == 0:
				current_health += amount
			else:
				if excess > amount:
					excess += amount
				else:
					current_health += excess - amount
					excess = 0
	
	if current_health <= 0:
		current_health = 0
		set_player_play_state(PLAYER_STATE.out_of_play)
	
	# Update the health bar locally
	update_health_bar_visual()
	
	
@rpc("authority", "call_local", "reliable")
func sync_health_values(synced_health: int, synced_excess: int):
	current_health = synced_health
	excess = synced_excess
	update_health_bar_visual()



func update_health_bar_visual():
	if health_meter and health_meter.health_remaining_bar:
		# Calculate bar sizes based on current values
		var remaining_width = (104.5 / 100.0) * current_health
		var excess_width = (104.5 / (100.0 * (get_parent().current_players.size() + 1))) * excess
		
		health_meter.health_remaining_bar.size.x = remaining_width
		health_meter.health_excess_bar.size.x = excess_width


#-----------------SCORE DISPLAY FUNCTIONS-----------------------

#player.set_score_display_visible.rpc(true)
@rpc("any_peer", "call_local", "reliable")
func set_score_display_visible(value:bool):
	if value == true:
		%mini_avatar.visible = true
		%Avatar.visible = false
		%external_status.visible = false
	else:
		%external_status.visible = true
		%mini_avatar.visible = false
		%Avatar.visible = true
	score_display.visible = value



@rpc("any_peer", "call_local", "reliable")
func request_score_value_increase(value):
	if multiplayer.is_server():
		print("increasing score by : ", value)
		server_increase_score_value(value)
	else:
		request_score_value_increase.rpc_id(1, value)

@rpc("authority", "call_local", "reliable")
func server_increase_score_value(value):
	current_score += value
	
	update_score_display()
	
func update_score_display():
	if score_display and score_display.score:
		score_display.score.text = str(current_score)



# ===== NEW FUNCTIONS FOR CHIPS AND MULTIPLIER DISPLAY =====

@rpc("any_peer", "call_local", "reliable")
func request_chips_display_update(value):
	if multiplayer.is_server():
		server_update_chips_display(value)
	else:
		request_chips_display_update.rpc_id(1, value)

@rpc("authority", "call_local", "reliable")
func server_update_chips_display(value):
	
	update_chips_display(value)

func update_chips_display(value):
	if score_display and score_display.chips:
		score_display.chips.text = str(value)



@rpc("any_peer", "call_local", "reliable")
func request_mult_display_update(value):
	if multiplayer.is_server():
		server_update_mult_display(value)
	else:
		request_mult_display_update.rpc_id(1, value)

@rpc("authority", "call_local", "reliable")
func server_update_mult_display(value):
	
	update_mult_display(value)

func update_mult_display(value):
	if score_display and score_display.mult:
		score_display.mult.text = str(value)

#--------------	HAND NAME DISPLAY------------------
@rpc("any_peer", "call_local", "reliable")
func request_hand_display_update(text):
	if multiplayer.is_server():
		server_update_chips_display(text)
	else:
		request_chips_display_update.rpc_id(1, text)

@rpc("authority", "call_local", "reliable")
func server_update_hand_display(text):
	
	update_hand_display(text)

func update_hand_display(text):
	if score_display and score_display.hand:
		score_display.hand.text = text

#--------------EXTERNAL STATUS DISPLAY----------------------


@rpc("any_peer", "call_local", "reliable")
func request_status_text_change(text):
	if multiplayer.is_server():
		print("changing status text to : ", text)
		server_change_external_status_text(text)
	else:
		request_status_text_change.rpc_id(1, text)  # Send to server (ID 1)

@rpc("authority", "call_local", "reliable")  # Changed from "any_peer" to "authority"
func server_change_external_status_text(text):
	print("server updating status display")
	update_external_status_display(text)

	
func update_external_status_display(text):
	# Add null check to avoid errors
	if has_node("%Game_Status_text"):
		%external_status.text = text
		print("Updated status display to: ", text)
	else:
		print("ERROR: Game_Status_text node not found!")
	







# ===== CONVENIENCE FUNCTIONS =====



@rpc("any_peer", "call_local", "reliable")
func request_update_all_displays(score,chips,multiplier,hand):
	if multiplayer.is_server():
		server_update_all_displays(score,chips,multiplier,hand)
	else:
		request_update_all_displays.rpc_id(1, score,chips,multiplier,hand)

@rpc("authority", "call_local", "reliable")
func server_update_all_displays(score,chips,multiplier,hand):
	update_all_score_displays(score,chips,multiplier,hand)
	




func update_all_score_displays(score,chips,multiplier,hand):
	"""Update all score display elements at once"""
	if score >= 0:
		current_score = score
	
	server_increase_score_value.rpc(score)
	
	server_update_chips_display.rpc(chips)

	server_update_mult_display.rpc(multiplier)
	
	server_update_hand_display.rpc(hand)
	
	

















#	starting health - current health = difference. if the difference is greater than the amount then add the amount. 
#	if its less than the amount.put health at starting health and  subtract the difference from the amount and add it to the excess.
#	 update both bars. 

	#health panel size (108/100) * current_health
	#excess panel size (108/(100*number of players - 1)) * excess amount
	 
	
		
@rpc ("any_peer","call_local", "reliable")
func request_player_inactive():
	if multiplayer.is_server():
		print("player : ", player_id, " is inactive")
		set_player_active.rpc(false)	
	
		


@rpc("any_peer", "call_local", "reliable")			
func clear_community_discards_from_selection():
	#print("removing player %s cards : player id  :  ",% player_id)	
	print(selected_cards)
	selected_cards = selected_cards.filter(
	func(card): return card.owner_id != -1
	)
	
	
@rpc("any_peer", "call_local", "reliable")			
func clear_player_selection():
	#print("removing player %s cards : player id  :  ",% player_id)	
	print(selected_cards)
	selected_cards = []
	



@rpc("any_peer", "call_local", "reliable")
func request_player_status_text_change(text):
	if multiplayer.is_server():
		print("changing status text to : " , text)
		server_player_change_status_text(text)
	else:
		request_status_text_change.rpc_id(1,text)

@rpc("authority","call_local" ,"reliable")
func server_player_change_status_text(text):
	update_player_status_display(text)
	

func update_player_status_display(text):
	status_text.text = text
	
	#
#func update_active_display():
	#if active_player:
		#%Player_frame_outline.visible = true
	#else:
		#%Player_frame_outline.visible = false
			
	
	
	
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
