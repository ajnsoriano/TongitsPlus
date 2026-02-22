extends Node2D

const CARD_WIDTH = 40
#const CARD_WIDTH = 25
const DEFAULT_CARD_MOVE_SPEED = 0.1

enum PlayerState {
	IDLE,
	DRAWING,
	PLAYING,
	DISCARDING
}

var state : PlayerState = PlayerState.IDLE
var player_index = 1
var player_hand = []
var HAND_X_POSITION
var HAND_Y_POSITION
var card_manager_reference
var player_state_text_reference
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#HAND_X_POSITION = $"../Camera2D".get_screen_center_position().x
	HAND_X_POSITION = self.position.x
	HAND_Y_POSITION = self.position.y
	card_manager_reference = $"../CardManager"
	player_state_text_reference = $PlayerState

func _process(delta: float) -> void:
	player_state_text_reference.text = PlayerState.find_key(state)	
	
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
		
		if card == card_manager_reference.card_being_dragged:
			card.z_index = player_hand.size() + 1
			continue
		card.z_index = i
		card.hand_position = new_position
		
		#card.z_index = i
		# Fanning out cards in hand (come back to this)
		#card.rotation_degrees = 180 + (i - player_hand.size() / 2.0) * 3
		
		animate_card_to_position(card, new_position, speed)
		
		
func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset  = HAND_X_POSITION + index * CARD_WIDTH - total_width / 2.0
	return x_offset

func update_card_order(card):
	#remove card first:
	player_hand.erase(card)
	
	var new_index = 0
	for i in range(player_hand.size()):
		if card.position.x > calculate_card_position(i):
			new_index = i + 1
	
	player_hand.insert(new_index, card)
	
func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	return tween
	
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)

func check_hand_size():
	if player_hand.size() < 13:
		return true
	return false
	
func clear():
	for card in player_hand:
		card.queue_free()
	player_hand.clear()
