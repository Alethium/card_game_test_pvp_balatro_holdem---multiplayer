class_name Major_Arcana_Deck
extends Deck
@onready var card_manager: Node2D = $"../card_manager"
@onready var starting_deck_height : int  = 22



const THE_FOOL = preload("uid://dewuqaryhsymb")
const THE_MAGICIAN = preload("uid://dchhob3ouxr0n")
const THE_LOVERS = preload("uid://d4ignu318k1yo")
const THE_TRANSEXUAL = preload("uid://g8eu3ud2shsp")

var base_set: Array = [
	
	THE_FOOL,
	THE_MAGICIAN,
	THE_LOVERS,
	THE_FOOL,
	THE_TRANSEXUAL,
	THE_LOVERS,
	THE_MAGICIAN,
	THE_FOOL,
	THE_MAGICIAN,
	THE_FOOL,
	THE_LOVERS,
	
	]

func _ready() -> void:
	super._ready()
	deck_height = 10
func _process(_delta: float) -> void:
	super._process(_delta)
