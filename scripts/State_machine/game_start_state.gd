#GAME_START_STATE
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
	print("game is starting")
	
	print("when all players have loaded in we will begin")
func exit_state() -> void:
	print("proceeding to ante")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	
	card_manager.instantiate_cards()
	states.change_state(states.bet_ante)
