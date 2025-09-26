class_name HealthMeter
extends Node2D
@onready var health_bar: Sprite2D = $health_bar
@onready var container_bottom: Sprite2D = $container_bottom
@onready var container_middle: Sprite2D = $container_middle
@onready var container_top: Sprite2D = $container_top



func handle_health_display(health):
	health_bar.scale = health * 0.06
	
