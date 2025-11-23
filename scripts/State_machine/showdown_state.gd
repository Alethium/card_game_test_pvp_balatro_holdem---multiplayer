# SCORING TIME
extends game_state




func enter_state() -> void:
	print("ITS TIME FOR A MOTHERFUCKIN SHOWDOWN")
func exit_state() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	pass


# starting wth the player after the dealer, the "small blind." person.
#give the hand to the score manager to find out what the best hand is, and get back the base numbers before doinking. 
# score manager should return a hand name, the hands pre modified score. 
# this score and the hands score and mult before mods, should be displayed. 
#does the score manager create the doinks when its doing the scoring?
# then this state looks at the individual cards. left to right
# based on a timer, the card is highlighted
#
