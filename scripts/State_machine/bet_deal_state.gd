#Deal BET STATE
extends game_state

enum BET_STATE {stay,see,raise,fold,none}
var prev_move : BET_STATE = BET_STATE.none
var players_stayed = 0
#PLAYERS CHOOSE TO STAY, RAISE OR FOLD. Based on the drawanddiscardrounds results.  
#IF PLAYERS RAISE, THEN A SECOND ROUND OF SEEING F PEOPLE WILL SEE THE BET. 
#IF UNWILLING TO SEE THE BET, A PLAYER MUST FOLD
#IF ALL BUT ONE FOLD OUT DURING A BETTING PHASE PROCEED TO PAYOUT WHERE THE REMAINER TAKES THE POT. 



func enter_state() -> void:
	print("its time to bet on your dealt hand.")
#	 set buttonsto stay hold raise
	label.text = "Its time to Bet, do you want to \n Stay , Raise, or Fold"
	game_manager.set_active_player()
	game_manager.set_previous_player()
	game_manager.set_active_player()
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Stay")
		player.set_button_text.rpc("button1","See")
		player.set_button_text.rpc("button2","Raise")
		player.set_button_text.rpc("button3","Fold")
		player.set_player_bet_state.rpc(BET_STATE.none)


	
	
	
func exit_state() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
#	if previous is null, that means this is the very first bet in the betting round. this thould be the state that this and all betting states start on. 
# always start with the active player, which should be getting rotated each round. handle that later for now its always host. 
	
#	 now i have to use the tracking of player bets and the current bet to orchestrate the growing bet 
	for player in players.current_players:
		if player.player_id != game_manager.active_player.player_id:
			player.set_button_disabled.rpc("button1",true)
			player.set_button_disabled.rpc("button2",true)
			player.set_button_disabled.rpc("button3",true)
			player.set_button_disabled.rpc("action_button",true)
			
			player.set_button_visibility.rpc("action_button",false)
			player.set_button_visibility.rpc("button1",false)
			player.set_button_visibility.rpc("button2",false)
			player.set_button_visibility.rpc("button3",false)

		else:
			player.set_button_disabled.rpc("button1",false)
			player.set_button_disabled.rpc("button2",false)
			player.set_button_disabled.rpc("button3",false)
			player.set_button_disabled.rpc("action_button",false)
			
			player.set_button_visibility.rpc("action_button",true)
			player.set_button_visibility.rpc("button1",true)
			player.set_button_visibility.rpc("button2",true)
			player.set_button_visibility.rpc("button3",true)
				
	
#	 IF THE TURN IS THE FIRST TURN OF BETTING
	#if game_manager.previous_player == null:
##		waits for player to make first choice
#
			#if game_manager.active_player.action_button_pressed:
				#print("1st better chose to stay")
				#game_manager.active_player.set_player_bet_state.rpc(BET_STATE.stay)
				#game_manager.active_player.set_button_disabled.rpc("button1",false)
				#game_manager.active_player.set_action_button_pressed.rpc(false)
				#game_manager.make_next_player_active()
			#if game_manager.active_player.button2_pressed:
				#print("better chose to raise the bet")
##				current_pot += current_bet - player_bet + 1
				#game_manager.raise_bet()
				#game_manager.active_player.set_player_bet_state.rpc(BET_STATE.raise)
				#game_manager.active_player.set_action_button_pressed.rpc(false)
				#game_manager.make_next_player_active()
				#
			#if game_manager.active_player.button3_pressed:
				#print("better chose to see your bet")
				#game_manager.active_player.set_player_bet_state(BET_STATE.fold)
	##			remove active player from rotation somehow
				#game_manager.make_next_player_active()
			
#	 EVERY TURN AFTER THAT
	if game_manager.previous_player != null:
		if game_manager.previous_player.bet_state == BET_STATE.none:
#			disable see because theres no previous bet to see. 
			game_manager.active_player.set_button_disabled.rpc("button1",true)

#		waits for player to make first choice
		if game_manager.previous_player.bet_state == BET_STATE.stay:
			#print("previous player chose to stay")
			
			game_manager.active_player.set_button_disabled.rpc("button1",true)
			
		if game_manager.previous_player.bet_state == BET_STATE.see:
			#print("previous player chose to see")
			
			
			game_manager.active_player.set_button_disabled.rpc("button1",true)
		if game_manager.previous_player.bet_state == BET_STATE.raise:
			#print("previous player chose to raise")
			
			game_manager.active_player.set_button_disabled.rpc("action_button",true)
			game_manager.active_player.set_button_disabled.rpc("button1",false)

		if game_manager.previous_player.bet_state == BET_STATE.fold:
			#print("previous player chose to fold")
			
			game_manager.active_player.set_button_disabled.rpc("button1",false)		
			
		
		handle_player_input()
		
		
	if players_stayed == players.current_players.size():
		states.change_state(states.deal_flop)
			















func handle_player_input():
	if game_manager.active_player.action_button_pressed:
		players_stayed +=1
		print("better chose to stay, players stayed : ", players_stayed)
		game_manager.active_player.set_player_bet_state.rpc(BET_STATE.stay)
		game_manager.active_player.set_action_button_pressed.rpc(false)
		game_manager.make_next_player_active()	
		
	if game_manager.active_player.button1_pressed:
		print("better chose to see your bet")
		players_stayed = 0
		game_manager.active_player.set_player_bet_state.rpc(BET_STATE.see)
		game_manager.active_player.set_button1_pressed.rpc(false)
		game_manager.see_bet()
		game_manager.make_next_player_active()
		
	if game_manager.active_player.button2_pressed:
		print("better chose to raise your bet")
		players_stayed = 0
		game_manager.raise_bet()
		game_manager.active_player.set_player_bet_state.rpc(BET_STATE.raise)
		game_manager.active_player.set_button2_pressed.rpc(false)
		game_manager.make_next_player_active()		
			
	if game_manager.active_player.button3_pressed:
		print("better chose to fold")
		
		game_manager.active_player.set_player_bet_state.rpc(BET_STATE.fold)
		game_manager.active_player.set_button3_pressed.rpc(false)
		game_manager.fold_player(game_manager.active_player.player_id)
#			remove active player from rotation somehow
		game_manager.make_next_player_active()
