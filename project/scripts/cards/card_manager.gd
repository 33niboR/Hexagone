extends Node
class_name CardManager

var draw_pile: Array[CardData] = []

func draw_hand(hand_size: int = 3) -> Array[CardData]:
	var hand: Array[CardData] = []
	for i in hand_size:
		if draw_pile.is_empty():
			break
		hand.append(draw_pile.pick_random())
	return hand
