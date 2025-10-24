


extends Node2D
@onready var players: Node2D = $"../Players"
var all_players_full = false


@onready var major_arcana_in_play: Node2D = $"../Major_arcana_Slots"

@onready var major_modifier_deck_slot: CardSlot = $"../Major_modifier_deck_Slot"
@onready var major_modifier_discard_slot: CardSlot = $"../Major_modifier_discard_slot"

@onready var minor_card_deck_slot: CardSlot = $"../Minor_card_deck_Slot"
@onready var minor_card_discard_slot: CardSlot = $"../Minor_card_discard_slot"

@onready var minor_arcana_community_slots: Array[Node2D] = [%Minor_Arcana_Slot5, %Minor_Arcana_Slot4, %Minor_Arcana_Slot3, %Minor_Arcana_Slot2, %Minor_Arcana_Slot]
@onready var game_manager: GameManager = $"../game_manager"
@onready var spawned_cards: Node2D = $"../spawned_cards"

@onready var score_manager: Node2D = $"../score_manager"

var card_signals_connected = false
var slot_signals_connected = false
var player_signals_connected = false
#signal dealing_complete
var currently_grabbed_card : Card
var current_hovered_slot : CardSlot
var current_hovered_card : Card
var last_hovered_card : Card
var is_hovering_on_card = false
var screen_size

var dealing_index : int = 0 
var dealing = false
var reloading = false
var cards_delt = 0
var dealing_timer = 0
var slots_filled = 0
var total_slots_to_fill = 0
var minor_left_to_deal = 0

# New variables for community card dealing
var dealing_to_community = false
var community_cards_to_deal = 0
var community_dealing_timer = 0
var reloading_timer = 0

var drawn_card 
@export var Current_Minor_Deck : Minor_Arcana_Deck

var currently_spawned_cards : Array 


# Network variables
var networked_cards: Dictionary = {}  # card_id -> Card object
var card_id_counter = 100
var random_seed_value: int = 0

# In your CardSpawner
var deck_seed: int = 0
var deck_order: Array = []  # Stores card indices instead of scenes


func _ready() -> void:
	
	screen_size = get_viewport_rect().size
	if multiplayer.is_server():
		instantiate_cards()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Press Enter to debug
		debug_selection_state()	
	#if multiplayer.is_server():
		#initialize_deck_order()
	
	#Current_Minor_Deck.initialize_deck()
	
func _process(delta: float) -> void:
	for card in spawned_cards.get_children():
		card.move_to_target(delta)
		handle_card_visibility(card)
	
	Current_Minor_Deck.handle_deck_height()
	if reloading == true:	
		server_reload_deck.rpc()
	if players.current_players.size() != 0:
		handle_players_served()		

	if reloading == true:
		do_reload()


#_____________signal functions_________________________
func connect_player_signals(player):
	#player.connect("discard_request",on_discard_button_pressed)
	player.connect("player_added",_on_player_added)
	#player.connect("player_request_click",request_player_click)
	#player.connect("player_request_unclick",on_player_unclick)

func _on_player_added(player):
	players.current_players.append(player)

func connect_slot_signals(slot):
	slot.connect("on_hover",_on_hovered_slot)
	slot.connect("off_hover",_off_hovered_slot)
	
	


#__________main utility functions_____________________________________________________________

func initialize_deck_order():
	if multiplayer.is_server():
		deck_seed = randi()
		randomize()  # Reset random seed
		seed(deck_seed)
		print(deck_seed)
		# Create array of indices [0, 1, 2, ...] for your deck
		deck_order = range(Current_Minor_Deck.base_set.size())
		deck_order.shuffle()
		print(deck_order)
		print("server Deck order created. First card index: ", deck_order[0])




func instantiate_cards():
	var deck_index = 0
	for card in Current_Minor_Deck.base_set:
		#print(Current_Minor_Deck.)
		if card is PackedScene:	
			var int_card = card.instantiate()
			
			#int_card.global_position = minor_card_deck_slot.global_position
			#int_card.card_id = randi()
			
			Current_Minor_Deck.deck_of_cards.append(int_card)
			int_card.global_position = minor_card_deck_slot.global_position
			int_card.card_id = card_id_counter
			int_card.discard_slot = minor_card_discard_slot
			card_id_counter += 1
			spawned_cards.add_child(int_card)
			
			
			print(int_card," : added to deck of cards from base set at index : ",deck_index)
			deck_index += 1
			
			#Current_Minor_Deck.deck_of_cards.shuffle()
		#Current_Minor_Deck.deck_of_cards.shuffle()
	print("card_instantiation_done")
	print(Current_Minor_Deck.deck_of_cards[0])
	return	

