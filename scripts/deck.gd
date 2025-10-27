class_name Deck
extends Node2D
@onready var deck_body: Area2D = $deck_body


@export var cards: Node2D 
@export var discard_pile: CardSlot

var clickable : bool = false
var deck_of_cards : Array

@onready var back: Sprite2D = $visuals/Back
@onready var thickness: Sprite2D = $visuals/thickness
@onready var height_outline: Sprite2D = $visuals/height_outline
@onready var card_outline: Sprite2D = $visuals/card_outline
@onready var visuals: Node2D = $visuals

@onready var deck_height : int = 0


	

func handle_deck_height():
	#print(deck_height,"deck height deck of cards size",deck_of_cards.size())
	if deck_of_cards.size() > 0:
		visuals.modulate.a = 1
	else:
		visuals.modulate.a = 0
	
	height_outline.offset.y = deck_height/2	
	thickness.offset.y = deck_height/2
	visuals.position.y = -deck_height


func handle_hover(delta):
	if clickable:
		deck_body.scale = lerp(deck_body.scale,Vector2(1.1,1.1),delta * 3)
	else:
		deck_body.scale = lerp(deck_body.scale,Vector2(1.0,1.0),delta * 3)
# Called when the node enters the scene tree for the first time.

func _on_deck_body_mouse_entered() -> void:
	clickable = true
	print("clickable:",clickable,"node :",self)
	card_outline.visible = true
	height_outline.visible = true
	
	


func _on_deck_body_mouse_exited() -> void:
	clickable = false
	print("unclickable:",clickable)
	card_outline.visible = false
	height_outline.visible = false
	

func _on_click():
	pass
	

@rpc ("any_peer", "call_local", "reliable")
func increase_deck_height():
	deck_height += 1
@rpc ("any_peer", "call_local", "reliable")
func decrease_deck_height():
	deck_height -= 1
	
