class_name HandCursor
extends Node2D
@onready var hand_sprite: Sprite2D = $Hand_Sprite

enum HandState {point,grab}


var current_offset : Vector2

func _ready() -> void:
	handle_hand_frame_and_offset(0)
	
	

@rpc ("any_peer", "call_local", "reliable")
func handle_hand_frame_and_offset(curr_hand_state):
	
	if curr_hand_state == 1:
		hand_sprite.frame = 1
		current_offset = Vector2(-1,-25)
	else:
		hand_sprite.frame = 0
		current_offset = Vector2(29,-17)
	hand_sprite.offset = current_offset
	
