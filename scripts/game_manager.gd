class_name GameManager
extends Node2D
@onready var score_manager: Node2D = $"../score_manager"
@onready var card_manager: Node2D = $"../card_manager"
@onready var players: Node2D = $"../Players"
@onready var current_player_index = 0


var current_dealer = Player
var current_big_blind : Player
var current_small_blind : Player

var current_ante = 1
var current_bet = 0
var current_pot = 0

var current_score = 0
# will be used when displaying the growing score for each players hand as doinks com inasthe for loopmoves through the players cards

@onready var active_player_index = 0
var active_player = null
var previous_player = null
var second_prev_state
var prev_state
var curr_state 
var next_state

#states
@onready var menu_state: Node = $menu_state
@onready var game_start: Node = $game_start
@onready var ante_up: Node = $ante_up
@onready var deal_players: Node = $deal_players
@onready var discard_players: Node = $discard_players
@onready var bet_deal: Node = $bet_deal
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
@onready var game_status_label: Label = %Game_Status_text
#@onready var game_status_display: Control = $"../UI/Game_Status_Display"

@onready var play_space: Node2D = $".."




var player_signals_connected = false


func _ready() -> void:	
	
	set_starting_state()
	
func _process(delta: float) -> void:
#build a state machine, that commands the card manager to deal cards, locks and unlocks what players can do. 
	run_current_state(delta)
	for player in players.current_players:
		player.handle_hand_slots(delta)
		
		
func run_current_state(delta):
	curr_state.update(delta)	 
	
func change_state(new_state):
	if new_state != null:
		curr_state.exit_state()
		second_prev_state = prev_state
		prev_state=curr_state
		
		curr_state=new_state
		curr_state.enter_state()

func set_starting_state():
	print("setting_start_state")
	for state in get_children():
		state.play_space = play_space
		state.states = self
		state.players = players
		state.card_manager = card_manager
		state.game_manager = self
		state.score_manager = score_manager
		state.display = game_status_display
		state.label = game_status_label

		
	prev_state = menu_state
	curr_state = menu_state
	next_state = game_start
	curr_state.enter_state()

func make_next_player_active():
	var num_players = players.current_players.size()
	print("next player active ")
	print("currently %s players" %num_players)
	if !active_player_index >= num_players-1:
		active_player_index += 1
		print("increasing player index to ", active_player_index)
	else:
		active_player_index = 0
		print("resetting player index to ", active_player_index)
	set_previous_player()
	set_active_player()
	

func set_active_player():
#	 set all players to inactive
	for player in players.current_players:
		player.request_player_inactive.rpc()
#	 set active player to active index
	
	players.current_players[active_player_index].request_player_active.rpc()
	if active_player != null:
		active_player.set_action_button_pressed(false)
		active_player.set_button1_pressed(false)
		active_player.set_button2_pressed(false)
		active_player.set_button3_pressed(false)
		previous_player = active_player
	active_player = players.current_players[active_player_index]
			
#	 check to see if they have a current bet state of folded before moving to make them active. 
# 	maybe player. waiting_players, can collect losers, folders, and new joiners who wait for the hand to end to ante in ont he next go around. 
func ante_in():
	active_player.current_health -=1
	current_pot += 1
	
func raise_bet():
	active_player.current_bet += 1
	current_bet += 1
	current_pot += current_bet
	active_player.current_health -= current_bet - active_player.current_bet
#	0 + 1-1+1 = 1
#   1 + 1 - 1 + 1 = 2

func see_bet():
	active_player.current_bet = current_bet
	current_pot += current_bet 
	active_player.current_health -= current_bet
	
func reset_pot():
	
	current_pot = 0
	
	
	
func fold_player(player):
	print("player has folded : ", player)
#	set player current bet back to zero. 
#	move the player from current players to waiting players. 
#	 set external display to waiting to join




func set_previous_player():
#	 set all players to inactive
#	 set active player to active index
	previous_player = active_player
	





		
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
