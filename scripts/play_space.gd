extends Node2D
enum PlayState {ante,deal_hole,hole_bet,deal_flop,flop_bet,deal_turn,turn_bet,river_deal,river_bet,showdown}

var play_state : PlayState
@onready var score_manager: ScoreManager = $score_manager
@onready var card_manager: Node2D = $card_manager
@onready var multiplayer_manager: Node2D = $multiplayer_manager
@onready var game_manager: GameManager = $game_manager
@onready var play_space: Node2D = $"."
@onready var score_display: GameScoreDisplay = $UI/Score_Display # Assuming you have a ScoreDisplay node in your scene
@onready var game_status_text: Label = %Game_Status_text


func _ready() -> void:
	print("game ready")
	update_pot_display()
	update_score_display()
	
	
func _process(_delta: float) -> void:
	update_pot_display()


# ===== SCORE DISPLAY FUNCTIONS =====

@rpc("any_peer", "call_local", "reliable")
func request_score_value_increase(value):
	if multiplayer.is_server():
		print("increasing score by : ", value)
		server_increase_score_value(value)
	else:
		request_score_value_increase.rpc_id(1, value)

@rpc("authority", "call_local", "reliable")
func server_increase_score_value(value):
	game_manager.current_score += value
	
	update_score_display()
	
func update_score_display():
	if score_display and score_display.score:
		score_display.score.text = str(game_manager.current_score)

@rpc("any_peer", "call_local", "reliable")
func request_status_text_change(text):
	if multiplayer.is_server():
		print("changing status text to : ", text)
		server_change_status_text(text)
	else:
		request_status_text_change.rpc_id(1, text)  # Send to server (ID 1)

@rpc("authority", "call_local", "reliable")  # Changed from "any_peer" to "authority"
func server_change_status_text(text):
	print("server updating status display")
	update_status_display(text)

	
func update_status_display(text):
	# Add null check to avoid errors
	if has_node("%Game_Status_text"):
		game_status_text.text = text
		print("Updated status display to: ", text)
	else:
		print("ERROR: Game_Status_text node not found!")
	



@rpc("any_peer", "call_local", "reliable")
func request_pot_value_increase(value):
	if multiplayer.is_server():
		print("increasing pot by : ", value)
		server_increase_pot_value(value)
	else:
		request_pot_value_increase.rpc_id(1, value)

@rpc("authority", "call_local", "reliable")
func server_increase_pot_value(value):
	game_manager.current_pot += value
	
	update_pot_display()
	
func update_pot_display():
	score_display.pot.text = str(game_manager.current_pot, " / ", game_manager.current_bet)


# ===== NEW FUNCTIONS FOR CHIPS AND MULTIPLIER DISPLAY =====

@rpc("any_peer", "call_local", "reliable")
func request_chips_display_update(text):
	if multiplayer.is_server():
		server_update_chips_display(text)
	else:
		request_chips_display_update.rpc_id(1, text)

@rpc("authority", "call_local", "reliable")
func server_update_chips_display(value):
	
	update_chips_display(value)

func update_chips_display(value):
	if score_display and score_display.chips:
		score_display.chips.text = value


@rpc("any_peer", "call_local", "reliable")
func request_mult_display_update(value):
	if multiplayer.is_server():
		server_update_mult_display(value)
	else:
		request_mult_display_update.rpc_id(1, value)

@rpc("authority", "call_local", "reliable")
func server_update_mult_display(value):
	
	update_mult_display(value)

func update_mult_display(value):
	if score_display and score_display.mult:
		score_display.mult.text = value


# ===== CONVENIENCE FUNCTIONS =====

func update_all_score_displays(score: int = -1, chips: String = "", multiplier: String = ""):
	"""Update all score display elements at once"""
	if score >= 0:
		game_manager.current_score = score
		
		update_score_display()
	
	if chips != "":
		update_chips_display(chips)
	
	if multiplier != "":
		update_mult_display(multiplier)


@rpc("any_peer", "call_local", "reliable")
func request_update_all_displays(score: int = -1, chips: String = "", multiplier: String = ""):
	if multiplayer.is_server():
		server_update_all_displays(score, chips, multiplier)
	else:
		request_update_all_displays.rpc_id(1, score, chips, multiplier)

@rpc("authority", "call_local", "reliable")
func server_update_all_displays(score: int = -1, chips: String = "", multiplier: String = ""):
	update_all_score_displays(score, chips, multiplier)
