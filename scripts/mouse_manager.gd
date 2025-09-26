extends Node2D

@onready var hand_cursor: HandCursor = $"../Hand_Cursor"



func _process(_delta: float) -> void:
	hand_cursor.global_position = get_global_mouse_position()
