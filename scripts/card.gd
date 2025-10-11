class_name Card
extends Node2D

#@export var OWNER_ID : Player
@export var target_slot : CardSlot

@onready var back: Sprite2D = $Visuals/Back
@onready var front: Sprite2D = $Visuals/Front
@onready var card_outline: Sprite2D = $Visuals/card_outline
@onready var visuals: Node2D = $Visuals
var current_slot_id
var selected = false
var selectable = true

var card_id: int = -1
var owner_id: int = -1
var network_position: Vector2

signal on_hover
signal off_hover

@export var face_down : bool = false
@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var sync = $MultiplayerSynchronizer  # Reference to your sync node

func _ready():
	# Only the server should control the card's authoritative state
	if multiplayer.is_server():
		sync.set_multiplayer_authority(1)  # Server has authority
	else:
	# Clients can't directly modify synced properties
		sync.set_multiplayer_authority(1)

	if multiplayer.is_server():
		card_id = randi()


	


func handle_facing():

	if face_down:
		back.visible = true
		front.visible = false
	else:
		back.visible = false
		front.visible = true
		
func flip():
	print("flipping")
	face_down = !face_down
	handle_facing()
	
func _on_card_body_mouse_entered() -> void:
	print(self.name, " hovered, owner id : ",owner_id)
	flip()
	if is_multiplayer_authority():
		emit_signal("on_hover",self)

func _on_card_body_mouse_exited() -> void:
	if is_multiplayer_authority():
		off_hover.emit(self)
		
#@rpc("any_peer", "reliable")
#func update_card_visibility(should_face_down: bool, visible_to_player: int):
	#if multiplayer.get_unique_id() == visible_to_player:
		#face_down = false
	#else:
		#face_down = should_face_down
	#handle_facing()
#
#@rpc("any_peer", "unreliable")
#func sync_position(new_position: Vector2):
	#global_position = new_position
	#
#the server will run this function	
func move_to_target(delta):
	if target_slot:
		global_position = lerp(global_position, target_slot.global_position,delta * 10)
	else:
		pass
		
