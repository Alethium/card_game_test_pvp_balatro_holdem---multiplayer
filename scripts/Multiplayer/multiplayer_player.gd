class_name MultiplayerPlayer
extends Node2D

@onready var player_hand: Node2D = $player_hand
signal discard_request
signal play_hand
@onready var current_hand_display: Label = $Control/current_hand
@onready var score_display: Label = $Control/Score
@onready var player_role_marker_position: Node2D = $player_role_marker_position
@onready var mouse_window_detection: Node = $mouse_window_detection

var display_name : String
var hand_size = 5
var discard_count = 2
var current_slots = []
var starting_health = 100
var remaining_health : int
var current_chips : Array[Chip]
const CHIP = preload("res://Scenes/chip.tscn")
var starting_mana = 0
var current_mana : int
var active_turn = false
@onready var hand_cursor: HandCursor = $Hand_Cursor
const CARD_SLOT = preload("res://Scenes/card_slot.tscn")
var currently
var empty_slots = 5
var hand_to_play : Array[Card]
var current_hand : Array[Card] 
var number_of_cards_selected = 0
signal player_added
var direction : Vector2
var player_position : int
signal player_request_unclick
signal player_request_click
@onready var button_container = $Control

@export var player_id := 1:
	set(id):
		player_id = id
		%input_synchronizer.set_multiplayer_authority(id)




func _ready() -> void:
	player_added.emit(self)
	current_hand = []
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		# Only enable interaction if this is our local player
	if not is_multiplayer_authority():
		set_buttons_interactable(false)
	else:
		set_buttons_interactable(true)
	
	
	
	

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		update_input(delta)


func _input(event: InputEvent) -> void:
	if multiplayer.get_unique_id() == player_id:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				player_request_click.emit(%input_synchronizer.player_mouse_cursor_position)
				#send a request to the server for a click of the mouse. 
				%input_synchronizer.click()

func update_input(delta):
	#hand_cursor.global_position += %input_synchronizer.player_mouse_cursor_direction
	
	hand_cursor.global_position = %input_synchronizer.player_mouse_cursor_position
	#also transfer clicking code from cardmanager over here
	

func add_slot():
	var new_slot = CARD_SLOT.instantiate()
	current_slots.push_front(new_slot)
	player_hand.add_child(new_slot)
	new_slot.global_position = player_hand.global_position

func remove_slot(slot):
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
		


func _on_discard_button_pressed() -> void:
	print("player_pressed_discard")
	discard_request.emit(self)


func _on_play_button_pressed() -> void:
	print("player_pressed_play")
	#for card in current_hand:
		#if card.selected:
			#played_hand.append(card)
	if hand_to_play.size() ==0:
		print("no hand to play")
		return
	else:
		play_hand.emit(self,hand_to_play)
	
func set_buttons_interactable(enabled: bool):
	for button in button_container.get_children():
		if button is BaseButton:
			button.disabled = !enabled
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE if not enabled else Control.MOUSE_FILTER_PASS
