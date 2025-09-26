class_name Major_Arcana_Deck
extends Deck
@onready var deal_icon: Sprite2D = $Deal
var currently_spawned_cards : Array  


func _ready() -> void:
	for i in cards.base_set.size() :
		var curr_card = cards.base_set[i]
		deck_of_cards.append(curr_card)
		print("added : ", curr_card)
	

	
	
# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	handle_deck_height()
	handle_hover(delta)
	
	if currently_spawned_cards.size() != 0:
		for card in currently_spawned_cards:
			card.handle_facing()
	
	currently_spawned_cards = cards.get_children()
	




func _on_Major_Arcana_deck_body_mouse_entered() -> void:
	deal_icon.visible = true

func _on_Major_Arcana_deck_body_mouse_exited() -> void:
	deal_icon.visible = false