func draw_single_card(owner_id) -> Card:
	print("draw_single_card_activated")
	
	if Current_Minor_Deck.deck_of_cards.size() == 0:
		push_error("No cards left in deck!")
		return null
	#get the node for the card we want to spawn in	
	var card_scene = Current_Minor_Deck.deck_of_cards.pop_front()
	card_scene.z_index = 5
	#remove the card from the deck
	
	Current_Minor_Deck.decrease_deck_height.rpc()
	
	#return with the call that replicates this picked card for everyone. 
	if card_scene is Node2D:
		print("spawning card node",card_scene)
		return draw_instantiated_card(card_scene,owner_id,minor_card_deck_slot.global_position)
	#elif card_scene is PackedScene:
		#print("instantiating packed scene",card_scene)
		#return spawn_card_for_all(card_scene,owner_id,minor_card_deck_slot.global_position)
		
	else:
		print("not a card")
		return null

func spawn_card_for_all(card_scene: PackedScene, owner_id: int, position: Vector2) -> Card:
#	generate a unique ID for this card
	var card_instance_id = card_id_counter
	card_id_counter += 1
	# Spawn on server first
	var card = spawn_card_instance(card_scene,card_instance_id,owner_id,position)
	print("spawning card for all", card)
		# Tell all clients to spawn this card
	#spawn_card_on_clients.rpc(card,card_instance_id, owner_id, position.x, position.y)
	
	return card

func spawn_card_instance(card_scene: PackedScene, card_id: int, owner_id: int, position: Vector2) -> Card:	
	#instantiate the scene into a node
	var card = card_scene.instantiate()
	card.card_id = card_id
	card.owner_id = owner_id
	card.global_position = position
	
	print("instantiating card for all", card)
	#add to network tracking variables
		# Add to tracking
	
	networked_cards[card_id] = card
	currently_spawned_cards.append(card)
	#add node to scene for server
	
	return card
func draw_instantiated_card(card: Node2D, owner_id: int, position: Vector2) -> Card:
		#instantiate the scene into a node
	
	#card.card_id = card_id
	card.owner_id = owner_id
	card.global_position = position
	print("adding card node for all", card)
	
	#add to network tracking variables
		# Add to tracking
	
	networked_cards[card.card_id] = card
	currently_spawned_cards.append(card)
	#add node to scene for server

	return card


func handle_card_visibility(card):
	#print("card is face down?",card.face_down)
	if card.target_slot != minor_card_discard_slot:
		if multiplayer.get_unique_id() == card.owner_id :
			#print("player is? ",multiplayer.get_unique_id())
			#print("card is face down?",card.face_down)
			#print("card owner id?",card.owner_id)
			#print("own")
			card.face_down = false
		elif card.owner_id == -1 :
			#print("player is? ",multiplayer.get_unique_id())
			#print("card is face down?",card.face_down)
			#print("card owner id?",card.owner_id)
			#print("community")
			card.face_down = false
		else:
			#print("player is? ",multiplayer.get_unique_id())
			#print("card is face down?",card.face_down)
			#print("card owner id?",card.owner_id)
			#print("opponent")
			card.face_down = true
	
	card.handle_facing()



func highlight_hovered_card(card,hovered):
	if hovered:
		card.scale = Vector2(1.1,1.1)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1

#_________recieved inputs_________________________________________________________________

func _on_deal_to_community_pressed() -> void:
	print("deal pressed by : " , multiplayer.get_unique_id())	
	
	if multiplayer.is_server():
		print("server deck report:::",Current_Minor_Deck.deck_of_cards)
		server_deal_to_community.rpc()
	else:
		print("player report:::",Current_Minor_Deck.deck_of_cards)
		request_deal_to_community.rpc_id(1)

func _on_deal_to_players_pressed() -> void:
	print("deal to players pressed")
	if multiplayer.is_server():
		
		server_deal_to_players.rpc()
		
	else:
		print("player requested deal")
		request_deal_to_players.rpc()

