class_name MajorArcana
extends Card

# Joker Properties
@export var card_name: String = "name"
@export_multiline var effect_description: String = "Rightside-up:
Upside-down:"
enum EffectType {on_card,on_hand}
@export var effect_type : EffectType
@export var sell_value: int = 3  # Base sell value
@export var rarity: int = 0  # Common, Uncommon, Rare, etc.

# Modifiers that can be applied/stacked
@export var chip_modifier: int = 0
@export var mult_modifier: int = 0
@export var money_modifier: int = 0
@export var probability_modifier: float = 0.0

# Runtime variables
var active: bool = true
var edition: String = "Base"  # Foil, Holographic, Polychrome, etc.



func _ready():
	# Jokers are always face up
	face_down = false

	
func _process(_delta):
	handle_rotation()
			

func handle_rotation():
	if upside_down == true:
		%Visuals.rotation_degrees = lerp(%Visuals.rotation_degrees,180.0,0.1)
	else:
		%Visuals.rotation = lerp(%Visuals.rotation,0.0,0.1)

	
func on_card_played(card):
	# Called when any card is played
	if card.rank%2 and card.rank <= 10:
		return ["chips",card.rank]
	elif !card.rank%2 and card.rank <= 10:
		return ["chips",20]
		
func _on_card_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			upside_down = !upside_down		
