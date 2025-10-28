class_name Card
extends Node2D

#@export var OWNER_ID : Player
@export var target_slot : CardSlot
@export var discard_slot : CardSlot
@onready var back: Sprite2D = $Visuals/Back
@onready var front: Sprite2D = $Visuals/Front
@onready var outline: Sprite2D = $Visuals/card_outline
@onready var visuals: Node2D = $Visuals
var current_slot_id
var selected = false
var selected_by = []
var selectable = true
var marked_for_discard = false
var card_id: int = -1
var owner_id: int = -1
var network_position: Vector2

signal on_hover
signal off_hover

@export var face_down : bool = false
@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var sync: MultiplayerSynchronizer = $MultiplayerSynchronizer





func _ready():
	# Only the server should control the card's authoritative state
	if multiplayer.is_server():
		sync.set_multiplayer_authority(1)  # Server has authority
	else:
	# Clients can't directly modify synced properties
		sync.set_multiplayer_authority(1)

	if multiplayer.is_server():
		card_id = randi()
	
	 	

		
	
@rpc ("any_peer", "call_local", "reliable")
func select(select_by_id):
	# Update visual feedback based on selection state
	if multiplayer.get_unique_id() ==  select_by_id:
		outline.visible = true
	print("selected by" , select_by_id)
	if !selected_by.has(select_by_id):
		selected = true
		selected_by.append(select_by_id)
		
@rpc ("any_peer", "call_local", "reliable")
func deselect(select_by_id):
	
	if select_by_id == 0:
		print("deselected community")
		outline.visible = false
		selected = false
		selected_by = []
		
	else:	
			# Add any other visual feedback for selected cards
		print("deselected by" , select_by_id)
		if multiplayer.get_unique_id() ==  select_by_id:
			outline.visible = false
		if selected_by.has(select_by_id):
			selected = false
			selected_by.erase(select_by_id)
	
		

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
# right now the client can see the cards the server has selected 
#but the server cannot see the cards the player has selected. 
#or at least as far as the print statements go	

func _on_card_body_mouse_entered() -> void:
	if face_down == false:
		z_index = 3
		scale.x = 1.2
		scale.y = 1.2
	# Update local state before reading
	#update_status()
	
	#var is_server = multiplayer.is_server()
	#var authority = get_multiplayer_authority()
	#
	#print(self.name, " hovered")
	#print("  Owner ID: ", owner_id)
	#print(" Card ID : ", card_id)
	#print("  Is Server: ", is_server)
	#print("  Authority: ", authority)
	#print("target slot : ",target_slot)
	#print("  sync.selected: ", sync.selected)
	#print("  local selected: ", selected)
	#
	## Emit signals only if we have authority
	#if sync.get_multiplayer_authority() == multiplayer.get_unique_id():
		#on_hover.emit(self)
		#
	##if is_multiplayer_authority():
		##print(self.name, " hovered, owner id : ",owner_id, sync.selected)
##
		##emit_signal("on_hover",self)

func _on_card_body_mouse_exited() -> void:
	if face_down == false:
		z_index = 1
		scale.x = 1
		scale.y = 1
	if is_multiplayer_authority():
		off_hover.emit(self)
		
#the server will run this function	
func move_to_target(delta):
	if target_slot:
		global_position = lerp(global_position, target_slot.global_position,delta * 10)
	else:
		pass
		
