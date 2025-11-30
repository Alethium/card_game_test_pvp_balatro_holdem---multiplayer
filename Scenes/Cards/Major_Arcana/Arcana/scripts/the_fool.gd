class_name TheFool
extends MajorArcana

#
#
#

func _ready():
	super._ready()
	


func on_hand_played(hand_type: String):
	# Called after any hand is played
	if hand_type:
		if !upside_down :
			return ["chip",50]
		else:
			return ["mult",4]

func _on_card_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			upside_down = !upside_down
