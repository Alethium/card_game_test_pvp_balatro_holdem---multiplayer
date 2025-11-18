#GAME_START_STATE
extends game_state
var players_ready = []
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
	print("game is starting")
	play_space.request_status_text_change.rpc(str("pre game, when game is hosted \n and all players ready we will begin",))
	
	
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Ready Up!")
		
	print("when all players have loaded in we will begin")
func exit_state() -> void:
	print("proceeding to ante")
	for player in players.current_players:
		player.set_action_button_pressed.rpc(false)
		player.request_player_unready.rpc()
	game_manager.set_active_player()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	
	check_players_ready()
	
	#
	##states.change_state(states.bet_ante)
func check_players_ready():
	if multiplayer.is_server() and players.current_players.size() > 0:
		
		for player in players.current_players:
			if player.action_button_pressed and player.is_ready == false:
				player.request_player_ready.rpc()
				player.set_button_text.rpc("action_button","Ready!")
				if !players_ready.has(player.player_id):
					players_ready.append(player.player_id)
			elif !player.action_button_pressed and player.is_ready == true:
				player.request_player_unready.rpc()
				if players_ready.has(player.player_id):
					players_ready.erase(player.player_id)
				player.set_button_text.rpc("action_button","Not Ready!")
		#print(players_ready)		
		if players_ready.size() == players.current_players.size():
			print("all players ready")
			states.change_state(states.ante_up)
