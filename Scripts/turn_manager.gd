extends Node

const DEFAULT_CARD_MOVE_SPEED = 0.1
var turn = 1
var turn_timer
var deck_reference
var card_manager_reference
var opponent_hand
var discard_pile
var current_player_index
var player_hand
var players = 2
var deadwood_text
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_timer = $"../TurnTimer"
	turn_timer.one_shot = true
	turn_timer.wait_time = 1.0
	deck_reference = $"../Deck"
	opponent_hand = $"../OpponentHand"
	discard_pile = $"../DiscardSlot"
	player_hand = $"../PlayerHand"
	deadwood_text = opponent_hand.get_node("DeadwoodCounter")
	
	card_manager_reference = $"../CardManager"
	card_manager_reference.connect("card_discarded", _on_card_discarded)
	
	start_game()
		#$"../EndTurnButton".disabled = false
		#$"../EndTurnButton".visible = true
		

func start_game():
	#deadwood_text.visible = false
	deck_reference.create_deck()
	for i in range(1, 13):
		deck_reference.draw_card(opponent_hand)
		deck_reference.draw_card(player_hand)
		await get_tree().create_timer(0.1).timeout
	
	var starting_player = randi_range(1, players)
	starting_player = 1 # TEMPORARY
	if starting_player == 2:
		current_player_index = 2
		opponent_turn()
	elif starting_player == 1:
		deck_reference.draw_card(player_hand)
		player_hand.state = player_hand.PlayerState.PLAYING
		current_player_index = 1


func _on_card_discarded():
	#turn_timer.wait_time = 2
	turn_timer.start()
	await turn_timer.timeout
	_on_end_turn_button_pressed()

func pass_turn():
	player_hand.state = player_hand.PlayerState.DRAWING

func _on_end_turn_button_pressed() -> void:
	current_player_index = 2
	opponent_turn()
	
func opponent_turn():
	print("TURN: ", turn)
	turn += 1
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	# check discard pile
	var draw_from_discard = check_discard_pile(opponent_hand.opponent_hand, discard_pile)
	if draw_from_discard:
		#draw from discard
		discard_pile.draw_top_card(opponent_hand)
		turn_timer.start()
		await turn_timer.timeout
	else:
		# draw card from deck
		deck_reference.draw_card(opponent_hand)
		turn_timer.start()
		await turn_timer.timeout
		
	# look for melds
	var meld_result = find_melds(opponent_hand.opponent_hand)
	var sets = meld_result["sets"]
	var runs = meld_result["runs"]
	var deadwood = meld_result["deadwood"]

	# check if cpu won before discarding 
	
	if deadwood.is_empty():
		print("COMPUTER WON BEFORE DISCARDING")
		sort_by_meld(sets, runs)
		tongits()
		return
	
	
	
	if !sets.is_empty():
		print("Sets:")
		for set_ in sets:
			for card in set_:
				print(str(card.rank) + " of " + card.suit)
		print("-End Sets")
	if !runs.is_empty():
		print("Runs:")
		for run in runs:
			for card in run:
				print(str(card.rank) + " of " + card.suit)
		print("-End runs")
	#
	var worst_card = choose_card_to_discard(opponent_hand.opponent_hand, sets, runs)
	print("Worst card: " + str(worst_card.rank) + " of " + worst_card.suit)
	
	## discard unwanted cards
	await discard(worst_card,opponent_hand)
	
	## end turn
	
	var deadwood_value = 0

	if !deadwood.is_empty():
		print("Deadwood cards:")
		for card in deadwood:
			if card != worst_card:
				print(str(card.rank) + " of " + card.suit)
				if card.rank > 10:
					deadwood_value += 10
				else:
					deadwood_value += card.rank
		
		print("Deadwood: ", deadwood_value)
	
	if deadwood_value == 0:
		sort_by_meld(sets, runs)
		tongits()
		return
	
	deadwood_text = opponent_hand.get_node("DeadwoodCounter")
	deadwood_text.text = str(deadwood_value)
		
	# reset player deck draw
	
	current_player_index = 1
	pass_turn()
	#$"../EndTurnButton".disabled = false
	#$"../EndTurnButton".visible = true
	
func reveal_cards(hand):
	for card in hand.opponent_hand:
		card.get_node("AnimationPlayer").play("card_flip_up")
	
