class_name TheMagician
extends MajorArcana

#
#
#

func _ready():
	super._ready()
	


func on_card_played(card):
	# Called after any hand is played
	

	if !upside_down :
		if card.suit == card.SUIT.Wands:
			print("The Magician is Gentle - Played cards with Wands suit give +3 Mult when scored")
			return [self.card_name,card,"mult",3]
		else:
			print("the card is facing the wrong direction to trigger ")
	elif upside_down:
		if card.suit == card.SUIT.Pentacles:
			print("The Magician is Wrathful - Played cards with Pentacle suit give +3 Mult when scored")
			return [self.card_name,card,"mult",3]
		else:
			print("the card is facing the wrong direction to trigger ")
