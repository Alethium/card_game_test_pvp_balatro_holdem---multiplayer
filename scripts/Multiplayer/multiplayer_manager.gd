extends Node2D

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"


var multiplayer_player_scene = preload("res://Scenes/Player/multiplayer_player.tscn")




#@onready var player_1_location: Node2D = $"../Players/Player1_location"
#@onready var player_2_location: Node2D = $"../Players/Player2_location"
#@onready var player_3_location: Node2D = $"../Players/Player3_location"
#@onready var player_4_location: Node2D = $"../Players/Player4_location"
@onready var players
@onready var card_manager
@onready var game_manager





func become_host():
	print("starting host")
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	#print(get_tree().get_current_scene().play_space.get_node("Players"))
	players = get_tree().get_current_scene().play_space.get_node("Players") 
	card_manager = get_tree().get_current_scene().play_space.get_node("card_manager") 
	game_manager = get_tree().get_current_scene().play_space.get_node("game_manager") 
	multiplayer.multiplayer_peer = server_peer
	
	_add_player_to_game(1)
	card_manager.initialize_deck_order()
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(delete_player)

func join_as_player():
	print("joining game")
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP,SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	
func _add_player_to_game(id:int):
	var player_to_add = multiplayer_player_scene.instantiate()
	print("player %s joined the game!" % id)
	player_to_add.player_id = id
	player_to_add.name = str(id)
	players.add_child(player_to_add, true)
	players.current_num_of_players += 1
	players.current_players.append(player_to_add)
	#card_manager.sync_deck_order.rpc(card_manager.deck_seed,card_manager.deck_order)
	
	var added_player = players.get_node(str(id))
	card_manager.connect_player_signals(added_player)
	game_manager.connect_player_signals(added_player)
	added_player.hand_cursor.modulate = Color.HOT_PINK
	 
	
	if players.current_num_of_players == 1:
		added_player.player_position = 1
		player_to_add.global_position = players.get_node("Player1_location").global_position 
		added_player.hand_cursor.modulate = Color.HOT_PINK
		
	elif players.current_num_of_players == 2:
		added_player.player_position = 2
		player_to_add.global_position = players.get_node("Player2_location").global_position 
		added_player.hand_cursor.modulate = Color.RED
	elif players.current_num_of_players == 3:
		added_player.player_position = 3
		player_to_add.global_position = players.get_node("Player3_location").global_position
		added_player.hand_cursor.modulate = Color.BLUE		
	elif players.current_num_of_players == 4:
		added_player.player_position = 4
		player_to_add.global_position = players.get_node("Player4_location").global_position
		added_player.hand_cursor.modulate = Color.GREEN_YELLOW		

func delete_player(id:int):
	print("player %s left the game" % id)
	if not players.has_node(str(id)):
		return
	players.current_players.erase(players.get_node(str(id)))
	players.get_node(str(id)).queue_free()
