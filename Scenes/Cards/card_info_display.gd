extends Control
@onready var info_text : String



	
	


	

	
@rpc ("any_peer","call_local", "reliable")
func set_info_text():
	if multiplayer.is_server():
		%Info_body.text = get_parent().info_text
	
