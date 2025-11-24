class_name Minor_Arcana
extends Card
enum SUIT {Cups,Wands,Pentacles,Swords}
enum RANK {Ace,Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Page,Knight,Queen,King}
@export var suit : SUIT  
@export var rank : RANK
var score : int
var face_card : bool
var cursed = false




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	front.frame_coords.x = rank + 1
	front.frame_coords.y = suit 
	if rank == 0:
		score = 10
		face_card = true
	elif rank >=  1 and rank <= 9:
		score = rank + 1
		face_card = false
	elif rank >= 10:
		score = 10
		face_card = true
	info_text = str("+ ",score," Chips")
	
	
	%Card_Info_Display.set_info_text.rpc()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.

	
