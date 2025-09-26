# mouse_boundary_detector.gd
extends Node

signal mouse_entered_window()
signal mouse_exited_window()

var is_mouse_in_window: bool = true

func _ready():
	# Connect viewport signals
	get_viewport().mouse_entered.connect(_on_mouse_entered_viewport)
	get_viewport().mouse_exited.connect(_on_mouse_exited_viewport)
	
	# Also handle focus notifications
	get_tree().root.focus_entered.connect(_on_window_focus_entered)
	get_tree().root.focus_exited.connect(_on_window_focus_exited)

func _on_mouse_entered_viewport():
	is_mouse_in_window = true
	mouse_entered_window.emit()
	print("Mouse entered window")

func _on_mouse_exited_viewport():
	is_mouse_in_window = false
	mouse_exited_window.emit()
	print("Mouse exited window")

func _on_window_focus_entered():
	# Window gained focus
	print("Window gained focus")

func _on_window_focus_exited():
	# Window lost focus
	print("Window lost focus")
	# You might want to treat this as mouse leaving too
	if is_mouse_in_window:
		is_mouse_in_window = false
		mouse_exited_window.emit()

func is_mouse_inside_window() -> bool:
	return is_mouse_in_window
