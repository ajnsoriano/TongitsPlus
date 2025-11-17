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
	
	# Look for sets
	var sets = detect_sets(opponent_hand)
	if !sets.is_empty():
		print("Sets:")
		for set_ in sets:
			for card in set_:
				print(str(card.rank) + " of " + card.suit)
		print("-End Sets")
	
	# Look for runs
	var runs = detect_runs(opponent_hand)
	print(runs)
	# discard unwanted cards
	#discard(opponent_hand)
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

func detect_sets(hand):
	var sets = []
	var rank_dictionary = {}
	
	for card in hand.opponent_hand:
		if not rank_dictionary.has(card.rank):
			rank_dictionary[card.rank] = []
		rank_dictionary[card.rank].append(card)
		
	for rank_cards in rank_dictionary.values():
		if rank_cards.size() >= 3:
			sets.append(rank_cards)
		
	return sets

func detect_runs(hand):
	var runs = []
	var suit_dictionary = {}
	
	# Group by suit
	for card in hand.opponent_hand:
		if not suit_dictionary.has(card.suit):
			suit_dictionary[card.suit] = []
		suit_dictionary[card.suit].append(card)
	
	#print(suit_dictionary)
	
	# Sort and find consecutive sequences
	for suit_cards in suit_dictionary.values():
		
		suit_cards.sort_custom(func(a,b): return a.rank < b.rank)
		var current_run = []
		
		for i in range(suit_cards.size()):
			if current_run.is_empty():
				current_run.append(suit_cards[i])
			else:
				var last_card = current_run.back()
				if suit_cards[i].rank == last_card.rank + 1:
					current_run.append(suit_cards[i])
				else:
					if current_run.size() >= 3:
						runs.append(current_run.duplicate())
					current_run = [suit_cards[i]]
		
		if current_run.size() >= 3:
			runs.append(current_run)
		for card in suit_cards:
			print(str(card.rank) + " of " + card.suit)
	
	#for suit in suit_dictionary.keys():
		#var suit_cards = suit_dictionary[suit]
		#var sortable := []
		#for card in suit_cards:
			#sortable.append({"rank": int(card.rank), "card": card})
		#
		#sortable.sort()
		#
		#var sorted_cards := []
		#for item in sortable:
			#sorted_cards.append(item.card)
		#
		#for card in sorted_cards:
			#print(str(card.rank) + " of " + card.suit)
					
	return runs
