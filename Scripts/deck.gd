extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.15



var card_manager_reference
var deck = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_manager_reference = $"../CardManager"
	
	create_deck()
	deck.shuffle()
	deck.shuffle()
	deck.shuffle()
	
	$RichTextLabel.text = str(deck.size())
	
	 #Draw 13 cards
	#for i in range(0, 13):
		#draw_card($"../PlayerHand")
		
func create_deck():
	deck.clear()
	var suits = ["Spades", "Clubs", "Hearts", "Diamonds"]
	for suit in suits:
		for rank in range(1, 14): # 1 through 13
			#deck.append("%s%d" % [suit, rank])
			var card = {
				"suit": suit,
				"rank": rank,
				"id": str(suit + str(rank))
			}
			deck.append(card)

func draw_card(hand):
	if deck.size() > 0:
		var card_drawn = deck[0]
		deck.erase(card_drawn)
		
		#If player drew last card in the deck, disable the deck
		if deck.size() == 0:
			$Area2D/CollisionShape2D.disabled = true
			$Sprite2D.visible = false
			$RichTextLabel.visible = false
		
		$RichTextLabel.text = str(deck.size())
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		#var card_image_path = str("res://Art/Deck1/" + card_drawn["id"] + ".png")
		#new_card.get_node("CardImage").texture = load(card_image_path)
		new_card.set_card_data(card_drawn)
		card_manager_reference.add_child(new_card)
		new_card.position = self.position
		new_card.name = "Card"
		hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
		if hand == $"../PlayerHand":
			new_card.get_node("AnimationPlayer").play("card_flip_up")
		else:
			new_card.get_node("Area2D/CollisionShape2D").disabled = true
			if card_manager_reference.All_Face_Up:
				new_card.get_node("AnimationPlayer").play("card_flip_up")
