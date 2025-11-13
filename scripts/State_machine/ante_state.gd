#ANTE_STATE
extends game_state


#in this state the players will put in thier ante from their pile of "chips"
#ante cost grows as the rounds get further in. 
#when all players have submitted their ante proceed to next state, dealing cards to players.  
#forced bets,

#person left of the dealer posts the small blind, which is half the big blind. 1 token
#player two to the left of the dealer sets the ante by posting the big blind.1 token blind = 2 tokens

#PLAYERS CHOOSE TO MEET THE BIG BLIND or FOLD OUT




func enter_state() -> void:
	print("its time to ANTE UP")
	for player in players.current_players:
		player.set_button_text.rpc("bet","ANTE")
		player.request_player_unready.rpc()
	
func exit_state() -> void:
	for player in players.current_players:
		player.set_button_text.rpc("bet","BET")
		player.set_player_bet.rpc(false)
func update(_delta: float) -> void:
	check_players_ante()
#if all players have clicked the bet button move to next state

func check_players_ante():
	if multiplayer.is_server() and players.current_players.size() > 0:
		var players_bet = 0
		for player in players.current_players:
			if player.has_bet == true:
				
				players_bet += 1
			if players_bet == players.current_players.size():
				print("all players have ANTE")
				states.change_state(states.deal_players)
