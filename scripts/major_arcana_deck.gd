class_name Major_Arcana_Deck
extends Deck
@onready var card_manager: Node2D = $"../card_manager"
@onready var starting_deck_height : int  = 22



var THE_FOOL = preload("uid://dewuqaryhsymb")

var base_set: Array = [
	THE_FOOL,
	]

func _ready() -> void:
	super._ready()
	#for i in cards.base_set.size() :
		#var curr_card = cards.base_set[i]
		#deck_of_cards.append(curr_card)
		#print("added : ", curr_card)
	

	
	
# Called when the node enters the scene tree for the first time.

	#handle_hover(delta)
	#
	#if currently_spawned_cards.size() != 0:
		#for card in currently_spawned_cards:
			#card.handle_facing()
	#
	#currently_spawned_cards = cards.get_children()
	#
#
#
