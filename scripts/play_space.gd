extends Node2D
enum PlayState {ante,deal_hole,hole_bet,deal_flop,flop_bet,deal_turn,turn_bet,river_deal,river_bet,showdown}

var play_state : PlayState
@onready var score_manager: ScoreManager = $score_manager
@onready var card_manager: Node2D = $card_manager
@onready var multiplayer_manager: Node2D = $multiplayer_manager
@onready var game_manager: GameManager = $game_manager



func _ready() -> void:
	print("game ready")
func _process(_delta: float) -> void:
	pass
 
