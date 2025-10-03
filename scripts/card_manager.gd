


extends Node2D
@onready var players: Node2D = $"../Players"



@onready var major_arcana_in_play: Node2D = $"../Major_arcana_Slots"

@onready var major_modifier_deck_slot: CardSlot = $"../Major_modifier_deck_Slot"
@onready var major_modifier_discard_slot: CardSlot = $"../Major_modifier_discard_slot"

@onready var minor_card_deck_slot: CardSlot = $"../Minor_card_deck_Slot"
@onready var minor_card_discard_slot: CardSlot = $"../Minor_card_discard_slot"

@onready var minor_arcana_community_slots: Array[Node2D] = [%Minor_Arcana_Slot5, %Minor_Arcana_Slot4, %Minor_Arcana_Slot3, %Minor_Arcana_Slot2, %Minor_Arcana_Slot]
@onready var game_manager: GameManager = $"../game_manager"

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
@onready var cards_in_play: Node2D = $"../cards_in_play"
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
	instantiate_cards()
	
	
	#if multiplayer.is_server():
		#initialize_deck_order()
	
	#Current_Minor_Deck.initialize_deck()
	
func _process(delta: float) -> void:
	for card in cards_in_play.get_children():
		card.move_to_target(delta)
		handle_card_visibility(card)


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


func _on_deal_to_community_pressed() -> void:
	print("deal pressed by : " , multiplayer.get_unique_id())	
	
	if multiplayer.is_server():
		print(deck_order)
		#sync_deck_order.rpc(deck_seed, deck_order)
		server_deal_to_community.rpc()
	else:
		print(deck_order)
		request_deal_to_community.rpc_id(1)
#	most things are gonna end up with this type of duality i think	
#	if server then server deal to community
#	else request server for deal to community
	

#draw card has to happen on server and draw a card out,
 #then we need to do a seperate call to match that for the client. 
#then a third one that goes through all the cards and calls a 
#function where you take the card on server, and pass it into a function thatis run by everyone
 #where your card with this ID matches position with given position. 


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
		print("server dealing card to community")
		var drawn_card = draw_single_card(deck_order[0],-1)
		deck_order.remove_at(0)
		#-1 for community cards
	#	assign the target slot for the card to move to. 
		for slot in minor_arcana_community_slots:
			if slot.stored_cards.size() == 0:
				drawn_card.target_slot = slot
				#drawn_card.current_slot_id = slot.slot_id
				slot.stored_cards.append(drawn_card)
				break
#@rpc("any_peer", "call_local", "reliable")
#func request_deal_to_players():
	#pass
	
func _on_deal_to_players_pressed() -> void:
	print("deal to players pressed")
	if multiplayer.is_server():
		print(deck_order)
		#sync_deck_order.rpc(deck_seed, deck_order)
		server_deal_to_players.rpc()
	else:
		print(deck_order)
		request_deal_to_players.rpc_id(1)
				#print("added slots to fill: ", slots_to_fill)
				#print("total slots to fill: ", total_slots_to_fill)
			#
			#dealing = true
			#dealing_timer = 0
			#slots_filled = 0  # Reset when starting a new deal	
	
@rpc("any_peer", "call_local", "reliable")
func request_deal_to_players():
		#the player clients request to deal, then the server  runs the same function 
		# Only server should process this
	if multiplayer.is_server():
		server_deal_to_players.rpc()
	else:
		server_deal_to_players.rpc(1)	
	
@rpc("authority", "call_local", "reliable")
func server_deal_to_players():	
	if multiplayer.is_server():
		print("server dealing card to players")
		
		var curr_deal = players.current_players[dealing_index]
		
		var drawn_card = draw_single_card(deck_order[0],curr_deal.player_id)
		deck_order.remove_at(0)
	#	assign the target slot for the card to move to.
		var new_slot = curr_deal.add_slot()
		drawn_card.target_slot = new_slot
		if dealing_index < players.current_players.size()-1:
			dealing_index += 1
		else:
			dealing_index = 0
		
	
	
	
	
	
	
	
	
	
	
	
	
	