#func on_discard_button_pressed(player)-> void:
	#print("discard from %s pressed" % player)
	#if multiplayer.is_server():
		#server_discard_from_players.rpc(player)
	#else:
		#
		#request_discard_from_players.rpc_id(1,player)

func _on_reload_pressed() -> void:
	if multiplayer.is_server():
		print("server reload pressed")

		server_reload_deck.rpc()
	else:
		print("client reload pressed")
		
		request_reload_deck.rpc()
		
func _on_shuffle_button_pressed() -> void:
	if multiplayer.is_server():
		Current_Minor_Deck.deck_of_cards.shuffle()
		
func _on_hovered_slot(slot):
	if multiplayer.is_server():
		current_hovered_slot = slot

func _off_hovered_slot(_slot):
	if multiplayer.is_server():
		current_hovered_slot = null

func _on_clear_pressed()-> void:
	if multiplayer.is_server():
		server_clear_from_community.rpc()
	else:
		request_clear_from_community.rpc()
		
func _on_discard_pressed() -> void:
	print("Discard pressed by: ", multiplayer.get_unique_id())
	for card in currently_spawned_cards:
		print("card :", card, "selected? :", card.selected)
	if multiplayer.is_server():
		print("Server processing own discard")
		server_discard_from_players(multiplayer.get_unique_id())
	else:
		print("Client requesting discard from server")
		request_discard_from_players.rpc_id(1, multiplayer.get_unique_id())
func _on_score_pressed() -> void:
	print("scoring")
	for card in currently_spawned_cards:
		print("card :", card, "selected? :", card.sync.selected)
	if multiplayer.is_server():
		print("Server processing scoring")
		server_score_cards()
	else:
		print("Client requesting scoring server")
		request_score_cards.rpc()	
	
	
##_________________deal community cards ___________________________

@rpc("any_peer", "call_local", "reliable")
func request_deal_to_community():
		#the player clients request to deal, then the server  runs the same function 
		# Only server should process this
	if multiplayer.is_server():
		server_deal_to_community.rpc()
	else:
		server_deal_to_community.rpc(1)
	
@rpc("authority", "call_local", "reliable")
func server_deal_to_community():
	if multiplayer.is_server():
		if players.current_players.size() != 0:
			if Current_Minor_Deck.deck_of_cards.size() == 0:
				print("deck_empty")
				_on_reload_pressed()
			else:
				print("server dealing card to community")
	#			only draw card if there are cards remaining, if no cards remaining call reload.
				
				#-1 for community cards
			#	assign the target slot for the card to move to. 
				for slot in minor_arcana_community_slots:
					if slot.stored_cards.size() == 0:
						print("drawing card  : ",Current_Minor_Deck.deck_of_cards[0])
						var drawn_community_card = draw_single_card(-1)
						drawn_community_card.target_slot = slot
						Current_Minor_Deck.deck_of_cards.erase(drawn_community_card)
						#drawn_card.current_slot_id = slot.slot_id
						#deck_order.remove_at(0)
						slot.stored_cards.append(drawn_community_card)
						break
			
				


#_________________deal player cards__________________________

@rpc("any_peer", "reliable")
func request_deal_to_players():
		#the player clients request to deal, then the server  runs the same function 
		# Only server should process this
	if multiplayer.is_server():
		
		server_deal_to_players.rpc()
	else:
		
		request_deal_to_players.rpc_id(1)	

@rpc("authority", "call_local", "reliable")
func server_deal_to_players():	
	if multiplayer.is_server():
		if players.current_players.size() != 0:
			if !all_players_full:
				print("server dealing card to players")
				if Current_Minor_Deck.deck_of_cards.size() == 0 and reloading_timer == 0 and reloading == false:
					print("deck empty")
					_on_reload_pressed()
					
				if dealing_timer == 0 and reloading_timer == 0:
					var curr_deal = players.current_players[dealing_index]
						
					if curr_deal.current_hand_size < curr_deal.max_hand_size:

						var drawn_player_card = draw_single_card(curr_deal.player_id)
						
						
					#	assign the target slot for the card to move to.
						
						var new_slot = curr_deal.add_slot()
						drawn_player_card.target_slot = new_slot
						curr_deal.current_hand.append(drawn_player_card)
						Current_Minor_Deck.deck_of_cards.erase(drawn_player_card)
						if dealing_index < players.current_players.size()-1:
							dealing_index += 1
						else:
							dealing_index = 0
					else:
						if dealing_index < players.current_players.size()-1:
							dealing_index += 1
						else:
							dealing_index = 0	
						server_deal_to_players.rpc()
			else:
				print("all_players_full")
					
