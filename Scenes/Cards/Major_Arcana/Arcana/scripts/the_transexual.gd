class_name TheTransexual
extends MajorArcana

#
#
#

func _ready():
	super._ready()
	

# recieves the players selected cards and converts qtk or ktq
func on_scoring(cards):
	
	for card in cards :
		if card.rank == card.RANK.King:
			if !upside_down :
				
				print("The Kings are now Queens ")
				return {"origin" : self.card_name,"target" : card,"effect" : "change_rank","value" : 12}
			else:
				print("the card is facing the wrong direction to trigger ")
				
		elif card.rank == card.RANK.Queen:
			if upside_down :
				print("The Queens are now Kings ")
				return {"origin" : self.card_name,"target" : card,"effect" : "change_rank","value" : 13}
			else:
				print("the card is facing the wrong direction to trigger ")
				
	# Called after any hand is played
	#print("The Lovers , on card played, suit type : ",card.suit)
## check all cards in the player of the hands, hand that arent selected. if any of them are king or queen, this card applies. 
	#if !upside_down :
		#if card.rank == card.RANK.Queen:
			#print("The Magician is Gentle - Played cards with Wands suit give +3 Mult when scored")
			#return [self.card_name,card,"mult",3]
		#else:
			#print("the card is facing the wrong direction to trigger ")
	#elif upside_down:
		#if card.rank == card.RANK.King:
			#print("The Magician is Wrathful - Played cards with Pentacle suit give +3 Mult when scored")
			#return [self.card_name,card,"mult",3]
		#else:
			#print("the card is facing the wrong direction to trigger ")
