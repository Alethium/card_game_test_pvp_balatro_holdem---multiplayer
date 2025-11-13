#DEAL PLAYERS STATE
extends game_state
var num_cards
#dealer has an opportunity to alter the deck in this moment 
#apply modifiers to specific cards ala tarot cards. change suit, value, lucky, glass, gold, stone. 
# all players are dealt their hand
# really not sure yet how many cards are appropriate. 
# will this game deal just two like normal and a larger hand of spells and hijinx?
# once all the players # once all the players have the hand they want to keep
func enter_state() -> void:
	num_cards = 5*players.current_players.size()
	card_manager.dealing = true
	card_manager.Current_Minor_Deck.deck_of_cards.shuffle()
	print("it is time to deal cards!!!!!")
	
		
func exit_state() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(_delta: float) -> void:
	if card_manager.dealing_timer == 0 and num_cards > 0 :
		card_manager.dealing_timer += 20
		num_cards -= 1
		print("state machine calling for card deal to player")
		card_manager._on_deal_to_players_pressed()
