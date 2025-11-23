class_name Card
extends Button

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
var in_transit = false
var discarded = false

signal on_hover
signal off_hover
enum HEIGHT_STATE {BASE,LOWERED,LIFTED}
var current_height_state : HEIGHT_STATE = HEIGHT_STATE.BASE

@export var face_down : bool = false
@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var sync: MultiplayerSynchronizer = $MultiplayerSynchronizer

var upside_down = false



func _ready():
	visible = false
	#%Visuals.global_scale.x = 2
	#%Visuals.global_scale.y = 2
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
		%Visuals.position.y -= 15
		selected_by.append(select_by_id)
		
@rpc ("any_peer", "call_local", "reliable")
func deselect(select_by_id):
	if selected == true :
		if select_by_id == 0:
			print("deselected community")
			outline.visible = false
			selected = false
			%Visuals.position.y += 15
			selected_by = []
			
		else:	
				# Add any other visual feedback for selected cards
			print("deselected by" , select_by_id)
			if multiplayer.get_unique_id() ==  select_by_id:
				outline.visible = false
			if selected_by.has(select_by_id):
				selected = false
				%Visuals.position.y += 15
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
		print("card hovered")
		#%Visuals.global_scale.x = 2.2
		#%Visuals.global_scale.y = 2.2
		#wiggle()
		%Card_Info_Display.visible = true
		
		
@rpc ("any_peer", "call_local", "reliable")		
func change_height(height:HEIGHT_STATE):
	
	if height == HEIGHT_STATE.BASE:
		z_index = 1
		#%Visuals.global_scale = lerp(scale,Vector2(2,2),0.1)
	if height == HEIGHT_STATE.LOWERED:
		z_index = 0
		#%Visuals.global_scale = lerp(scale,Vector2(1.9,1.9),0.1)
	if height == HEIGHT_STATE.LIFTED:
		z_index = 2
		#%Visuals.global_scale = lerp(scale,Vector2(2.2,2.2),0.1)
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
	print("card unhovered")
	if face_down == false:
		%Visuals.global_scale.x = 2
		%Visuals.global_scale.y = 2
		#wiggle()
		%Card_Info_Display.visible = false
	if is_multiplayer_authority():
		off_hover.emit(self)
		
#the server will run this function	
func move_to_target(delta):
	if target_slot:
		if global_position.distance_to(target_slot.global_position) < 0.01:
			in_transit = false
			%Debug.text = str( "stationary :" , z_index )
		if global_position.distance_to(target_slot.global_position) < 25 :
			change_height.rpc(HEIGHT_STATE.BASE)
			global_position = lerp(global_position, target_slot.global_position,delta * 10)
			
		else :
			%Debug.text = str( "in transit :" , z_index )
			in_transit = true
			change_height.rpc(HEIGHT_STATE.LIFTED)
			global_position = lerp(global_position, target_slot.global_position,delta * 10)
			
		
	else:
		pass
		
func wiggle():
	var tween = create_tween()
	tween.set_parallel(true)
	#tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "rotation", deg_to_rad(5), 0.1)
	tween.tween_property(self, "rotation", deg_to_rad(-4), 0.1).set_delay(0.1)
	tween.tween_property(self, "rotation", deg_to_rad(3), 0.1).set_delay(0.1)
	tween.tween_property(self, "rotation", 0, 0.1).set_delay(0.1)
	#tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)
