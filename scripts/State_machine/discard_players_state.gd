#DISCARD PLAYERS STATE
extends game_state
var num_cards
var players_ready = []
#dealer has an opportunity to alter the deck in this moment 
#apply modifiers to specific cards ala tarot cards. change suit, value, lucky, glass, gold, stone. 
# all players are dealt their hand
# really not sure yet how many cards are appropriate. 
# will this game deal just two like normal and a larger hand of spells and hijinx?
# once all the players # once all the players have the hand they want to keep
func enter_state() -> void:
	label.text = "please discard cards you do not want, \n and you wll be dealt new cards. "
	print("its time to DISCARD THOSE CARDS!")
	label.text = "discard state, discarding and redrawing to players"
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Discard")
		player.set_button_visibility("button1",false)
		player.set_button_visibility("button2",false)
		player.set_button_visibility("button3",false)
		player.set_button_disabled.rpc("button1",true)
		player.set_button_disabled.rpc("button2",true)
		player.set_button_disabled.rpc("button3",true);
	
		
func exit_state() -> void:
	for player in players.current_players:
		player.set_action_button_pressed.rpc(false)
		player.request_player_unready.rpc()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	check_players_discard()

func check_players_discard():
#	 if players select cards and press the discard button, it locks them in and when all players have selected the discard, to the discard and redraw. 

	if multiplayer.is_server() and players.current_players.size() > 0:
		for player in players.current_players:
			if player.action_button_pressed and player.is_ready == false:
				player.request_player_ready.rpc()
				print("discarding cards for player : " , player.player_id)
				player.set_button_text.rpc("action_button","Discarding!")
				card_manager._on_discard_pressed(player.player_id)
				if !players_ready.has(player.player_id):
					players_ready.append(player.player_id)
			#elif !player.action_button_pressed and player.is_ready == true:
				#player.request_player_unready.rpc()
				#if players_ready.has(player.player_id):
					#players_ready.erase(player.player_id)
				#player.set_button_text.rpc("action_button","Not Ready!")
		if players_ready.size() == players.current_players.size():
			print("all players discard, redraw now")
			
			players_ready = []
			states.change_state(states.deal_players)
