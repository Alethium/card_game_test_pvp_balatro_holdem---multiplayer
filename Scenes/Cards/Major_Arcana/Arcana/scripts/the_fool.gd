class_name TheFool
extends MajorArcana

#
#
#

func _ready():
	super._ready()
	


func on_hand_played(hand_type):
	# Called after any hand is played
	

	if hand_type == "Pair":
		if !upside_down :
			print("The Fool for love gives your pair + 50 chips")
			return [self.card_name,hand_type,"chip",50]
		else:
			print("the card is facing the wrong direction to trigger ")
	if hand_type == "High Card":		
		if upside_down :
			print("The Fool for solitude gives your High Card + 4 mult")
			return [self.card_name,hand_type,"mult",4]
		else:
			print("the card is facing the wrong direction to trigger ")