func handle_players_served():
	var num_players_full : int = 0
	#print("was this many full : ", num_players_full)
	for player in players.current_players:
		#print("current hand size : ",player.current_hand_size)
		#print("max hand size : ",player.max_hand_size)
		if player.current_hand_size == player.max_hand_size:
			num_players_full += 1
		#print(" now this many full : ", num_players_full)
	if num_players_full >= players.current_players.size():
		#print("all players full")
		all_players_full = true
	else:
		#print("all players not full")
		all_players_full = false
			

#_____________Discard cards from player selected____________________________
@rpc("any_peer", "reliable")
func request_discard_from_players(player_id):
	
	if multiplayer.is_server():
		print("Server received discard request for player: ", player_id)
		server_discard_from_players(player_id)

# Remove the RPC decorator from this function and make it server-only
func server_discard_from_players(player_id):
	if not multiplayer.is_server():
		return
	#print(currently_spawned_cards)
	print("Server processing discard for player: ", player_id)
	
	# Find the player
	var target_player = null
	for player in players.current_players:
		if player.player_id == player_id:
			target_player = player
			break
	
	if target_player == null:
		print("Player not found: ", player_id)
		return
	
	print("Discarding for player: ", target_player.name)
	
	# Get all selected cards for this player
	var cards_to_discard = []
	
	print(currently_spawned_cards)
	for card in currently_spawned_cards:
		
		if card.owner_id == player_id and card.selected:
			
			cards_to_discard.append(card)
			print("Found selected card to discard: ", card)
	
	# Process the discard
	for card in cards_to_discard:
		print("Discarding card: ", card)
		target_player.input_synchronizer.deselect_card(card.card_id)
		card.deselect.rpc()
		card.owner_id = 0  # zero is for discarded cards
		
		## Remove from player's selection
		#if card in target_player.selected_cards:
			#target_player.selected_cards.erase(card)
		
		# Move to discard slot
		var original_slot = card.target_slot
		if original_slot != card.discard_slot:
			target_player.remove_slot(original_slot)
		card.target_slot = card.discard_slot
		minor_card_discard_slot.stored_cards.append(card)
		
		# Remove slot from player
	
	print("Discard complete for player: ", player_id)

func debug_selection_state():
	print("=== SELECTION DEBUG ===")
	print("Local player ID: ", multiplayer.get_unique_id())
	#print(currently_spawned_cards)
	for card in currently_spawned_cards:
		var selection_owner = -1
		for player in players.current_players:
			if card in player.selected_cards:
				selection_owner = player.player_id
				break
		
		print("Card ", card.card_id, 
			  " | Owner: ", card.owner_id, 
			  " | sync.selected: ", card.sync.selected, 
			  " | local selected: ", card.selected,
			  " | In player selection: ", selection_owner)



#----------------clear cards from the community cards---------------------------------------------------
@rpc("any_peer", "call_local", "reliable")
func request_clear_from_community():
	if multiplayer.is_server():
		server_clear_from_community.rpc()
	else:
		request_clear_from_community.rpc_id(1)

@rpc("authority", "call_local", "reliable")
func server_clear_from_community():
#	remove cards from players selections if they are community cards
	for player in players.current_players:		
		var cards = player.selected_cards
		for card in cards: 
			if card.owner_id == -1:
				print("clearing selection for players")
				player.toggle_card_selection(card)
				player.selected_cards.erase(card)
				
	for slot in minor_arcana_community_slots:
		if slot.stored_cards.size() > 0:
			slot.stored_cards[0].flip()
			slot.stored_cards[0].deselect.rpc()
			slot.stored_cards[0].selectable = false
			slot.stored_cards[0].owner_id = 0 # set to zero for discard pile
			slot.stored_cards[0].target_slot = minor_card_discard_slot 
			minor_card_discard_slot.stored_cards.append(slot.stored_cards[0])
			slot.stored_cards.remove_at(0)
			
			
#----------------reload discarded cards to deck---------------------------------------------------
@rpc("any_peer", "call_local", "reliable")
func request_reload_deck():
	if multiplayer.is_server():
		print("server reload requested")
		server_reload_deck.rpc()
	else:
		print("client reload requested")
		request_reload_deck.rpc_id(1)

