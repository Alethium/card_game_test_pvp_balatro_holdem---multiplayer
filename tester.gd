extends Node2D



var selected = false

@onready var label: Label = $Label




func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		update_status()	

func update_status():
	selected = %test_sync.selected
	if selected :
		label.text = "selected"
	else:
		label.text = "unselected"
