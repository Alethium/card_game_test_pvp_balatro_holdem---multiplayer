


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
		# Sync deck order to all clients
		#sync_deck_order.rpc(deck_seed, deck_order)


#@rpc("authority", "reliable")
#func sync_deck_order(seed_value: int, order: Array):
	#print("client deck given order",deck_order)
	#print("client given seed", seed_value)
	#deck_seed = seed_value
	#seed(deck_seed)  # Set the same random seed on all clients
	#deck_order = order
	#
	#
	#print(deck_order)
	#if deck_order:
		#print("client Deck order synced. First card index: ", deck_order[0])



			
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
				drawn_card.target_position = slot.global_position
				#drawn_card.current_slot_id = slot.slot_id
				slot.stored_cards.append(drawn_card)
				break

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
	card.target_position = position
	
	#add to network tracking variables
		# Add to tracking
	networked_cards[card_id] = card
	currently_spawned_cards.append(card)
	
	#add node to scene for server
	cards_in_play.add_child(card)
	return card

##call from 	server , on self and others
#@rpc("authority", "call_local", "reliable")
#func spawn_card_on_clients(card_id:int,owner_id:int,pos_x:float,pos_y:float):
##	dont spawn twice for host, they are the server so they already see the visuals. 
	#if multiplayer.is_server():
		#return
	#if card_id in networked_cards:
		#return 
	#print("client needs to spawn card : ", card_id)
	

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
	
	if multiplayer.get_unique_id() == card.owner_id or multiplayer.get_unique_id() == -1 :
		card.face_down = true
	else:
		card.face_down = false
	card.handle_facing()
	
	
	

	

			

	

	
	
	
	
	
