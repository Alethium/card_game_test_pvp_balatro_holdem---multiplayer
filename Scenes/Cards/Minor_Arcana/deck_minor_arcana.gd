class_name Minor_Arcana_Deck
extends Deck
@onready var card_manager: Node2D = $"../card_manager"



#CUPS
var ACE_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/ace_of_cups.tscn")
var _2_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/2_of_cups.tscn")
var _3_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/3_of_cups.tscn")
var _4_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/4_of_cups.tscn")
var _5_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/5_of_cups.tscn")
var _6_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/6_of_cups.tscn")
var _7_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/7_of_cups.tscn")
var _8_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/8_of_cups.tscn")
var _9_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/9_of_cups.tscn")
var _10_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/10_of_cups.tscn")
var PAGE_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/page_of_cups.tscn")
var KNIGHT_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/knight_of_cups.tscn")
var QUEEN_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/queen_of_cups.tscn")
var KING_OF_CUPS = preload("res://Scenes/Cards/Minor_Arcana/Cups/king_of_cups.tscn")
#WANDS
var ACE_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/ace_of_wands.tscn")
var _2_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/2_of_wands.tscn")
var _3_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/3_of_wands.tscn")
var _4_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/4_of_wands.tscn")
var _5_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/5_of_wands.tscn")
var _6_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/6_of_wands.tscn")
var _7_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/7_of_wands.tscn")
var _8_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/8_of_wands.tscn")
var _9_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/9_of_wands.tscn")
var _10_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/10_of_wands.tscn")
var PAGE_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/page_of_wands.tscn")
var KNIGHT_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/knight_of_wands.tscn")
var QUEEN_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/queen_of_wands.tscn")
var KING_OF_WANDS = preload("res://Scenes/Cards/Minor_Arcana/Wands/king_of_wands.tscn")
#PENTACLES
var ACE_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/ace_of_pentacles.tscn")
var _2_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/2_of_pentacles.tscn")
var _3_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/3_of_pentacles.tscn")
var _4_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/4_of_pentacles.tscn")
var _5_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/5_of_pentacles.tscn")
var _6_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/6_of_pentacles.tscn")
var _7_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/7_of_pentacles.tscn")
var _8_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/8_of_pentacles.tscn")
var _9_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/9_of_pentacles.tscn")
var _10_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/10_of_pentacles.tscn")
var PAGE_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/page_of_pentacles.tscn")
var KNIGHT_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/knight_of_pentacles.tscn")
var QUEEN_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/queen_of_pentacles.tscn")
var KING_OF_PENTACLES = preload("res://Scenes/Cards/Minor_Arcana/Pentacles/king_of_pentacles.tscn")
#SWORDS
var ACE_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/ace_of_swords.tscn")
var _2_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/2_of_swords.tscn")
var _3_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/3_of_swords.tscn")
var _4_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/4_of_swords.tscn")
var _5_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/5_of_swords.tscn")
var _6_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/6_of_swords.tscn")
var _7_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/7_of_swords.tscn")
var _8_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/8_of_swords.tscn")
var _9_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/9_of_swords.tscn")
var _10_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/10_of_swords.tscn")
var PAGE_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/page_of_swords.tscn")
var KNIGHT_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/knight_of_swords.tscn")
var QUEEN_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/queen_of_swords.tscn")
var KING_OF_SWORDS = preload("res://Scenes/Cards/Minor_Arcana/Swords/king_of_swords.tscn")


var base_set: Array = [
	ACE_OF_CUPS,
	_2_OF_CUPS,
	_3_OF_CUPS,
	_4_OF_CUPS,
	_5_OF_CUPS,
	_6_OF_CUPS,
	_7_OF_CUPS,
	_8_OF_CUPS,
	_9_OF_CUPS,
	_10_OF_CUPS,
	PAGE_OF_CUPS,
	KNIGHT_OF_CUPS,
	QUEEN_OF_CUPS,
	KING_OF_CUPS,
	ACE_OF_WANDS,
	_2_OF_WANDS,
	_3_OF_WANDS,
	_4_OF_WANDS,
	_5_OF_WANDS,
	_6_OF_WANDS,
	_7_OF_WANDS,
	_8_OF_WANDS,
	_9_OF_WANDS,
	_10_OF_WANDS,
	PAGE_OF_WANDS,
	KNIGHT_OF_WANDS,
	QUEEN_OF_WANDS,
	KING_OF_WANDS,
	ACE_OF_PENTACLES,
	_2_OF_PENTACLES,
	_3_OF_PENTACLES,
	_4_OF_PENTACLES,
	_5_OF_PENTACLES,
	_6_OF_PENTACLES,
	_7_OF_PENTACLES,
	_8_OF_PENTACLES,
	_9_OF_PENTACLES,
	_10_OF_PENTACLES,
	PAGE_OF_PENTACLES,
	KNIGHT_OF_PENTACLES,
	QUEEN_OF_PENTACLES,
	KING_OF_PENTACLES,
	ACE_OF_SWORDS,
	_2_OF_SWORDS,
	_3_OF_SWORDS,
	_4_OF_SWORDS,
	_5_OF_SWORDS,
	_6_OF_SWORDS,
	_7_OF_SWORDS,
	_8_OF_SWORDS,
	_9_OF_SWORDS,
	_10_OF_SWORDS,
	PAGE_OF_SWORDS,
	KNIGHT_OF_SWORDS,
	QUEEN_OF_SWORDS,
	KING_OF_SWORDS,
	
	]

func _ready() -> void:
	pass
	#initialize_deck()
	

	
	
# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	handle_deck_height()
	if card_manager.currently_spawned_cards.size() != 0:
		for card in card_manager.currently_spawned_cards:
			card.handle_facing()

#func initialize_deck():
	#for i in base_set.size() :
		#var curr_card = base_set[i]
		#deck_of_cards.append(curr_card)
		#print("added : ", curr_card)
		##cards remain uninstantiated until they become visible
	#

func _on_Major_Arcana_deck_body_mouse_entered() -> void:
	pass

func _on_Major_Arcana_deck_body_mouse_exited() -> void:
	pass
