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
	label.text = str("pre game, when game is hosted \n and all players ready we will begin",)
	check_players_ready()
#
	#
	##states.change_state(states.bet_ante)
func check_players_ready():
	if multiplayer.is_server() and players.current_players.size() > 0:
		var players_ready = 0
		for player in players.current_players:
			if player.ready_up == true:
				players_ready += 1
			if players_ready == players.current_players.size():
				print("all players ready")
				states.change_state(states.bet_ante)
