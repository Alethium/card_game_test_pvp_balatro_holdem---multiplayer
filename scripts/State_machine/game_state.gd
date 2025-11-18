class_name game_state
extends Node
# Called when the node enters the scene tree for the first time.
enum PlayState {game_start,ante,deal_players,deal_hole,hole_bet,deal_flop,flop_bet,deal_turn,turn_bet,river_deal,river_bet,showdown}

@export var play_state : PlayState
 
var players
var states
var card_manager
var game_manager
var score_manager
var display
var label
var play_space

func enter_state() -> void:
	pass # Replace with function body.
func exit_state() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	pass
