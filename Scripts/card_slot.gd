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
	card.z_index = 0
	# set card position to card slot position
	card.position = self.position
	var global_pos = card.global_position
	
	card.get_parent().remove_child(card)
	self.add_child(card)
	card.global_position = global_pos
	#card.position = global_pos
	
	
func draw_top_card(hand):
	if cards_in_slot.size() > 0:
		var top_card = cards_in_slot.back()
		top_card.get_parent().remove_child(top_card)
		card_manager_reference.add_child(top_card)
		top_card.global_position = self.position
		hand.add_card_to_hand(top_card, 0.1)
		if hand != $"../PlayerHand" and !card_manager_reference.All_Face_Up:
			top_card.get_node("AnimationPlayer").play("card_flip_down")
			top_card.get_node("Area2D/CollisionShape2D").disabled = true
		else:
			top_card.get_node("Area2D/CollisionShape2D").disabled = false
		cards_in_slot.pop_back()
