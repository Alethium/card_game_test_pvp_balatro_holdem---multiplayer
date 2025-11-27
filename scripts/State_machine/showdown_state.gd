# SCORING TIME
extends game_state
enum Phase {Selection,Scoring,Winner }
var showdown_phase : Phase = Phase.Selection
var player_hand_info = []
var players_ready = []

var player_selected_cards = []
var scoring = false
#selection
#the players select thier five cards and hit the Showdown Button
#the selected hands are sent to the scoring manager who checks for the hand, and returns score information.
#that score information, likely will contain the array of doinks to be added to the doink buffer
# all players are scored at the same time. the doinks are attributed to an array slot per player, and each of those subarrays are iterated through.

#scoring
#the players each get a bar that is divided by the highest players total, then the doinks will start ticking, and the bars will fill, 
#when a players doinks run out their score bar stops rising. the last bars doinks get faster and faster as it rises,
#until the last 3-5 where it does the the bink..bink.....bink...........Bink and the chaching plays and the siren bewbewbews and the player is showered in coins idk.  
#while this is happening there are number popups coming from each doink's value addition to the bar, as the cards related to the doing bump, and a lil noise pops. 
# the winning players bar reaches the top, and they are declared the winner of this hand.  


#winner 
#all of the chips in the pot, turn into energy, and are absobed into the winning player as it pushes thier healthbar back up to max, 
#and if it is going beyond the max, then excess starts to grow. excess bar is the total non personal health in the game you could collect. 
#
# FIX BUTTONS TO HAVE ONLY DISABLED ACTION BUTTON THAT SAYS SELECT HAND
#UNLOCK THE COMMUNITY AND HAND CARDS FOR SELECTION. 
func enter_state() -> void:
	play_space.request_status_text_change.rpc("Please Select the \n Hand you want to play")
	print("ITS TIME FOR A MOTHERFUCKIN SHOWDOWN")
	for card in card_manager.currently_spawned_cards:
		if card.owner_id != 0 or -2:
			card.selectable = true
	for player in players.current_players:
		player.set_button_text.rpc("action_button","Choose")
		player.set_button_visibility.rpc("action_button",true)
		player.set_button_visibility.rpc("button1",false)
		player.set_button_visibility.rpc("button2",false)
		player.set_button_visibility.rpc("button3",false)
		player.set_button_disabled.rpc("button1",true)
		player.set_button_disabled.rpc("button2",true)
		player.set_button_disabled.rpc("button3",true)
		player.set_button_disabled.rpc("action_button",true)

		
#	 set the game message to selecting , which 5 cards you want to play. 
func exit_state() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	if multiplayer.is_server():
		for player in players.current_players:
			player_selected_cards = game_manager.get_player_selected_cards(player.player_id)
			player.selected_cards = player_selected_cards
			
			if player_selected_cards:
				if player_selected_cards.size() > 0:
					player.set_button_text.rpc("action_button","Play Hand")
					player.set_button_disabled.rpc("action_button",false)
				
			else:
				player.set_button_text.rpc("action_button","Choose")
				player.set_button_disabled.rpc("action_button",true)
					
	
		for player in players.current_players:
			
			if player.action_button_pressed and player.selected_cards.size() > 0:
				player.set_button_text.rpc("action_button","Playing")
				if !players_ready.has(player.player_id):
					players_ready.append(player.player_id)
					
				
		
		if players_ready.size() == players.current_players.size() and scoring == false: 
			scoring = true
			for player in players.current_players:
				player_hand_info.append(game_manager.get_hand_base_score(player.player_id, game_manager.get_player_selected_cards(player.player_id)))
				print(player_hand_info)
			print("time to check those hands against the major arcana")
			play_space.request_status_text_change.rpc("all players ready \n time to check for modifiers and proceed to scoring. ")
			


# starting wth the player after the dealer, the "small blind." person.
#give the hand to the score manager to find out what the best hand is, and get back the base numbers before doinking. 
# score manager should return a hand name, the hands pre modified score. 
# this score and the hands score and mult before mods, should be displayed. 
#does the score manager create the doinks when its doing the scoring?
# then this state looks at the individual cards. left to right
# based on a timer, the card is highlighted
#