func draw_single_card(card_index,owner_id) -> Card:
	print("draw_single_card_activated")
		# This should only be called on the server
	#if not multiplayer.is_server():
		#push_error("draw_single_card called on client!")
		#return null
	
	if Current_Minor_Deck.deck_of_cards.size() == 0:
		push_error("No cards left in deck!")
		return null
	#get the node for the card we want to spawn in	
	var card_scene = Current_Minor_Deck.deck_of_cards[card_index]
	#remove the card from the deck
	
	
	
	#return with the call that replicates this picked card for everyone. 
	#we give it the card scene, the community -1 in this case for community owership. 
	#and we give it the starting point of the deck of cards position (later need to adjust for height
	#so we can accurately show it coming from the top of the deck)
	return spawn_card_for_all(card_scene,owner_id,minor_card_deck_slot.global_position)
	
	
	#in theory i want this to just be independant node instances in the deck of cards that get pulled out and put back,
	#but we shall see if any of this works first
	
func spawn_card_for_all(card_scene: PackedScene, owner_id: int, position: Vector2) -> Card:
#	generate a unique ID for this card
	var card_instance_id = card_id_counter
	card_id_counter += 1
	# Spawn on server first
	var card = spawn_card_instance(card_scene,card_instance_id,owner_id,position)
	
		# Tell all clients to spawn this card
	#spawn_card_on_clients.rpc(card,card_instance_id, owner_id, position.x, position.y)
	
	return card
	
	
	
func spawn_card_instance(card_scene: PackedScene, card_id: int, owner_id: int, position: Vector2) -> Card:	
	#instantiate the scene into a node
	var card = card_scene.instantiate()
	card.card_id = card_id
	card.owner_id = owner_id
	card.global_position = position
	
	
	#add to network tracking variables
		# Add to tracking
	networked_cards[card_id] = card
	currently_spawned_cards.append(card)
	
	#add node to scene for server
	cards_in_play.add_child(card)
	return card


func instantiate_cards():
	var deck_index = 0
	for card in Current_Minor_Deck.base_set:
		#print(Current_Minor_Deck.)
		if card is PackedScene:	
			var int_card = card
			
			#int_card.global_position = minor_card_deck_slot.global_position
			#int_card.card_id = randi()
			Current_Minor_Deck.deck_of_cards.append(int_card)
			
			
			
			print(int_card," : added to deck of cards from base set at index : ",deck_index)
			deck_index += 1
			
			#Current_Minor_Deck.deck_of_cards.shuffle()
		else:
			print("card_instantiation_done")
			print(Current_Minor_Deck.deck_of_cards[0])
			return	
			
			
func handle_card_visibility(card):
	print("card is face down?",card.face_down)
	
	if multiplayer.get_unique_id() == card.owner_id :
		print("player is? ",multiplayer.get_unique_id())
		print("card is face down?",card.face_down)
		print("card owner id?",card.owner_id)
		print("own")
		card.face_down = false
	elif card.owner_id == -1 :
		print("player is? ",multiplayer.get_unique_id())
		print("card is face down?",card.face_down)
		print("card owner id?",card.owner_id)
		print("community")
		card.face_down = false
	else:
		print("player is? ",multiplayer.get_unique_id())
		print("card is face down?",card.face_down)
		print("card owner id?",card.owner_id)
		print("opponent")
		card.face_down = true
	card.handle_facing()
			
			
#-------------------------------------------------------------------

			
			
			
			
	

func discard_selected_cards(player):
	for slot in player.player_hand.get_children():
		if slot.stored_cards.size() > 0:
			if slot.stored_cards[0].selected:
				slot.stored_cards[0].selected = false
				slot.stored_cards[0].selectable = false
				
				slot.stored_cards[0].face_down = true
				Current_Minor_Deck.discard_pile.stored_cards.append(slot.stored_cards[0])
				player.current_hand.erase(slot.stored_cards[0])
				slot.stored_cards.remove_at(0)
				player.remove_slot(slot)

func discard_community_cards():
	for slot in minor_arcana_community_slots:
		if slot.stored_cards.size() > 0:
			slot.stored_cards[0].face_down = true
			slot.stored_cards[0].selected = false
			slot.stored_cards[0].selectable = false
			Current_Minor_Deck.discard_pile.stored_cards.append(slot.stored_cards[0])
			slot.stored_cards.remove_at(0)
