extends Node2D
enum PlayState {ante,deal_hole,hole_bet,deal_flop,flop_bet,deal_turn,turn_bet,river_deal,river_bet,showdown}

var play_state : PlayState
@onready var score_manager: ScoreManager = $score_manager
@onready var card_manager: Node2D = $card_manager
@onready var multiplayer_manager: Node2D = $multiplayer_manager
@onready var game_manager: GameManager = $game_manager
@onready var play_space: Node2D = $"."
@onready var game_status_text : String = ""



func _ready() -> void:
	print("game ready")
	update_pot_display()
	update_score_display()
	
	
func _process(_delta: float) -> void:
	pass
 
@rpc("any_peer", "call_local", "reliable")
func request_pot_value_increase(value):
	if multiplayer.is_server():
		print("increasing potby : " , value)
		server_increase_pot_value(value)
	else:
		request_pot_value_increase.rpc_id(1,value)

@rpc("authority", "call_local", "reliable")
func server_increase_pot_value(value):
	game_manager.current_pot += value
	update_pot_display()
	
func update_pot_display():
	%current_pot_text.text = str(game_manager.current_pot)


@rpc("any_peer", "call_local", "reliable")
func request_score_value_increase(value):
	if multiplayer.is_server():
		print("increasing pot by : " , value)
		server_increase_score_value(value)
	else:
		request_score_value_increase.rpc_id(1,value)

@rpc("authority", "call_local", "reliable")
func server_increase_score_value(value):
	game_manager.current_score += value
	update_score_display()
	
func update_score_display():
	%Score_Text.text = str(game_manager.current_score)
	
	
	
	
@rpc("any_peer", "call_local", "reliable")
func request_status_text_change(text):
	if multiplayer.is_server():
		print("changing status text to : " , text)
		server_change_status_text(text)
	else:
		request_status_text_change.rpc_id(1,text)

@rpc("any_peer","call_local" ,"reliable")
func server_change_status_text(text):
	print("server updating staus display")
	update_status_display(text)
	

func update_status_display(text):
	%Game_Status_text.text = text
