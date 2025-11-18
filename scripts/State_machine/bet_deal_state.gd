#Deal BET STATE
extends game_state

#PLAYERS CHOOSE TO STAY, RAISE OR FOLD. Based on the drawanddiscardrounds results.  
#IF PLAYERS RAISE, THEN A SECOND ROUND OF SEEING F PEOPLE WILL SEE THE BET. 
#IF UNWILLING TO SEE THE BET, A PLAYER MUST FOLD
#IF ALL BUT ONE FOLD OUT DURING A BETTING PHASE PROCEED TO PAYOUT WHERE THE REMAINER TAKES THE POT. 



func enter_state() -> void:
	print("its time to bet on your dealt hand.")
#	 set buttonsto stay hold raise
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Stay")
		player.set_button_text.rpc("button1","See")
		player.set_button_text.rpc("button2","Raise")
		player.set_button_text.rpc("button3","Fold")
	
	
	
	
func exit_state() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	pass
	
	
