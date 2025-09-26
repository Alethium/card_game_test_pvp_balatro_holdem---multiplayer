


extends Node2D
@onready var players: Node2D = $"../Players"

@export var Current_Minor_Deck : Minor_Arcana_Deck

@onready var major_arcana_in_play: Node2D = $"../Major_arcana_Slots"

@onready var major_modifier_deck_slot: CardSlot = $"../Major_modifier_deck_Slot"
@onready var major_modifier_discard_slot: CardSlot = $"../Major_modifier_discard_slot"

@onready var minor_card_deck_slot: CardSlot = $"../Minor_card_deck_Slot"
@onready var minor_card_discard_slot: CardSlot = $"../Minor_card_discard_slot"

@onready var minor_arcana_community_slots: Node2D = $"../Minor_Arcana_Community_Slots"
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

# Network variables
var networked_cards: Dictionary = {}  # card_id -> Card object
var random_seed_value: int = 0

func _ready() -> void:
	screen_size = get_viewport_rect().size

	if multiplayer.is_server():
		random_seed_value = randi()
		initialize_deck.rpc(random_seed_value)
	else:
		set_process(false)  # Clients wait for server commands

@rpc("any_peer", "call_local", "reliable")
func initialize_deck(seed_value: int):
	randomize()
	seed(seed_value)
	
	if multiplayer.is_server():
		Current_Minor_Deck.initialize_deck()
		# Sync initial deck state to all clients
		sync_deck_state.rpc(Current_Minor_Deck.deck_of_cards.size())




func _process(_delta: float) -> void:
	if multiplayer.is_server():
		server_process(_delta)
	else:
		client_process(_delta)
		#cunty change
func server_process(_delta: float) -> void:		
	highlight_selected_cards()
	
	if card_signals_connected == false:
		for card in Current_Minor_Deck.deck_of_cards:
			connect_card_signals(card)
			card_signals_connected = true
	
	if slot_signals_connected == false:
		for player in players.current_players:
			var player_hand_slots = player.player_hand.get_children()
			for slots in player_hand_slots:
				connect_slot_signals(slots)
				slot_signals_connected = true
				
	if player_signals_connected == false :
		print("connecting player signal")
		for player in players.current_players:
			connect_player_signals(player)			
		player_signals_connected = true
	
	if currently_grabbed_card != null :
		var mouse_pos = get_global_mouse_position()
		currently_grabbed_card.global_position = Vector2(clamp(mouse_pos.x,0,screen_size.x),clamp(mouse_pos.y,0,screen_size.y))
	
	if dealing == true and reloading != true:
		dealing_timer -= 1
		Deal_all_players()
		
	if reloading == true:
		reload_deck()
	# Handle community card dealing separately
	if dealing_to_community:
		community_dealing_timer -= 1
		deal_to_community_cards()

@rpc("any_peer", "reliable")
func spawn_card_for_all(card_data: Dictionary, target_player_id: int, slot_index: int):
	# Client-side card spawning
	var card_scene = preload("res://Scenes/Card.tscn")  # Adjust path as needed
	var new_card = card_scene.instantiate()
	new_card.card_id = card_data.card_id
	new_card.owner_id = target_player_id
	
	# Position card appropriately
	var target_player = get_player_by_id(target_player_id)
	if target_player:
		new_card.global_position = target_player.global_position
	
	add_child(new_card)
	return new_card
	
func get_player_by_id(player_id: int):
	for player in players.current_players:
		if player.player_id == player_id:
			return player
	return null

@rpc("any_peer", "unreliable")
func sync_card_position(card_id: int, position: Vector2):
	# Find card by ID and update position
	for card in get_tree().get_nodes_in_group("Card"):
		if card.card_id == card_id:
			card.global_position = position
			break

	
	

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
	for slot in minor_arcana_community_slots.get_children():
		if slot.stored_cards.size() > 0:
			slot.stored_cards[0].face_down = true
			slot.stored_cards[0].selected = false
			slot.stored_cards[0].selectable = false
			Current_Minor_Deck.discard_pile.stored_cards.append(slot.stored_cards[0])
			slot.stored_cards.remove_at(0)
# New function to deal specific number of cards to community
func deal_to_community_cards():
	
	if community_dealing_timer <= 0 and community_cards_to_deal > 0 and !reloading:
		var slots = minor_arcana_community_slots.get_children()
		
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
	for slot in minor_arcana_community_slots.get_children():
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






func _on_deal_pressed() -> void:
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


func _on_deal_to_community_pressed() -> void:
	if multiplayer.is_server():
		deal_cards_to_community(1)
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
	
