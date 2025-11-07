extends Node

var turn_timer
var deck_reference
var opponent_hand
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_timer = $"../TurnTimer"
	turn_timer.one_shot = true
	turn_timer.wait_time = 1.0
	deck_reference = $"../Deck"
	opponent_hand = $"../OpponentHand"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_end_turn_button_pressed() -> void:
	opponent_turn()
	
func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false

	
	# check discard pile
	
	# draw card 
	deck_reference.draw_card(opponent_hand)
	turn_timer.start()
	await turn_timer.timeout
	# look for melds
	
	# discard unwanted cards
	
	# end turn
	
	# reset player deck draw
	
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
