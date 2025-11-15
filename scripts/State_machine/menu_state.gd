#menuSTATE
extends game_state

#in game start state, this is where we will load in the players
#we will spawn in the decks and the players
#display some sort of intro UI element
#spin a dial to select the Dealer for this round. 

#each player is dealt a personal curse card and a boon card.
# the cards have a positive and a negative effect,depending on if its drawn as a curse or a boon. 



func enter_state() -> void:
	#spawn in the hosts tarot deck with its specific visuals. 
	#add in each player(not sure how MP handles this yet. )
	#display a waiting for players to ready up display. 

	
	print("select if you want to host or join")
func exit_state() -> void:
	print("proceeding to game")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	check_players()
#
	#
	##states.change_state(states.bet_ante)
func check_players():
	if multiplayer.is_server() and players.current_players.size() > 1:
		states.change_state(states.game_start)
		
		#var players_ready = 0
		#for player in players.current_players:
			#if player.action_button_pressed and player.is_ready == false:
				#player.request_player_ready.rpc()
				#player.set_button_text.rpc("action_button","Ready!")
				#players_ready += 1
			#elif !player.action_button_pressed and player.is_ready == true:
				#player.request_player_unready.rpc()
				#player.set_button_text.rpc("action_button","Not Ready!")
				#
			#if players_ready == players.current_players.size():
				#print("all players ready")
				#states.change_state(states.bet_ante)