func discard(card, hand):
	var card_to_discard = card
	
	#cards that do not make a meld
	
	#high cards
	
	var tween = hand.animate_card_to_position(card_to_discard, discard_pile.position, 0.5, true)
	card_to_discard.get_node("AnimationPlayer").play("card_flip_up")
	await tween.finished
	
	hand.remove_card_from_hand(card_to_discard)
	discard_pile.add_card(card_to_discard) 
	
func sort_by_meld(sets, runs):
	var sorted_hand = []
	for _set in sets:
		for card in _set:
			sorted_hand.append(card)
	for run in runs:
		for card in run:
			sorted_hand.append(card)
	opponent_hand.opponent_hand = sorted_hand
	opponent_hand.update_hand_positions(0.1)
	
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
	
func find_melds(hand):
	var sets = []
	var runs = []
	var deadwood = []
	var rank_map := {}
	# find sets
	for card in hand:
		if not rank_map.has(card.rank):
			rank_map[card.rank] = []
		rank_map[card.rank].append(card)
		
	for rank in rank_map.keys():
		var group = rank_map[rank]
		if group.size() >= 3:
			sets.append(group.duplicate())
	
	# find runs
	var suit_map := {}
	for card in hand:
		if not suit_map.has(card.suit):
			suit_map[card.suit] = []
		if not in_any_set(card, sets):
			suit_map[card.suit].append(card)
	
	for suit in suit_map:
		suit_map[suit].sort_custom(func(a, b): return a.rank < b.rank)

	for suit in suit_map:
		var cards = suit_map[suit]
		if cards.size() < 3:
			continue
		
		var current_run = [cards[0]]
		
		for i in range(1, cards.size()):
			var prev = cards[i - 1]
			var curr = cards[i]
			
			if curr.rank == prev.rank + 1:
				current_run.append(curr)
			else:
				if current_run.size() >= 3:
					runs.append(current_run.duplicate())
				current_run = [curr]
		
		if current_run.size() >= 3:
			runs.append(current_run)
	
	#compute deadwood
	for card in hand:
		if not in_any_meld(card, sets) and not in_any_meld(card, runs):
			deadwood.append(card)
		
	return {
		"sets": sets,
		"runs": runs,
		"deadwood": deadwood
	}
	
func in_any_meld(card, meld_list):
			for meld in meld_list:
				if card in meld:
					return true
			return false

func does_discard_complete_set(hand, card):
	var count = 0
	for c in hand:
		if c.rank == card.rank:
			count += 1
	return count >= 2
	
func does_discard_help_run(hand, card, runs, sets):
	#TODO CHANGE THIS FUNCTION TO USE RUNS RETURNED IN find_melds(), CHECK IF IT EXTENDS EXISTING
	#RUNS THEN CHECK IF CARD CAN CREATE NEW RUNS
	
	# extends a run
	for run in runs:
		if run[0].suit != card.suit:
			continue
	
		var low = run[0].rank
		var high = run.back().rank
		
		if card.rank == low - 1:
			return true
		if card.rank == high + 1:
			return true
	
	# creates new run
	
	#collect ranks of same suit that are not part of sets
	var suit_ranks = []
	for c in hand:
		if c.suit == card.suit and not in_any_set(c, sets):
			suit_ranks.append(c.rank)
	
	# (card-2, card-1, card)
	if suit_ranks.has(card.rank - 2) and suit_ranks.has(card.rank - 1):
		return true
	# (card-1, card, card+1)
	if suit_ranks.has(card.rank - 1) and suit_ranks.has(card.rank + 1):
		return true
	# (card, card+1, card+2)
	if suit_ranks.has(card.rank + 1) and suit_ranks.has(card.rank + 2):
		return true
	
	return false

func in_any_set(card, sets):
	for s in sets:
		if card in s:
			return true
	return false

func check_discard_pile(hand, discard_slot):
	var top = discard_slot.cards_in_slot.back()
	if top != null:
		#complete set
		var melds = find_melds(hand)
		var runs = melds["runs"]
		var sets = melds["sets"]
		if does_discard_complete_set(hand, top):
			return true
		#helps run
		if does_discard_help_run(hand, top, runs, sets):
			return true
	return false
	
func tongits():
	print("TONGITS!!!")
	turn_timer.wait_time = 0.5
	turn_timer.start()
	await(turn_timer) 
	#get_tree().quit()
	if !deadwood_text.visible:
		deadwood_text.visible = true
	deadwood_text.text = "COMPUTER WINS"
	
	reveal_cards(opponent_hand)
	
func _on_restart_button_pressed() -> void:
	discard_pile.clear()
	player_hand.clear()
	opponent_hand.clear()
	deck_reference.create_deck()
	start_game()
