extends Control

@export var lifespan = 50
@export var value : int
@onready var pop_text: Label = $Label
var speed = 10




func _process(delta: float) -> void:
	lifespan -= 1
	speed += 3
	if lifespan < 25 :
		modulate.a -= 0.05
	if lifespan > 0:
		pop_text.global_position.y -= speed * delta
	else:
		queue_free()
	


@rpc("any_peer","call_local","reliable")
func set_value(new_value):
		
		if new_value > 0:
			pop_text.text = str("+",abs(new_value))
		else:
			pop_text.text = str("-",abs(new_value))

	
	
