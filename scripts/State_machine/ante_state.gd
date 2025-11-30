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
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Ante Up!")
	play_space.request_status_text_change.rpc("Ante state, Please Ante up")

		
		
	
func exit_state() -> void:
	for player in players.current_players:
		player.set_action_button_pressed.rpc(false)
		player.request_player_unready.rpc()

func update(_delta: float) -> void:
	check_players_ante()
	for player in players.current_players:
		player.set_button_visibility.rpc("button1",false)
		player.set_button_visibility.rpc("button2",false)
		player.set_button_visibility.rpc("button3",false)
		player.set_button_disabled.rpc("button1",true)
		player.set_button_disabled.rpc("button2",true)
		player.set_button_disabled.rpc("button3",true) 
#if all players have clicked the bet button move to next state

func check_players_ante():
	
	if multiplayer.is_server() and players.current_players.size() > 0:
		for player in players.current_players:
			if player.action_button_pressed and player.is_ready == false:
				player.request_player_ready.rpc()
				player.set_button_text.rpc("action_button","Ante In!")
				if !players_ready.has(player.player_id):
					game_manager.ante_in(player)
					player.request_player_ready.rpc()
					players_ready.append(player.player_id)
			#elif !player.action_button_pressed and player.is_ready == true:
				#player.request_player_unready.rpc()
				#if players_ready.has(player.player_id):
					#players_ready.erase(player.player_id)
				#player.set_button_text.rpc("action_button","Not Ready!")
		if players_ready.size() == players.current_players.size():
			print("all players ready")
			states.change_state(states.deal_players)
