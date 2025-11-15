extends Node

const DEFAULT_CARD_MOVE_SPEED = 0.1

var turn_timer
var deck_reference
var opponent_hand
var discard_pile
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_timer = $"../TurnTimer"
	turn_timer.one_shot = true
	turn_timer.wait_time = 1.0
	deck_reference = $"../Deck"
	opponent_hand = $"../OpponentHand"
	discard_pile = $"../CardSlot"
	
	for i in range(0, 13):
		deck_reference.draw_card(opponent_hand)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_end_turn_button_pressed() -> void:
	opponent_turn()
	
func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	# check discard pile
	
	# draw card from deck
	#deck_reference.draw_card(opponent_hand)
	#turn_timer.start()
	#await turn_timer.timeout
	
	# draw card from discard pile 
	discard_pile.draw_top_card(opponent_hand)
	turn_timer.start()
	await turn_timer.timeout
	
	# look for melds
	
	# discard unwanted cards
	discard(opponent_hand)
	# end turn
	
	# reset player deck draw
	
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	
func discard(hand):
	var card_to_discard = hand.opponent_hand[4]
	
	#cards that do not make a meld
	
	#high cards
	
	var tween = hand.animate_card_to_position(card_to_discard, discard_pile.position, DEFAULT_CARD_MOVE_SPEED, true)
	card_to_discard.get_node("AnimationPlayer").play("card_flip_up")
	await tween.finished
	hand.remove_card_from_hand(card_to_discard)
	
	discard_pile.add_card(card_to_discard)
