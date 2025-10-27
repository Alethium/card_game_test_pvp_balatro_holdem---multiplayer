class_name DiscardPile
extends Deck


var discarded_cards = []


func _ready() -> void:
	super._ready()
	handle_deck_height()
