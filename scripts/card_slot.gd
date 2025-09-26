class_name CardSlot
extends Node2D
enum SLOT_TYPE {Minor_Arcana,Major_Arcana,Player_Hand,Opponent_Hand,Major_Discard,Minor_Discard}
@export var Slot_Type : SLOT_TYPE
signal on_hover
signal off_hover
var stored_cards:Array[Card]


func _process(delta: float) -> void:
	if stored_cards != null:
		for card in stored_cards:
			card.global_transform = lerp(card.global_transform,global_transform,delta*10)
		
		

func _on_card_slot_body_mouse_entered() -> void:
	on_hover.emit(self)


func _on_card_slot_body_mouse_exited() -> void:
	off_hover.emit(self)
