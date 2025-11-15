extends Node2D

signal hovered
signal hovered_off

var hand_position

var suit : String
var rank : int
var id : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)

func set_card_data(card_data):
	suit = card_data["suit"]
	rank = card_data["rank"]
	id = card_data["id"]
	var card_image_path = str("res://Art/Deck1/" + id + ".png")
	$CardImage.texture = load(card_image_path)

func print_card_data():
	print("Suit: ", suit)
	print("Rank: ", rank)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
