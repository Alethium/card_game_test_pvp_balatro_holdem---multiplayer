extends Control
@onready var info_text : String
@onready var card: Card = $".."



	
	


	

	
@rpc ("any_peer","call_local", "reliable")
func set_info_text():
	if multiplayer.is_server():
		if card.upside_down:
			%Info_body.text = get_parent().down_info_text
		else:
			%Info_body.text = get_parent().up_info_text
	
