# SCORING TIME
extends game_state
enum Phase {Selection,Scoring,Winner }
var showdown_phase : Phase = Phase.Selection
#selection
#the players select thier five cards and hit the Showdown Button
#the selected hands are sent to the scoring manager who checks for the hand, and returns score information.
#that score information, likely will contain the array of doinks to be added to the doink buffer
# all players are scored at the same time. the doinks are attributed to an array slot per player, and each of those subarrays are iterated through.

#scoring
#the players each get a bar that is divided by the highest players total, then the doinks will start ticking, and the bars will fill, 
#when a players doinks run out their score bar stops rising. the last bars doinks get faster and faster as it rises,
#until the last 3-5 where it does the the bink..bink.....bink...........Bink and the chaching plays and the siren bewbewbews and the player is showered in coins idk.  
#while this is happening there are number popups coming from each doink's value addition to the bar, as the cards related to the doing bump, and a lil noise pops. 
# the winning players bar reaches the top, and they are declared the winner of this hand.  


#winner 
#all of the chips in the pot, turn into energy, and are absobed into the winning player as it pushes thier healthbar back up to max, 
#and if it is going beyond the max, then excess starts to grow. excess bar is the total non personal health in the game you could collect. 
#

func enter_state() -> void:
	print("ITS TIME FOR A MOTHERFUCKIN SHOWDOWN")
#	 set the game message to selecting , which 5 cards you want to play. 
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