# New function to deal specific number of cards to community
func deal_to_community_cards():
	
	if community_dealing_timer <= 0 and community_cards_to_deal > 0 and !reloading:
		var slots = minor_arcana_community_slots
		
		# Find an empty slot
		for slot in slots:
			if slot.stored_cards.size() == 0:
				# Deal the card to this empty slot
				if Current_Minor_Deck.deck_of_cards.size() > 0:
					var card = Current_Minor_Deck.deck_of_cards[0]
					slot.stored_cards.append(card)
					Current_Minor_Deck.cards.add_child(card)
					Current_Minor_Deck.deck_of_cards.remove_at(0)
					community_cards_to_deal -= 1
					community_dealing_timer = 10
					print("Dealt card to Community cards, ", community_cards_to_deal, " left to deal")
				else:
					print("Deck is empty! reloading.")
					_on_reload_pressed()
				break
		# Check if we've dealt all requested cards or if there are no more empty slots
		if community_cards_to_deal == 0:
			print("All requested community cards dealt!")
			dealing_to_community = false
			
		# Check if all community slots are full
		var all_slots_full = true
		for slot in slots:
			if slot.stored_cards.size() == 0:
				all_slots_full = false
				break
				
		if all_slots_full:
			print("All community slots are full!")
			dealing_to_community = false
# Function to start dealing to community (call this with the number of cards you want)
func deal_cards_to_community(number_of_cards: int):

	
	if dealing_to_community:
		print("Already dealing to community!")
		return
		
	if number_of_cards <= 0:
		print("Invalid number of cards requested:", number_of_cards)
		return
		
	# Check how many empty community slots we have
	var empty_slots = 0
	for slot in minor_arcana_community_slots:
		if slot.stored_cards.size() == 0:
			empty_slots += 1
	
	if empty_slots < number_of_cards:
		print("Not enough empty community slots! Requested:", number_of_cards, " Available:", empty_slots)
		number_of_cards = empty_slots  # Deal as many as we can
	
	if number_of_cards > 0:
		community_cards_to_deal = number_of_cards
		dealing_to_community = true
		community_dealing_timer = 0
		print("Starting to deal", number_of_cards, "cards to community")
func deal_card_to_player(player):
	player.add_slot()
	
	var hand = player.player_hand.get_children()
	for slot in hand:
		if slot.stored_cards.size() == 0:
			var card = Current_Minor_Deck.deck_of_cards[0]
			player.current_hand.append(card)
			slot.stored_cards.append(card)
			Current_Minor_Deck.cards.add_child(card)
			Current_Minor_Deck.deck_of_cards.remove_at(0)
			dealing_timer = 10
			slots_filled += 1
			print("Total filled slots: ", slots_filled)
			print(player.hand_size)
			print(player.current_hand.size())
			

func Deal_all_players():
		# Check if all slots are filled
	if slots_filled >= total_slots_to_fill:
		print("All hands are full! Dealing complete.")
		dealing = false
		dealing_index = 0
		total_slots_to_fill = 0
		return

	if Current_Minor_Deck.deck_of_cards.size() == 0:
		print("Deck is empty! reloading.")
		_on_reload_pressed()
		
	if dealing_timer <= 0 and !reloading:
		var current_player = players.current_players[dealing_index]
		if current_player.current_hand.size() < current_player.hand_size and dealing_timer <= 0:
			print("player :",current_player,"has ",current_player.current_hand.size()," cards")
			var cards_needed = current_player.hand_size - current_player.current_hand.size()
			print("player",current_player,"has room for", cards_needed," : deal detected")
			deal_card_to_player(current_player)
			if dealing_index < players.current_players.size() - 1:
				dealing_index += 1
			else:
				dealing_index = 0
			dealing_timer = 5 
		else: 
			print("Player ", dealing_index, " hand is full, moving to next player")
			if dealing_index < players.current_players.size() - 1:
				dealing_index += 1
			else:
				dealing_index = 0
			dealing_timer = 5  # Short delay before moving to next player
		
			
func begin_deal():
	if multiplayer.is_server():
		if dealing == false:
			for player in players.current_players:
				var slots_to_fill = player.hand_size - player.current_hand.size()
				print(player.hand_size)
				print(player.current_hand.size())
				
				total_slots_to_fill += slots_to_fill
				
				print("added slots to fill: ", slots_to_fill)
				print("total slots to fill: ", total_slots_to_fill)
			
			dealing = true
			dealing_timer = 0
			slots_filled = 0  # Reset when starting a new deal










func raycast_mouse() :
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters) 
	
	if result.size() > 0:
		return result
	return null

func raycast_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters) 
	
	if result.size() > 0:
		if result[0].collider.get_parent().is_in_group("Card"):
			return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card	= current_card
			highest_z_index = current_card.z_index
	return highest_z_card		

func on_hovered_card(card) -> void :
	if !currently_grabbed_card and !is_hovering_on_card and current_hovered_card != last_hovered_card:
		current_hovered_card = card
		if card == raycast_for_card():
			highlight_hovered_card(card,true)
			is_hovering_on_card = true
	print("hover_on")

