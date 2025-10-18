extends MultiplayerSynchronizer



var selected = false

func _ready() -> void:

	if get_multiplayer_authority() != multiplayer.get_unique_id():
			set_process(false)
			set_physics_process(false)
	

func _on_area_2d_mouse_entered() -> void:
	if multiplayer.is_server():
		selected = !selected
