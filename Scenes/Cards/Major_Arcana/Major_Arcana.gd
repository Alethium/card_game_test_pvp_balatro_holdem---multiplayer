class_name MajorArcana
extends Card

# Joker Properties
@export var joker_name: String = "Joker"
@export_multiline var effect_description: String = "Rightside-up:
Upside-down:"
@export var sell_value: int = 3  # Base sell value
@export var rarity: int = 0  # Common, Uncommon, Rare, etc.

# Modifiers that can be applied/stacked
@export var chip_modifier: int = 0
@export var mult_modifier: int = 0
@export var money_modifier: int = 0
@export var probability_modifier: float = 0.0
var upside_down = false
# Runtime variables
var active: bool = true
var edition: String = "Base"  # Foil, Holographic, Polychrome, etc.

func _ready():
	# Jokers are always face up
	face_down = false


func apply_upside_effect(hand_type: String, played_cards: Array, current_chips: int, current_mult: int):
	pass

	
func apply_downside_effect(hand_type: String, played_cards: Array, current_chips: int, current_mult: int):
	pass
	
func on_round_start():
	# Called at the start of each round
	pass

func on_round_end():
	# Called at the end of each round
	pass

func on_card_played(card):
	# Called when any card is played
	pass

func on_hand_played(hand_type: String, cards: Array):
	# Called after a hand is played
	pass
