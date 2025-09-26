extends MultiplayerSynchronizer
@onready var mouse_window_detection: Node = $"../mouse_window_detection"
@onready var buttons = $"../Control"
var player_mouse_cursor_direction :Vector2
var player_mouse_cursor_position : Vector2
var clicked = false

@onready var view = get_viewport()
var screen_size 
func _ready() -> void:
	screen_size = get_parent().get_viewport_rect().size
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	player_mouse_cursor_position = view.get_mouse_position()
	player_mouse_cursor_direction.x = Input.get_axis("ui_left","ui_right")
	player_mouse_cursor_direction.y = Input.get_axis("ui_up","ui_down")
func _physics_process(delta: float) -> void:
	if mouse_window_detection.is_mouse_in_window:
		player_mouse_cursor_position = view.get_mouse_position()
		player_mouse_cursor_direction.x = Input.get_axis("ui_left","ui_right")
		player_mouse_cursor_direction.y = Input.get_axis("ui_up","ui_down")
	
	player_mouse_cursor_position = Vector2(clamp(player_mouse_cursor_position.x,0,screen_size.x),clamp(player_mouse_cursor_position.y,0,screen_size.y))
	
			

func click():			
	clicked = true	#if you are the server do the stuff below, and send it back to the player.
	print("player " ,get_parent().player_id , " clicked")	
	
	

func unclick():
	clicked = false
	print("player " ,get_parent().player_id , " unclicked")

	
	
	
	
