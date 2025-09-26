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
	
func exit_state() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	pass
