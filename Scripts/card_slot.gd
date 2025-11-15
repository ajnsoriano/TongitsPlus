extends Node2D


var card_in_slot = false
var global_z_index = 100
var card_manager_reference
var cards_in_slot = []

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	
func add_card(card):
	# add to card stack
	cards_in_slot.append(card)
	
	# set card position to card slot position
	card.position = self.position
	var global_pos = card.global_position
	
	card.get_parent().remove_child(card)
	self.add_child(card)
	card.global_position = global_pos
	print(card.get_parent())
	
func draw_top_card():
	print("Draw top card from card slot")
	
