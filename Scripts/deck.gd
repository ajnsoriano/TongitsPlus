extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.15

#var player_deck = ["King", "King", "King", "King", "King", "King", "King", "King"]
var player_deck = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_deck()
	player_deck.shuffle()
	player_deck.shuffle()
	player_deck.shuffle()
	
	$RichTextLabel.text = str(player_deck.size())

func create_deck():
	player_deck.clear()
	var suits = ["Spades", "Clubs", "Hearts", "Diamonds"]
	for suit in suits:
		for rank in range(1, 14): # 1 through 13
			player_deck.append("%s%d" % [suit, rank])

func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	#If player drew last card in the deck, disable the deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Art/Deck1/" + card_drawn + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	$"../CardManager".add_child(new_card)
	new_card.position = self.position
	new_card.name = "Card"
	
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
