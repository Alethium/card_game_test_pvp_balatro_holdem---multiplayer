class_name NetworkManager
extends Node

func become_host():
	print("host game pressed")
	%Multiplayer_HUD.hide()
	MultiplayerManager.become_host()

func join_game():
	print("joining game")
	%Multiplayer_HUD.hide()
	MultiplayerManager.join_as_player()


func _on_host_game_button_pressed() -> void:
	become_host()


func _on_join_game_button_pressed() -> void:
	join_game()
