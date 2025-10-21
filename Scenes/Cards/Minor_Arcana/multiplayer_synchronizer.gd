extends MultiplayerSynchronizer

@onready var current_slot_id
@onready var selected = false
@onready var selectable = true
@onready var selected_by = []
@onready var card_id: int = -1
@onready var owner_id: int = -1
@onready var network_position: Vector2
