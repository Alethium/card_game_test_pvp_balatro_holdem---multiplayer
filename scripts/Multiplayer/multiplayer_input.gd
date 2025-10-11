extends MultiplayerSynchronizer

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

@onready var view = get_viewport()
var screen_size 
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
	#request_player_click.rpc(get_parent().player_id,player_mouse_cursor_position)	
	player_select_card(get_parent().player_id,player_mouse_cursor_position)
	

func unclick():
	clicked = false
	curr_hand_state = 0
	hand_cursor.handle_hand_frame_and_offset.rpc(curr_hand_state)	
	print(curr_hand_state)
	print("player " ,get_parent().player_id , " unclicked")




@rpc("any_peer", "call_local", "reliable")
func request_player_click(player_id,click_position):
	print("player click requested")
	if multiplayer.is_server():
		server_player_click.rpc(player_id,click_position)


@rpc("any_peer", "call_local", "reliable")	
func server_player_click(player_id,click_position):
	print("yay!",player_id,click_position)
	if multiplayer.is_server():
		var card = raycast_for_card(click_position)
		if card != null and !card.selected:
			print("yay!",card," clicked!, clicker is: ",player_id,"clicked at : ",click_position)
			if card.owner_id == player_id or card.owner_id == -1 and get_parent().selected_cards.size() <= 5 :
				print("clicked card is  allowed to be selected by this user")
				
				get_parent().toggle_card_selection(card)
				
			else:
				print("clicked card is NOT allowed to be selected by this user")
		elif card != null and card.selected:
			if card.owner_id == player_id or card.owner_id == -1 :
				print("selected card clicked for deselect")
				get_parent().toggle_card_selection(card)
				
			else:
				print("clicked card is NOT allowed to be selected by this user")

func player_select_card(player_id,click_position):
	print("yay!",player_id,click_position)
	var card = raycast_for_card(click_position)
	raycast_at_mouse(click_position)
	if card != null :
		if card not in get_parent().selected_cards:
			print("yay!",card," clicked!, clicker is: ",player_id,"clicked at : ",click_position)
			if card.owner_id == player_id or card.owner_id == -1:
				print("clicked card is  allowed to be selected by this user")
				if get_parent().selected_cards.size() < 5 :
					print("selected card clicked for select")
					get_parent().toggle_card_selection(card)
				else:
					print("max selected card reached")
			else:
				print("clicked card is NOT allowed to be selected by this user")
		else :
			if card.owner_id == player_id or card.owner_id == -1 :
				print("selected card clicked for deselect")
				get_parent().toggle_card_selection(card)
				
			else:
				print("clicked card is NOT allowed to be selected by this user")			
	else: 
		return	
	
	
	
	#if multiplayer.is_server():
		#if raycast_for_card(click_position) != null:
			#print("server found card")
			#var currently_clicked_card = raycast_for_card()
			##print(currently_clicked_card.name,"  :  ",currently_clicked_card.score,"facecard?:",currently_clicked_card.face_card)
			#if currently_clicked_card.selected == false and currently_clicked_card.selectable == true:
				#currently_clicked_card.selected = true
				#if players.current_players[game_manager.current_player_index].hand_to_play.size() < 5:
					##this is where the code for selecting a hand breaks down, im using current player index, 
					##so its always sending to p1. since theres no turn based movement. 
					##when player is using the mouse it needs to be checking to see whose mouse, and if they can select that card, 
					##and cards need to have a container owner id that its checked against,ill set that when i do the slots connecting. 
					#
					#
					#players.current_players[game_manager.current_player_index].hand_to_play.append(currently_clicked_card)
					#print(players.current_players[game_manager.current_player_index].name, "hand to play :", players.current_players[game_manager.current_player_index].hand_to_play)
					#print(currently_clicked_card,": selected")
			#else:
				#currently_clicked_card.selected = false
				#players.current_players[game_manager.current_player_index].hand_to_play.erase(currently_clicked_card)
#
				#print(currently_clicked_card,": deselected")

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
	
	
	
	
