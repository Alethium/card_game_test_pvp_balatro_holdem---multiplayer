class_name HandCursor
extends Node2D
@onready var hand_sprite: Sprite2D = $Hand_Sprite

enum Hand {point,grab}

var current_hand : Hand
var current_offset : Vector2

func _ready() -> void:
	current_hand = Hand.point


func handle_hand_frame_and_offset():
	if current_hand == Hand.grab:
		hand_sprite.frame = 1
		current_offset = Vector2(-1,-25)
	else:
		hand_sprite.frame = 0
		current_offset = Vector2(29,-17)
	
