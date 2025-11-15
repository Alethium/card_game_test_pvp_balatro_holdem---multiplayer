#ANTE_STATE
extends game_state
var players_ready = []

#in this state the players will put in thier ante from their pile of "chips"
#ante cost grows as the rounds get further in. 
#when all players have submitted their ante proceed to next state, dealing cards to players.  
#forced bets,

#person left of the dealer posts the small blind, which is half the big blind. 1 token
#player two to the left of the dealer sets the ante by posting the big blind.1 token blind = 2 tokens

#PLAYERS CHOOSE TO MEET THE BIG BLIND or FOLD OUT




func enter_state() -> void:
	print("its time to ANTE UP")
	label.text = "Ante state, Please Ante up"
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Ante Up!")
	
func exit_state() -> void:
	for player in players.current_players:
		#player.set_button_text.rpc("button1","BET")
		player.set_player_bet.rpc(false)


func update(_delta: float) -> void:
	check_players_ante()
#if all players have clicked the bet button move to next state

func check_players_ante():
	
	if multiplayer.is_server() and players.current_players.size() > 0:
		for player in players.current_players:
			if player.action_button_pressed and player.is_ready == false:
				player.request_player_ready.rpc()
				player.set_button_text.rpc("action_button","Ante In!")
				if !players_ready.has(player.player_id):
					players_ready.append(player.player_id)
			#elif !player.action_button_pressed and player.is_ready == true:
				#player.request_player_unready.rpc()
				#if players_ready.has(player.player_id):
					#players_ready.erase(player.player_id)
				#player.set_button_text.rpc("action_button","Not Ready!")
		if players_ready.size() == players.current_players.size():
			print("all players ready")
			states.change_state(states.deal_players)