@rpc("authority", "call_local", "reliable")
func server_reload_deck():
	if multiplayer.is_server() and reloading == false:
		print("server reload true")
		reloading = true
		reloading_timer +=3
		
func do_reload():	
#		if you are the server you can reload
		print("server doing the reload")
#		this does the reloading

		if reloading_timer > 0:
			reloading_timer -=1
			print("timer counting down : ",reloading_timer)
			#print("reloading")
		if reloading_timer == 0:
			print("timer reached 0: ",reloading_timer)
			
			for card in minor_card_discard_slot.stored_cards:
				print("adding to deck height")
				Current_Minor_Deck.increase_deck_height.rpc()
				card.z_index = -3
				card.selectable = true
				card.target_slot = minor_card_deck_slot
				print("reloading deck with : ", card)
				minor_card_deck_slot.stored_cards.append(card)
				print(minor_card_deck_slot.stored_cards)
				print("Cards left to reload : ", minor_card_discard_slot.stored_cards)
				minor_card_discard_slot.stored_cards.erase(card)
				break
				
				

			#TODO fix this shit
		for card in minor_card_deck_slot.stored_cards:
			#print(minor_card_deck_slot.stored_cards)
			if card.global_position.distance_to(minor_card_deck_slot.global_position) <= 0.1:
				
				print("removing card to reload :  ", card)
				card.global_position = minor_card_deck_slot.global_position
				Current_Minor_Deck.deck_of_cards.append(card)
				
				print("full current deck of cards size",Current_Minor_Deck.deck_of_cards.size())
				#card.face_down = false
					
				
				minor_card_deck_slot.stored_cards.erase(card)
				#reloading_timer += 3

				print(Current_Minor_Deck.deck_height)
				
		if minor_card_deck_slot.stored_cards.size() == 0 and reloading_timer == 0:
			print("finishing the reload")
			Current_Minor_Deck.deck_of_cards.shuffle()
			reloading = false
			return
#add the cards back to the deck, shuffle the deck, recreate deck order

#----------------score player selected cards---------------------------------------------------
@rpc("any_peer", "call_local", "reliable")
func request_score_cards():
	if multiplayer.is_server():
		print("server reload requested")
		server_score_cards.rpc()
	else:
		print("client reload requested")
		request_score_cards.rpc_id(1)

@rpc("authority", "call_local", "reliable")
func server_score_cards():
	if not multiplayer.is_server():
		return
	#print(currently_spawned_cards)
	print("Server scoring players")

# Find the players and get card
	for player in players.current_players:
		var hand = []
		for card in currently_spawned_cards:
			if card.selected_by.has(player.player_id):
				hand.append(card)
		print("player %s hand"%player.player_id,hand)
		#loop through all cards, if selected by player.player_id, then add to the hand, then score it. 
		
		var hand_info = score_manager.get_hand_info(hand)
		if hand_info != null :
			#player.hand_to_play.clear()
	#		player.update_score_display(score)
			player.current_hand_display.text = str("Current Hand : ", hand_info["hand_type"])
			player.score_display.text = str("Score : ", hand_info["score"])
			print("Best hand: ", hand_info["hand_type"])
			print("Score: ", hand_info["score"])
			print("Multiplier: ", hand_info["multiplier"])
			print("Chips: ", hand_info["chips"])
			print("cards: ", hand_info["cards"])
		else:
			print("no hand to score")

	##print(currently_spawned_cards)
	#for card in currently_spawned_cards:
		#
		#if card.owner_id != 0 and card.selected:
			#print("Found selected card to score: ", card)
			#print("selected by : ", card.selected_by)
	

	#for card in cards_to_discard:
		#print("Discarding card: ", card)
		#target_player.input_synchronizer.deselect_card(card.card_id)
		#card.deselect.rpc()
		#card.owner_id = 0  # Or whatever indicates discarded
		#
		### Remove from player's selection
		##if card in target_player.selected_cards:
			##target_player.selected_cards.erase(card)
		#
		## Move to discard slot
		#var original_slot = card.target_slot
		#if original_slot != card.discard_slot:
			#target_player.remove_slot(original_slot)
		#card.target_slot = card.discard_slot
		#minor_card_discard_slot.stored_cards.append(card)
		#
		## Remove slot from player
	#
	#print("Discard complete for player: ", player_id)
#
