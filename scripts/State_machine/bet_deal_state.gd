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
	
	
	
	if game_manager.previous_player == null:
#		waits for player to make first choice
		if game_manager.active_player.bet_state == BET_STATE.none:
			game_manager.active_player.set_button_disabled("button1",true)
			if game_manager.active_player.action_button_pressed:
				print("1st better chose to stay")
				game_manager.active_player.set_player_bet_state(BET_STATE.stay)
				game_manager.active_player.set_button_disabled("button1",false)
				game_manager.active_player.set_action_button_pressed(false)
				game_manager.make_next_player_active()
			if game_manager.active_player.button2_pressed:
				print("better chose to raise the bet")
#				current_pot += current_bet - player_bet + 1
				game_manager.active_player.set_player_bet_state(BET_STATE.raise)
				game_manager.make_next_player_active()
				
			if game_manager.active_player.button3_pressed:
				print("better chose to see your bet")
				game_manager.active_player.set_player_bet_state(BET_STATE.fold)
	#			remove active player from rotation somehow
				game_manager.make_next_player_active()
			

	elif game_manager.previous_player != null:
#		waits for player to make first choice
		if game_manager.previous_player.bet_state == BET_STATE.stay:
			print("previous player chose to stay")
			game_manager.active_player.set_button_disabled("button1",true)
		if game_manager.previous_player.bet_state == BET_STATE.see:
			print("previous player chose to see")
			game_manager.active_player.set_button_disabled("button1",true)
		if game_manager.previous_player.bet_state == BET_STATE.raise:
			print("previous player chose to raise")
			game_manager.active_player.set_button_disabled("button1",false)
		if game_manager.previous_player.bet_state == BET_STATE.raise:
			print("previous player chose to fold")
			game_manager.active_player.set_button_disabled("button1",false)		
			
		if game_manager.active_player.action_button_pressed:
			print("better chose to stay")
			game_manager.active_player.set_player_bet_state(BET_STATE.stay)
			game_manager.active_player.set_action_button_pressed(false)
			game_manager.make_next_player_active()	
			
		if game_manager.active_player.button1_pressed:
			print("better chose to see your bet")
			game_manager.active_player.set_player_bet_state(BET_STATE.see)
			game_manager.active_player.set_button1_pressed(false)
			game_manager.make_next_player_active()
			
		if game_manager.active_player.button2_pressed:
			print("better chose to raise your bet")
			game_manager.active_player.set_player_bet_state(BET_STATE.raise)
			game_manager.active_player.set_button2_pressed(false)
			game_manager.make_next_player_active()		
				
		if game_manager.active_player.button3_pressed:
			print("better chose to fold")
			game_manager.active_player.set_player_bet_state(BET_STATE.fold)
			game_manager.active_player.set_button3_pressed(false)
#			remove active player from rotation somehow
			game_manager.make_next_player_active()
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		#if game_manager.previous_player.bet_state == BET_STATE.see:
		
		
		
		
			
		if game_manager.active_player.bet_state == BET_STATE.none:
			game_manager.active_player.set_button_disabled("button1",true)
			if game_manager.active_player.action_button_pressed:
				print("better chose to stay")
				game_manager.active_player.set_player_bet_state(BET_STATE.stay)
				game_manager.make_next_player_active()
			if game_manager.active_player.bet_state == BET_STATE.stay:
				pass
#			stay(add 0 to betting amount and pool)
			if game_manager.active_player.bet_state == BET_STATE.see:
				pass
			if game_manager.active_player.bet_state == BET_STATE.raise:
				pass
	#			raise(+1 to betting amount. +1 to pool)
			if game_manager.active_player.bet_state == BET_STATE.fold:
				pass				
#			call player rpc to set button1 disabled
#			this means they have yet to make any bet, use this to disable see button , stay(add 0 to betting amount and pool),raise(+1 to betting amount. +1 to pool), fold, discard all cards, set player state to out of play. 
		if game_manager.active_player.bet_state == BET_STATE.stay:
			pass
#			stay(add 0 to betting amount and pool)
		if game_manager.active_player.bet_state == BET_STATE.see:
			pass
		if game_manager.active_player.bet_state == BET_STATE.raise:
			pass
#			raise(+1 to betting amount. +1 to pool)
		if game_manager.active_player.bet_state == BET_STATE.fold:
			pass
	
	#elif game_manager.previous_player != null:
		#if game_manager.previous_player.bet_state == BET_STATE.none:
			#pass
	#
		#if game_manager.active_player.bet_state == BET_STATE.none:
			#pass
		#if game_manager.active_player.bet_state == BET_STATE.stay:
			#pass
		#if game_manager.active_player.bet_state == BET_STATE.see:
			#pass
		#if game_manager.active_player.bet_state == BET_STATE.raise:
			#pass
		#if game_manager.active_player.bet_state == BET_STATE.fold:
			#pass
	#
#	for all of the players, starting at the dealer make them the active player and make the others active player false
# active player can now stay, and pass to the next player, raise to add 1 to the current hands pool, and see is greyed out because they are first.
# one they have made a choice it moves to the next player, if previous player placed a bet , stay is greyed out, you can See, Raise, or Fold. 
# if you see, you add 1 to the pot and pass to the next player who fces the same set of options. 
# if you raise, you add 1,and then add a second 1 to the pot. if you do this,the next person has to add in two. 
#i need to track all of the players current round buy in . or just block off anything but the otions and le tit play out till all hit stay?
# need var for bet amount, that goes up each time someone raises. if first does 1, it does +1, next player raises,now its 2, next player can hit see and it will put in two. or raise 
# and it will do bet amount plus 1 to get three, and then bet amount becomes three, 1st player who put in 1, now hits a bet amount of 3 so when they hit see, it places in the bet amount minus thier current bet amount, so 2
# bringing the current bet amount for player 1 to 3, 2nd player who paid in at 2 can his see to do bet amount of 3 minus current bet amount of 2, adds 1, to get to 3. player 3 who bought in at 3, 
# now has the option to stay, if they take it, they option to stay opens for the next person, and so forth, if any of them, choose to fold on any go around their hand is discarded,
 #buttons removed, and a wait until next ante status comes up. if any player raises, they add the current bet amount  ,3, minus thier own current bet, 3, , plus 1, bringing the bet up to 4,
 #and forcing everyone back into the loop again until everyone chooses stay , or fold. 

	
	
