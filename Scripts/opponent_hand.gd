extends Node2D

const CARD_WIDTH = 20
const DEFAULT_CARD_MOVE_SPEED = 0.1


var opponent_hand = []
var HAND_X_POSITION
var HAND_Y_POSITION
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#HAND_X_POSITION = $"../Camera2D".get_screen_center_position().x
	HAND_X_POSITION = self.position.x
	HAND_Y_POSITION = self.position.y
	
func add_card_to_hand(card, speed):
	if card not in opponent_hand:
		opponent_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED, false)
		
func update_hand_positions(speed):
	#for i in range(opponent_hand.size()):
		## Get new card position based on index
		#var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		#var card = opponent_hand[i]
		#card.hand_position = new_position
		#animate_card_to_position(card, new_position, speed)
	for i in range(opponent_hand.size()):
		var new_position = Vector2(HAND_X_POSITION, calculate_card_position(i))
		var card = opponent_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed, false)
		
		# Rotate cards to face inward (adjust depending on which side they’re on)
		card.rotation_degrees = -90  # Right side
		# or card.rotation_degrees = 90  # Left side
		
func calculate_card_position(index):
	#var total_width = (opponent_hand.size() - 1) * CARD_WIDTH
	#var x_offset  = HAND_X_POSITION + index * CARD_WIDTH - total_width / 2.0
	#return x_offset
	var total_height = (opponent_hand.size() - 1) * CARD_WIDTH
	var y_offset = HAND_Y_POSITION + index * CARD_WIDTH - total_height / 2.0
	return y_offset

func animate_card_to_position(card, new_position, speed, discard):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	if discard:
		tween.parallel().tween_property(card, "rotation_degrees", 0, speed)

func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
