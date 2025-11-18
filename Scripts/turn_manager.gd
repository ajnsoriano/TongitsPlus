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
	deck_reference.draw_card(opponent_hand)
	turn_timer.start()
	await turn_timer.timeout
	
	# draw card from discard pile 
	#discard_pile.draw_top_card(opponent_hand)
	#turn_timer.start()
	#await turn_timer.timeout
	
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
	if !runs.is_empty():
		print("Runs:")
		for run in runs:
			for card in run:
				print(str(card.rank) + " of " + card.suit)
		print("-End runs")
	
	var worst_card = choose_card_to_discard(opponent_hand.opponent_hand, sets, runs)
	print("Worst card: " + str(worst_card.rank) + " of " + worst_card.suit)
	
	var safe_cards = {}
	for meld in sets:
		for card in meld:
			safe_cards[card] = true
	
	for meld in runs:
		for card in meld:
			safe_cards[card] = true
	
	# discard unwanted cards
	discard(worst_card,opponent_hand)
	# end turn
	var deadwood = []
	var deadwood_value = 0
	for card in opponent_hand.opponent_hand:
		if not safe_cards.has(card):
			deadwood.append(card)
	if !deadwood.is_empty():
		for card in deadwood:
			if card.rank > 10:
				deadwood_value += 10
			else:
				deadwood_value += card.rank
		
		print("Deadwood: ", deadwood_value)
	else:
		print("TONGITS!!!")
	# reset player deck draw
	
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	
func discard(card, hand):
	var card_to_discard = card
	
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
		#for card in suit_cards:
			#print(str(card.rank) + " of " + card.suit)
					
	return runs

func score_card_to_discard(card, hand):
	var score = 0
	
	# Higher rank = worse card
	score += card.rank 
	
	# check near-set potential
	var same_rank_count = 0
	for c in hand:
		if c.rank == card.rank and c != card:
			same_rank_count += 1
	
	# almost a set (pair)
	if same_rank_count == 1:
		score -= 5 
	
	# check near-run potential
	for c in hand:
		if c != card and c.suit == card.suit:
			if abs(c.rank - card.rank) == 1:
				score -= 4 # one rank away from a run
			if abs(c.rank - card.rank) == 2:
				score -= 2 # two ranks away from a run (not as good but still worth keeping imo)
			
	return score
	
func choose_card_to_discard(hand, sets, runs):
	
	# identify safe cards 
	var safe_cards = {}
	for meld in sets:
		for card in meld:
			safe_cards[card] = true
	
	for meld in runs:
		for card in meld:
			safe_cards[card] = true
	
	# candidates are cards not in melds
	var candidates = []
	for c in hand:
		if not safe_cards.has(c):
			candidates.append(c)
		
	if candidates.size() == 0:
		var highest = hand[0]
		for c in hand:
			if c.rank > highest.rank:
				highest = c
		return highest
	
	# score candidates
	var worst_card = null
	var highest_score = -9999
	
	for c in candidates:
		var s = score_card_to_discard(c, hand)
		if s > highest_score:
			highest_score = s
			worst_card = c
	
	return worst_card
