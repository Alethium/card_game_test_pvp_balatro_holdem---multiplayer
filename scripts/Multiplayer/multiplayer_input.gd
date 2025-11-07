extends MultiplayerSynchronizer
@onready var player: MultiplayerPlayer = $".."

@onready var mouse_window_detection: Node = $"../mouse_window_detection"
@onready var buttons = $"../Control"
var player_mouse_cursor_direction :Vector2
var player_mouse_cursor_position : Vector2
var clicked = false
var currently_grabbed_card
var current_hovered_slot
enum HandState {point,grab}
@onready var curr_hand_state : int = 0
@onready var hand_cursor: HandCursor = $"../Hand_Cursor"
var discarding = false
var selected_cards = []
@onready var view = get_viewport()
var screen_size 
var ready_up = false
func _ready() -> void:
	
	curr_hand_state = 0
	
	screen_size = get_parent().get_viewport_rect().size
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	player_mouse_cursor_position = view.get_mouse_position()
	player_mouse_cursor_direction.x = Input.get_axis("ui_left","ui_right")
	player_mouse_cursor_direction.y = Input.get_axis("ui_up","ui_down")
func _physics_process(_delta: float) -> void:
	
	
	if mouse_window_detection.is_mouse_in_window:
		player_mouse_cursor_position = view.get_mouse_position()
		player_mouse_cursor_direction.x = Input.get_axis("ui_left","ui_right")
		player_mouse_cursor_direction.y = Input.get_axis("ui_up","ui_down")
		
	
	player_mouse_cursor_position = Vector2(clamp(player_mouse_cursor_position.x,0,screen_size.x),clamp(player_mouse_cursor_position.y,0,screen_size.y))
		

func click():			
	clicked = true	#if you are the server do the stuff below, and send it back to the player.
	curr_hand_state = 1
	hand_cursor.handle_hand_frame_and_offset.rpc(curr_hand_state)	
	print(curr_hand_state)
	raycast_at_mouse(player_mouse_cursor_position)
	print("player " ,get_parent().player_id , " clicked")
	if multiplayer.is_server():
		server_player_click(get_parent().player_id,player_mouse_cursor_position)
	else:
		request_player_click.rpc(get_parent().player_id,player_mouse_cursor_position)	
	
	

func unclick():
	clicked = false
	curr_hand_state = 0
	hand_cursor.handle_hand_frame_and_offset.rpc(curr_hand_state)	
	print(curr_hand_state)
	print("player ",get_parent().player_id , " unclicked")



@rpc("any_peer","reliable")
func request_player_click(player_id,click_position):
	print("player click requested")
	if multiplayer.is_server():
		server_player_click.rpc(player_id,click_position)
	else:
		request_player_click.rpc_id(1,player_id,click_position)
#address this. the player can see stuff they shouldnt, and the server cant see stuff it should. 

@rpc("any_peer", "call_local", "reliable")	
func server_player_click(player_id,click_position):
	print("yay!",player_id,click_position)
	#if multiplayer.get_unique_id() == player_id:
	var card = raycast_for_card(click_position)
	if card != null and card is Card:
		if !card.selected_by.has(player_id):
			if (card.owner_id == player_id or card.owner_id == -1) and selected_cards.size() <= player.max_hand_size - 1 :
				#select_card.rpc(card.card_id)  # Send ID instead of card object
				card.select.rpc(player_id)
				selected_cards.append(card)
				print("num of cards selected : ",selected_cards.size())
				print("yay!",card," clicked!, clicker is: ",player_id,"clicked at : ",click_position)
				print("clicked card is  allowed to be selected by this user  : ",card.selected)
			else:
				print("clicked card is NOT allowed to be selected by this user  : ",card.sync.selected)
		else :
			if card.owner_id == player_id or card.owner_id == -1 :
				#deselect_card.rpc(card.card_id)
				card.deselect.rpc(player_id)
				selected_cards.erase(card)
				print("selected card clicked for deselect", card.sync.selected)
			else:
				print("clicked card is NOT allowed to be selected by this user")
				
				
	
				

func on_player_unclick(_unclick_position):
	if multiplayer.is_server():
		if currently_grabbed_card:
			currently_grabbed_card.scale = Vector2 (1.1,1.1)
			if current_hovered_slot:
				current_hovered_slot.stored_cards.append(currently_grabbed_card)
			currently_grabbed_card = null

func raycast_at_mouse(click_position):
	var space_state = get_parent().get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = click_position
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters) 
	
	if result.size() > 0:
		print(result[0].collider.get_parent(),"Found!")
		return result[0].collider.get_parent()
			
			
	return null

func raycast_for_card(click_position):
	var space_state = get_parent().get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = click_position
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters) 
	
	if result.size() > 0:
		if result[0].collider.get_parent().is_in_group("Card"):
			print(result[0].collider.get_parent(), "card found")
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
	
	
@rpc ("any_peer", "call_local", "reliable")
func select_card(card_id):
	var card = find_card_by_id(card_id)
	if card:
		selected_cards.append(card)
		print("adding selected card: ", card_id)

@rpc ("any_peer", "call_local", "reliable")
func deselect_card(card_id):
	print("removing selected card: ", card_id)
	for i in range(selected_cards.size() - 1, -1, -1):
		if selected_cards[i].card_id == card_id:
			selected_cards.remove_at(i)
	print(selected_cards, " after removal")
	

func find_card_by_id(card_id):
	# Find card in the current scene or world by ID
	for card in get_tree().get_nodes_in_group("MinorArcana"):
		if card.card_id == card_id:
			return card
	return null


#func _on_ready_button_pressed() -> void:
	#print("player ready button pressed")
	#if multiplayer.is_server():	
		#if multiplayer.get_unique_id() == player.player_id:
			#server_player_ready.rpc(player.player_id)
	#else:
			#
		#if multiplayer.get_unique_id() == player.player_id:
			#request_player_ready.rpc(player.player_id)
	#
#@rpc("any_peer","reliable")	
#func request_player_ready(player_id):
	#print("player ready requested")
	#if multiplayer.is_server():
		#server_player_ready.rpc(player_id)
	#else:
		#request_player_ready.rpc_id(1,player_id)
#
#
#@rpc("any_peer", "call_local", "reliable")	
#func server_player_ready(player_id):
	#if multiplayer.is_server():	
		#if !ready_up:
			#print("player : ", player_id, " is ready")
			#ready_up = true
#
		#else:
			#print("player : ", player_id, " is not ready")
			#ready_up = false
