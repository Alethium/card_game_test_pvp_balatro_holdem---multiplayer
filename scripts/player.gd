class_name Player
extends Node2D
@onready var player_hand: Node2D = $player_hand
signal discard_request
signal play_hand
@onready var current_hand_display: Label = $Control/current_hand
@onready var score_display: Label = $Control/Score
@onready var player_role_marker_position: Node2D = $player_role_marker_position
var unique_player_id
var player_name
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
func _ready() -> void:
	current_hand = []
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
	print("player pressed discard")
	discard_request.emit(self)


func _on_play_button_pressed() -> void:

	#for card in current_hand:
		#if card.selected:
			#played_hand.append(card)
	if hand_to_play.size() ==0:
		print("no hand to play")
		return
	else:
		play_hand.emit(self,hand_to_play)
	
