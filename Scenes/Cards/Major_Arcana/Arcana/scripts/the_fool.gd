class_name TheFool
extends MajorArcana



func _ready():
	super._ready()
	



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


func _on_card_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			upside_down = !upside_down