func off_hovered_card(card) -> void :
	last_hovered_card = card
	current_hovered_card = null
	highlight_hovered_card(card,false)
	var new_hovered_card = raycast_for_card()
	if new_hovered_card and !currently_grabbed_card:
		highlight_hovered_card(new_hovered_card,true)
	else:
		is_hovering_on_card = false

func on_hovered_slot(slot):
	if multiplayer.is_server():
		current_hovered_slot = slot

func off_hovered_slot(_slot):
	if multiplayer.is_server():
		current_hovered_slot = null

func highlight_hovered_card(card,hovered):
	if hovered:
		card.scale = Vector2(1.1,1.1)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1

func highlight_selected_cards():
	for card in Current_Minor_Deck.currently_spawned_cards:
		if card.selected:
			card.card_outline.visible = true
		else:
			card.card_outline.visible = false	
			
func connect_card_signals(card):
	card.connect("on_hover",on_hovered_card)
	card.connect("off_hover",off_hovered_card)

func connect_slot_signals(slot):
	slot.connect("on_hover",on_hovered_slot)
	slot.connect("off_hover",off_hovered_slot)
	
func connect_player_signals(player):
	player.connect("discard_request",on_discard_request)
	player.connect("player_added",on_player_added)
	player.connect("player_request_click",on_player_click)
	player.connect("player_request_unclick",on_player_unclick)


func on_player_click(position):
	if multiplayer.is_server():
		if raycast_for_card() != null:
			var currently_clicked_card = raycast_for_card()
			#print(currently_clicked_card.name,"  :  ",currently_clicked_card.score,"facecard?:",currently_clicked_card.face_card)
			if currently_clicked_card.selected == false and currently_clicked_card.selectable == true:
				currently_clicked_card.selected = true
				if players.current_players[game_manager.current_player_index].hand_to_play.size() < 5:
					#this is where the code for selecting a hand breaks down, im using current player index, 
					#so its always sending to p1. since theres no turn based movement. 
					#when player is using the mouse it needs to be checking to see whose mouse, and if they can select that card, 
					#and cards need to have a container owner id that its checked against,ill set that when i do the slots connecting. 
					
					
					players.current_players[game_manager.current_player_index].hand_to_play.append(currently_clicked_card)
					print(players.current_players[game_manager.current_player_index].name, "hand to play :", players.current_players[game_manager.current_player_index].hand_to_play)
					print(currently_clicked_card,": selected")
			else:
				currently_clicked_card.selected = false
				players.current_players[game_manager.current_player_index].hand_to_play.erase(currently_clicked_card)

				print(currently_clicked_card,": deselected")
func on_player_unclick(position):
	if multiplayer.is_server():
		if currently_grabbed_card:
			currently_grabbed_card.scale = Vector2 (1.1,1.1)
			if current_hovered_slot:
				current_hovered_slot.stored_cards.append(currently_grabbed_card)
			currently_grabbed_card = null
		
		
		
func on_player_added(player):
	players.current_players.append(player)
func _on_shuffle_button_pressed() -> void:
	if multiplayer.is_server():
		Current_Minor_Deck.deck_of_cards.shuffle()

func on_discard_request(player):
	discard_selected_cards(player)
	
func _on_clear_minor_arcana_pressed() -> void:
	if multiplayer.is_server():
		discard_community_cards()


func _on_reload_pressed() -> void:
	if multiplayer.is_server():
		reloading = true
		reloading_timer = 10
	
func reload_deck():
	if multiplayer.is_server():
		if reloading == true :
			if reloading_timer > 0:
				reloading_timer -=1
			#print("reloading")
			if reloading_timer == 0:
				for card in minor_card_discard_slot.stored_cards:
					reloading_timer += 3
					card.z_index = -3
					card.selectable = true
				
					print("reloading deck with : ", card)
					minor_card_deck_slot.stored_cards.append(card)
					minor_card_discard_slot.stored_cards.erase(card)
					Current_Minor_Deck.deck_of_cards.append(card)
					break
				
			for card in minor_card_deck_slot.stored_cards:
				if card.global_position.distance_to(minor_card_deck_slot.global_position) <= 0.1:
					card.face_down = false
					card.z_index = 2	
					Current_Minor_Deck.cards.remove_child(card)
					minor_card_deck_slot.stored_cards.erase(card)
				
			
			if minor_card_deck_slot.stored_cards.size() == 0 and reloading_timer == 0:
				reloading = false
	
	

	

			

	

	
	
	
	
	
