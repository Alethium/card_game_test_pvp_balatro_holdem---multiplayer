#DEAL HOLE STATE
extends game_state
var num_cards = 2
# once all the players are locked in on thier card choice
#then we deal in 3 cards to the community cards.
#deal 3 major arcana to the field as well. -the triumverate?  

func enter_state() -> void:
	print("its time to deal some hole")
	play_space.request_status_text_change.rpc("please discard cards you do not want, \n and you wll be dealt new cards.")
	card_manager.dealing = true
	
	
func exit_state() -> void:
	for player in players.current_players:
		player.set_button_disabled.rpc("button1",false)
		player.set_button_disabled.rpc("button2",false)
		player.set_button_disabled.rpc("button3",false)
		player.set_button_disabled.rpc("action_button",false)
		
		player.set_button_visibility.rpc("action_button",true)
		player.set_button_visibility.rpc("button1",true)
		player.set_button_visibility.rpc("button2",true)
		player.set_button_visibility.rpc("button3",true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	if card_manager.dealing_timer == 0 and num_cards > 0 :
		card_manager.dealing_timer += 20
		num_cards -= 1
		print("state machine calling for card deal to player")
		card_manager._on_deal_to_community_pressed()
		card_manager._on_deal_to_major_arcana_pressed()
	if card_manager.dealing_timer == 0 and num_cards == 0 :
		print("done dealing state ")
		card_manager.dealing = false
		print("time to go to  betting on your hand")
		states.change_state(states.discard_players)
