


extends Node2D
@onready var players: Node2D = $"../Players"



@onready var major_arcana_in_play: Node2D = $"../Major_arcana_Slots"

@onready var major_modifier_deck_slot: CardSlot = $"../Major_modifier_deck_Slot"
@onready var major_modifier_discard_slot: CardSlot = $"../Major_modifier_discard_slot"

@onready var minor_card_deck_slot: CardSlot = $"../Minor_card_deck_Slot"
@onready var minor_card_discard_slot: CardSlot = $"../Minor_card_discard_slot"

@onready var minor_arcana_community_slots: Node2D = $"../Minor_Arcana_Community_Slots"
@onready var game_manager: GameManager = $"../game_manager"


@onready var score_manager: Node2D = $"../score_manager"

var card_signals_connected = false
var slot_signals_connected = false
var player_signals_connected = false
#signal dealing_complete
var currently_grabbed_card : Card
var current_hovered_slot : CardSlot
var current_hovered_card : Card
var last_hovered_card : Card
var is_hovering_on_card = false
var screen_size

var dealing_index : int = 0 
var dealing = false
var reloading = false
var cards_delt = 0
var dealing_timer = 0
var slots_filled = 0
var total_slots_to_fill = 0
var minor_left_to_deal = 0

# New variables for community card dealing
var dealing_to_community = false
var community_cards_to_deal = 0
var community_dealing_timer = 0
var reloading_timer = 0


@export var Current_Minor_Deck : Minor_Arcana_Deck
@onready var cards_in_play: Node2D = $"../cards_in_play"
var currently_spawned_cards : Array 


# Network variables
var networked_cards: Dictionary = {}  # card_id -> Card object
var random_seed_value: int = 0

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
func _process(_delta: float) -> void:
	if multiplayer.is_server():
		update_card_positions.rpc(_delta)

@rpc("any_peer","call_local")
func draw_single_card(owner_id):

	#take the top card of the deck
	var drawn_card = Current_Minor_Deck.deck_of_cards[0]
	drawn_card.owner_id = owner_id
	currently_spawned_cards.append(drawn_card)
	drawn_card.global_position = minor_card_deck_slot.global_position
	for slot in minor_arcana_community_slots.get_children():
		if slot.stored_cards.size() == 0:
			drawn_card.target_slot = slot
			print("drawn cards target slot: ",drawn_card.target_slot )
			slot.stored_cards.append(drawn_card)
			break
			
			
	cards_in_play.add_child(drawn_card)
	Current_Minor_Deck.deck_of_cards.remove_at(0)
	
	
	
	
	#instantiate it, the card spawner should spawn the card for everyone. 
	#give the card the correct owner, 
	#generate a unique id for this card to keep it unique. 
func _on_deal_to_community_pressed() -> void:
	print("deal pressed by : " , multiplayer.get_unique_id())	
	draw_single_card.rpc(-1)



@rpc("any_peer","call_local")
func update_card_positions(delta):
	#print("multiplayer id : ", multiplayer.get_unique_id())
	for card in cards_in_play.get_children():
		print("drawn cards target slot updated: ",card.target_slot )
		print("drawn cards owner: ",multiplayer.get_unique_id()) 
		if card.target_slot != null:
			
			card.global_position = lerp(card.global_position,card.target_slot.global_position,delta*10)
			
func instantiate_cards():
	
	
	for card in Current_Minor_Deck.base_set:
		if card is PackedScene:	
			var int_card = card.instantiate()
			int_card.global_position = minor_card_deck_slot.global_position
			int_card.card_id = randi()
			print(int_card," : instantiated")
			Current_Minor_Deck.deck_of_cards.append(int_card)
			Current_Minor_Deck.deck_of_cards.shuffle()
		else:
			print("card_instantiation_done")
			print(Current_Minor_Deck.deck_of_cards[0])
			return	



	

	
	
	
	
	
