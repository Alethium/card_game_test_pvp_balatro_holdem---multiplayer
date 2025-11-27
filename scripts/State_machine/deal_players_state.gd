#DEAL PLAYERS STATE
extends game_state
var num_cards
#dealer has an opportunity to alter the deck in this moment 
#apply modifiers to specific cards ala tarot cards. change suit, value, lucky, glass, gold, stone. 
# all players are dealt their hand
# really not sure yet how many cards are appropriate. 
# will this game deal just two like normal and a larger hand of spells and hijinx?
# once all the players # once all the players have the hand they want to keep
func enter_state() -> void:
	play_space.request_status_text_change.rpc("Dealing Cards \n Please Wait ...")
	
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Dealing")
		player.set_button_visibility.rpc("button1",false)
		player.set_button_visibility.rpc("button2",false)
		player.set_button_visibility.rpc("button3",false)
		player.set_button_disabled.rpc("button1",true)
		player.set_button_disabled.rpc("button2",true)
		player.set_button_disabled.rpc("button3",true)



	label.text = "Dealing cards to players"
	if game_manager.prev_state == states.discard_players : 
		var current_card_count = 0
		for card in card_manager.currently_spawned_cards:

			if card.owner_id > 0 :
#				find a way to deselect like when clear community
				current_card_count += 1
				card.deselect.rpc(0)
				
		num_cards = 5*players.current_players.size() - current_card_count
		print("this many cards to be ddealt : ",num_cards)
			
	else:
		num_cards = 5*players.current_players.size()
		print("this many cards to be dealt : ",num_cards)
	
	if num_cards == 0:
		if game_manager.prev_state == states.discard_players : 
			print("no discard to discard")
			if game_manager.second_prev_state == states.deal_players : 
				print("time to go to  betting on your hand")
				states.change_state(states.bet_deal)
			elif game_manager.second_prev_state == states.deal_hole : 
				states.change_state(states.bet_hole)	
			elif game_manager.second_prev_state == states.deal_flop : 
				states.change_state(states.bet_flop)
			elif game_manager.second_prev_state == states.deal_turn : 
				states.change_state(states.bet_turn)
			elif game_manager.second_prev_state == states.deal_river : 
				states.change_state(states.bet_river)
	else:
			
		card_manager.dealing = true
		card_manager.Current_Minor_Deck.deck_of_cards.shuffle()
		print("it is time to deal cards!!!!!")
	
	
		
func exit_state() -> void:
	card_manager.dealing = false
	for player in players.current_players:
		player.set_action_button_pressed.rpc(false)
		player.request_player_unready.rpc()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	if card_manager.dealing_timer == 0 and num_cards > 0 :
		card_manager.dealing_timer += 20
		num_cards -= 1
		print("state machine calling for card deal to player")
		card_manager._on_deal_to_players_pressed()
	if card_manager.dealing_timer == 0 and num_cards == 0 :
		print("done dealing state ")
		card_manager.dealing = false
		if game_manager.prev_state == states.discard_players : 
			print("refilling hand")
			
			if game_manager.second_prev_state == states.deal_players : 
				print("time to go to  betting on your hand")
				states.change_state(states.bet_deal)
			elif game_manager.second_prev_state == states.deal_hole : 
				states.change_state(states.bet_hole)	
			elif game_manager.second_prev_state == states.deal_flop : 
				states.change_state(states.bet_flop)
			elif game_manager.second_prev_state == states.deal_turn : 
				states.change_state(states.bet_turn)
			elif game_manager.second_prev_state == states.deal_river : 
				states.change_state(states.bet_river)

		
		else:
			print("time to go to  discard")
			states.change_state(states.discard_players)
