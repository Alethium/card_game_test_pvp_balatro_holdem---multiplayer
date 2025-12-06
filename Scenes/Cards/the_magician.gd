class_name TheMagician
extends MajorArcana

#
#
#

func _ready():
	super._ready()
	


func on_card_played(card):
	# Called after any hand is played
	print("on card played, suit type",card.suit)
	
	
	
	if !upside_down :
		if card.suit == card.SUIT.Wands:
			print("The Wizard is Gentle - Played cards with Wands suit give +3 Mult when scored")
			return ["mult",3]
	elif upside_down:
		if card.suit == card.SUIT.Pentacles:
			print("The Wizard is Wrathful - Played cards with Pentacle suit give +3 Mult when scored")
			return ["mult",3]

func _on_card_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			upside_down = !upside_down
