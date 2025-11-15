class_name NetworkManager
extends Node
@onready var play_space: Node2D = $"../Play_Space"


func _on_host_game_button_pressed() -> void:
	become_host()


func _on_join_game_button_pressed() -> void:
	join_game()
	
	
	
	
	
	
	
	
func become_host():
	print("host game pressed")
	%Enet_Multiplayer_HUD.hide()
	MultiplayerManager.become_host()
	play_space.visible = true
	play_space.game_manager.curr_state.enter_state()
	play_space.process_mode = Node.PROCESS_MODE_INHERIT
	

func join_game():
	print("joining game")
	%Enet_Multiplayer_HUD.hide()
	MultiplayerManager.join_as_player()
	play_space.visible = true
	play_space.game_manager.curr_state.enter_state()
	play_space.process_mode = Node.PROCESS_MODE_INHERIT
