class_name Minor_Arcana
extends Card
enum SUIT {Cups,Wands,Pentacles,Swords}
enum RANK {Ace,Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Page,Knight,Queen,King}
@export var suit : SUIT  
@export var rank : RANK
var base_score : int
var mod_score : int = base_score
var face_card : bool
var cursed = false
var temp_suit : SUIT   
var temp_rank : RANK




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	temp_rank = rank
	temp_suit = suit
	update_visual()
	if rank == 0:
		base_score = 10
		face_card = true
	elif rank >=  1 and rank <= 9:
		base_score = rank + 1
		face_card = false
	elif rank >= 10:
		base_score = 10
		face_card = true
	up_info_text = str("+ ",base_score," Chips")
	
	
	#%Card_Info_Display.set_info_text.rpc()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.

	
func update_visual():
	front.frame_coords.x = temp_rank + 1
	front.frame_coords.y = temp_suit 
