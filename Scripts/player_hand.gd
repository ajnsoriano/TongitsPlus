extends Node2D

const CARD_WIDTH = 40
#const CARD_WIDTH = 25
const DEFAULT_CARD_MOVE_SPEED = 0.1


var player_hand = []
var HAND_X_POSITION
var HAND_Y_POSITION
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#HAND_X_POSITION = $"../Camera2D".get_screen_center_position().x
	HAND_X_POSITION = self.position.x
	HAND_Y_POSITION = self.position.y
	
func add_card_to_hand(card, speed):
	if card not in player_hand:
		# left most card on top
		#player_hand.insert(0, card)
		
		# right most card on top (usually how i play)
		player_hand.append(card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)
		
func update_hand_positions(speed):
	for i in range(player_hand.size()):
		# Get new card position based on index
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		
		#card.z_index = i
		# Fanning out cards in hand (come back to this)
		#card.rotation_degrees = 180 + (i - player_hand.size() / 2.0) * 3s
		
		animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset  = HAND_X_POSITION + index * CARD_WIDTH - total_width / 2.0
	return x_offset

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
