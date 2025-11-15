class_name GameManager
extends Node2D
@onready var score_manager: Node2D = $"../score_manager"
@onready var card_manager: Node2D = $"../card_manager"
@onready var players: Node2D = $"../Players"
@onready var current_player_index = 0
var current_dealer = Player
var current_big_blind : Player
var current_small_blind : Player
@onready var current_players = 0

var prev_state
var curr_state 

#states
@onready var game_start: Node = $game_start
@onready var bet_ante: Node = $bet_ante
@onready var deal_players: Node = $deal_players
@onready var discard_players: Node = $discard_players
@onready var deal_hole: Node = $deal_hole
@onready var bet_hole: Node = $bet_hole
@onready var deal_flop: Node = $deal_flop
@onready var bet_flop: Node = $bet_flop
@onready var deal_turn: Node = $deal_turn
@onready var bet_turn: Node = $bet_turn
@onready var deal_river: Node = $deal_river
@onready var bet_river: Node = $bet_river
@onready var showdown: Node = $showdown
@onready var payout: Node = $payout
@onready var store: Node = $store
@onready var game_state_label: Label = $"../UI/Game_State_Display/Game State"
@onready var game_state_display: Control = $"../UI/Game_State_Display"

@onready var play_space: Node2D = $".."




var player_signals_connected = false


func _ready() -> void:	
	set_starting_state()
	
func _process(delta: float) -> void:
	for player in players.current_players:
		if player.signals_connected == false :
			connect_player_signals(player)			
			player.signals_connected = true
#build a state machine, that commands the card manager to deal cards, locks and unlocks what players can do. 
	run_current_state(delta)
	for player in players.current_players:
		player.handle_hand_slots(delta)
		
		
func run_current_state(delta):
	curr_state.update(delta)	 
	
func change_state(next_state):
	if next_state != null:
		curr_state.exit_state()
		prev_state=curr_state
		
		curr_state=next_state
		curr_state.enter_state()

func set_starting_state():
	print("setting_start_state")
	for state in get_children():
		state.states = self
		state.players = players
		state.card_manager = card_manager
		state.game_manager = self
		state.score_manager = score_manager
		state.display = game_state_display
		state.label = game_state_label

		
	prev_state = game_start
	curr_state = game_start
	curr_state.enter_state()

func connect_player_signals(player):
	print("player signal connected")
	player.connect("action_button_pressed",_on_action_button_pressed)
	#player.button1_pressed.connect(_on_button1_pressed)
	#player.button2_pressed.connect(_on_button2_pressed)
	#player.button3_pressed.connect(_on_button3_pressed)


func _on_action_button_pressed(player_id):
	print("player : ",player_id, "action button pressed")



		
func _on_play_request(player,hand):
	print("hand sent to play :", hand)
	var community_slots = card_manager.minor_arcana_community_slots.get_children()
	var community_cards = []

	#if the community slot contains a card, 
	#and the card is selected for being played, add it to the played hand. 
	if community_slots[0].stored_cards.size() == 1:
		if community_slots[0].stored_cards[0].selected:
			community_cards.append(community_slots[0].stored_cards[0])
	if community_slots[1].stored_cards.size() == 1:
		if community_slots[1].stored_cards[0].selected:
			community_cards.append(community_slots[1].stored_cards[0])	
	if community_slots[2].stored_cards.size() == 1:
		if community_slots[2].stored_cards[0].selected:
			community_cards.append(community_slots[2].stored_cards[0])	
	if community_slots[3].stored_cards.size() == 1:
		if community_slots[3].stored_cards[0].selected:
			community_cards.append(community_slots[3].stored_cards[0])
	if community_slots[4].stored_cards.size() == 1:
		if community_slots[4].stored_cards[0].selected:
			community_cards.append(community_slots[4].stored_cards[0])	

	print("game manager knows of played hand : ", hand)
	
	var hand_info = score_manager.get_hand_info(hand+community_cards)
	
	player.hand_to_play.clear()
	player.current_hand_display.text = str("Current Hand : ", hand_info["hand_type"])
	player.score_display.text = str("Score : ", hand_info["score"])
	print("Best hand: ", hand_info["hand_type"])
	print("Score: ", hand_info["score"])
	print("Multiplier: ", hand_info["multiplier"])
	print("Chips: ", hand_info["chips"])
	print("cards: ", hand_info["cards"])
	

	


func _on_score_pressed(player,hand) -> void:
	pass
	##print("hand sent to play :", hand)
	#var community_slots = card_manager.minor_arcana_community_slots.get_children()
	#var community_cards = []
#
	##if the community slot contains a card, 
	##and the card is selected for being played, add it to the played hand. 
	#if community_slots[0].stored_cards.size() == 1:
		#if community_slots[0].stored_cards[0].selected:
			#community_cards.append(community_slots[0].stored_cards[0])
	#if community_slots[1].stored_cards.size() == 1:
		#if community_slots[1].stored_cards[0].selected:
			#community_cards.append(community_slots[1].stored_cards[0])	
	#if community_slots[2].stored_cards.size() == 1:
		#if community_slots[2].stored_cards[0].selected:
			#community_cards.append(community_slots[2].stored_cards[0])	
	#if community_slots[3].stored_cards.size() == 1:
		#if community_slots[3].stored_cards[0].selected:
			#community_cards.append(community_slots[3].stored_cards[0])
	#if community_slots[4].stored_cards.size() == 1:
		#if community_slots[4].stored_cards[0].selected:
			#community_cards.append(community_slots[4].stored_cards[0])	
#
	#print("game manager knows of played hand : ", hand)
	#
	#var hand_info = score_manager.get_hand_info(hand+community_cards)
	#
	#player.hand_to_play.clear()
	#player.current_hand_display.text = str("Current Hand : ", hand_info["hand_type"])
	#player.score_display.text = str("Score : ", hand_info["score"])
	#print("Best hand: ", hand_info["hand_type"])
	#print("Score: ", hand_info["score"])
	#print("Multiplier: ", hand_info["multiplier"])
	#print("Chips: ", hand_info["chips"])
	#print("cards: ", hand_info["cards"])
