class_name Major_Arcana_Deck
extends Deck
@onready var card_manager: Node2D = $"../card_manager"
@onready var starting_deck_height : int  = 22



var THE_FOOL = preload("uid://dewuqaryhsymb")

var base_set: Array = [
	
	THE_FOOL,
	THE_FOOL,
	THE_FOOL,
	THE_FOOL,
	THE_FOOL,
	THE_FOOL,
	THE_FOOL,
	
	]

func _ready() -> void:
	super._ready()
	deck_height = 5
func _process(_delta: float) -> void:
	super._process(_delta)
