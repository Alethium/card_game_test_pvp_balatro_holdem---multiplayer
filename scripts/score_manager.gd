class_name ScoreManager
extends Node

# Poker hand definitions based on your image
const HAND_DEFINITIONS = {
	"Flush Five": {"multiplier": 16, "chips": 160},
	"Flush House": {"multiplier": 14, "chips": 140},
	"Five of a Kind": {"multiplier": 12, "chips": 120},
	"Royal Flush": {"multiplier": 6, "chips": 100},
	"Straight Flush": {"multiplier": 8, "chips": 100},
	"Four of a Kind": {"multiplier": 7, "chips": 60},
	"Full House": {"multiplier": 4, "chips": 40},
	"Flush": {"multiplier": 4, "chips": 35},
	"Straight": {"multiplier": 4, "chips": 30},
	"Three of a Kind": {"multiplier": 3, "chips": 30},
	"Two Pair": {"multiplier": 2, "chips": 20},
	"Pair": {"multiplier": 2, "chips": 10},
	"High Card": {"multiplier": 1, "chips": 5}
}







class PokerHand:
	var hand_type: String
	var base_multiplier: int
	var chips: int
	var cards: Array
	
	func _init(type: String, multiplier: int, chips_value: int, hand_cards: Array):
		hand_type = type
		base_multiplier = multiplier
		chips = chips_value
		cards = hand_cards
	
	func get_score() -> int:
		var card_value : int = 0
		for card in cards:
			card_value += card.score
		return (card_value + chips) * base_multiplier

# Function to determine the best hand from selected cards
func determine_best_hand(cards: Array) -> PokerHand:
	# Sort cards by rank for easier processing
	cards.sort_custom(func(a, b): return a.rank < b.rank)
	
	var possible_hands = []
	
	# Check for all possible hand types
	if cards.size() >= 5:
		var flush_five = check_flush_five(cards)
		if flush_five:
			possible_hands.append(flush_five)
		
		var flush_house = check_flush_house(cards)
		if flush_house:
			possible_hands.append(flush_house)
		
		var five_of_a_kind = check_five_of_a_kind(cards)
		if five_of_a_kind:
			possible_hands.append(five_of_a_kind)
		
		var royal_flush = check_royal_flush(cards)
		if royal_flush:
			possible_hands.append(royal_flush)
		
		var straight_flush = check_straight_flush(cards)
		if straight_flush:
			possible_hands.append(straight_flush)
		
		var four_of_a_kind = check_four_of_a_kind(cards)
		if four_of_a_kind:
			possible_hands.append(four_of_a_kind)
		
		var full_house = check_full_house(cards)
		if full_house:
			possible_hands.append(full_house)
		
		var flush = check_flush(cards)
		if flush:
			possible_hands.append(flush)
		
		var straight = check_straight(cards)
		if straight:
			possible_hands.append(straight)
	
	if cards.size() >= 3:
		var three_of_a_kind = check_three_of_a_kind(cards)
		if three_of_a_kind:
			possible_hands.append(three_of_a_kind)
	
	if cards.size() >= 4:
		var two_pair = check_two_pair(cards)
		if two_pair:
			possible_hands.append(two_pair)
	
	if cards.size() >= 2:
		var pair = check_pair(cards)
		if pair:
			possible_hands.append(pair)
	
	# Always have at least a high card
	var high_card = check_high_card(cards)
	possible_hands.append(high_card)
	
	# Sort hands by score (highest first)
	possible_hands.sort_custom(func(a, b): return a.get_score() > b.get_score())
	
	return possible_hands[0] if possible_hands else high_card

# Hand checking functions
func check_flush_five(cards: Array) -> PokerHand:
	if cards.size() < 5:
		return null
	
	# All cards must be the same suit
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return null
	
	# All cards must be the same rank
	var first_rank = cards[0].rank
	for card in cards:
		if card.rank != first_rank:
			return null
	
	return PokerHand.new(
		"Flush Five", 
		HAND_DEFINITIONS["Flush Five"]["multiplier"],
		HAND_DEFINITIONS["Flush Five"]["chips"],
		cards
	)

func check_flush_house(cards: Array) -> PokerHand:
	if cards.size() < 5:
		return null
	
	# All cards must be the same suit
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return null
	
	# Must be a full house (three of one rank, two of another)
	var rank_counts = {}
	for card in cards:
		if card.rank in rank_counts:
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1
	
	var has_three = false
	var has_two = false
	for count in rank_counts.values():
		if count == 3:
			has_three = true
		elif count == 2:
			has_two = true
	
	if has_three and has_two:
		return PokerHand.new(
			"Flush House", 
			HAND_DEFINITIONS["Flush House"]["multiplier"],
			HAND_DEFINITIONS["Flush House"]["chips"],
			cards
		)
	
	return null

func check_five_of_a_kind(cards: Array) -> PokerHand:
	if cards.size() < 5:
		return null
	
	# All cards must be the same rank
	var first_rank = cards[0].rank
	for card in cards:
		if card.rank != first_rank:
			return null
	
	return PokerHand.new(
		"Five of a Kind", 
		HAND_DEFINITIONS["Five of a Kind"]["multiplier"],
		HAND_DEFINITIONS["Five of a Kind"]["chips"],
		cards
	)

func check_royal_flush(cards: Array) -> PokerHand:
	if cards.size() < 5:
		return null
	
	# All cards must be the same suit
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return null
	
	# Must contain 10, J, Q, K, A (Ranks 9, 10, 11, 12, 0)
	# Note: Your RANK enum has Ace=0, Ten=9, Page=10, Knight=11, Queen=12, King=13
	var required_ranks = [9, 10, 11, 12, 0]  # Ten, Page, Knight, Queen, King, Ace
	var found_ranks = []
	for card in cards:
		if card.rank in required_ranks and not card.rank in found_ranks:
			found_ranks.append(card.rank)
	
	if found_ranks.size() == 5:
		return PokerHand.new(
			"Royal Flush", 
			HAND_DEFINITIONS["Royal Flush"]["multiplier"],
			HAND_DEFINITIONS["Royal Flush"]["chips"],
			cards
		)
	
	return null

func check_straight_flush(cards: Array) -> PokerHand:
	if cards.size() < 5:
		return null
	
	# All cards must be the same suit
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return null
	
	# Check for straight
	var straight = check_straight(cards)
	if straight:
		return PokerHand.new(
			"Straight Flush", 
			HAND_DEFINITIONS["Straight Flush"]["multiplier"],
			HAND_DEFINITIONS["Straight Flush"]["chips"],
			cards
		)
	
	return null

func check_four_of_a_kind(cards: Array) -> PokerHand:
	var rank_counts = {}
	for card in cards:
		if card.rank in rank_counts:
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1
	
	for rank in rank_counts:
		if rank_counts[rank] >= 4:
			return PokerHand.new(
				"Four of a Kind", 
				HAND_DEFINITIONS["Four of a Kind"]["multiplier"],
				HAND_DEFINITIONS["Four of a Kind"]["chips"],
				cards
			)
	
	return null

func check_full_house(cards: Array) -> PokerHand:
	var rank_counts = {}
	for card in cards:
		if card.rank in rank_counts:
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1
	
	var has_three = false
	var has_two = false
	for count in rank_counts.values():
		if count >= 3:
			has_three = true
		elif count >= 2:
			has_two = true
	
	if has_three and has_two:
		return PokerHand.new(
			"Full House", 
			HAND_DEFINITIONS["Full House"]["multiplier"],
			HAND_DEFINITIONS["Full House"]["chips"],
			cards
		)
	
	return null

func check_flush(cards: Array) -> PokerHand:
	if cards.size() < 5:
		return null
	
	var first_suit = cards[0].suit
	for card in cards:
		if card.suit != first_suit:
			return null
	
	return PokerHand.new(
		"Flush", 
		HAND_DEFINITIONS["Flush"]["multiplier"],
		HAND_DEFINITIONS["Flush"]["chips"],
		cards
	)

func check_straight(cards: Array) -> PokerHand:
	if cards.size() < 5:
		return null
	
	# Get unique ranks
	var unique_ranks = []
	for card in cards:
		if not card.rank in unique_ranks:
			unique_ranks.append(card.rank)
	
	unique_ranks.sort()
	
	# Check for Ace-low straight (A-2-3-4-5) - Ace=0, Two=1, Three=2, Four=3, Five=4
	if unique_ranks.has(0) and unique_ranks.has(1) and unique_ranks.has(2) and unique_ranks.has(3) and unique_ranks.has(4):
		return PokerHand.new(
			"Straight", 
			HAND_DEFINITIONS["Straight"]["multiplier"],
			HAND_DEFINITIONS["Straight"]["chips"],
			cards
		)
	
	# Check for normal straights
	for i in range(0, unique_ranks.size() - 4):
		if unique_ranks[i + 4] - unique_ranks[i] == 4:
			return PokerHand.new(
				"Straight", 
				HAND_DEFINITIONS["Straight"]["multiplier"],
				HAND_DEFINITIONS["Straight"]["chips"],
				cards
			)
	
	return null

func check_three_of_a_kind(cards: Array) -> PokerHand:
	var rank_counts = {}
	for card in cards:
		if card.rank in rank_counts:
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1
	
	for rank in rank_counts:
		if rank_counts[rank] >= 3:
			return PokerHand.new(
				"Three of a Kind", 
				HAND_DEFINITIONS["Three of a Kind"]["multiplier"],
				HAND_DEFINITIONS["Three of a Kind"]["chips"],
				cards
			)
	
	return null

func check_two_pair(cards: Array) -> PokerHand:
	var rank_counts = {}
	for card in cards:
		if card.rank in rank_counts:
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1
	
	var pair_count = 0
	for count in rank_counts.values():
		if count >= 2:
			pair_count += 1
	
	if pair_count >= 2:
		return PokerHand.new(
			"Two Pair", 
			HAND_DEFINITIONS["Two Pair"]["multiplier"],
			HAND_DEFINITIONS["Two Pair"]["chips"],
			cards
		)
	
	return null

func check_pair(cards: Array) -> PokerHand:
	var rank_counts = {}
	for card in cards:
		if card.rank in rank_counts:
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1
	
	for rank in rank_counts:
		if rank_counts[rank] >= 2:
			return PokerHand.new(
				"Pair", 
				HAND_DEFINITIONS["Pair"]["multiplier"],
				HAND_DEFINITIONS["Pair"]["chips"],
				cards
			)
	
	return null

func check_high_card(cards: Array) -> PokerHand:
	if cards.size() == 0:
		return null
	
	# Find the highest card
	var highest_card = cards[0]
	for card in cards:
		# Ace is high (rank 0 is highest)
		var card_rank = 14 if card.rank == 0 else card.rank + 1
		var highest_rank = 14 if highest_card.rank == 0 else highest_card.rank + 1
		
		if card_rank > highest_rank:
			highest_card = card
		# If ranks are equal, compare scores
		elif card_rank == highest_rank and card.score > highest_card.score:
			highest_card = card
	
	return PokerHand.new(
		"High Card", 
		HAND_DEFINITIONS["High Card"]["multiplier"],
		HAND_DEFINITIONS["High Card"]["chips"],
		[highest_card]
	)

# Function to calculate total score for a hand
func calculate_hand_score(cards: Array) -> int:
	var best_hand = determine_best_hand(cards)
	return best_hand.get_score()

# Function to get hand information
func get_hand_info(cards: Array) -> Dictionary:
	var best_hand = determine_best_hand(cards)
	for card in cards:
		card.selected = false
	
	return {
		"hand_type": best_hand.hand_type,
		"multiplier": best_hand.base_multiplier,
		"chips": best_hand.chips,
		"score": best_hand.get_score(),
		"cards": best_hand.cards
	}

# Example usage
func _ready():
	pass
	## Create some test cards using your Minor_Arcana class
	#var test_cards = [
		## These would be instances of your Minor_Arcana class
		## For testing, you'd need to create actual card instances
	#]
	#
	## Determine the best hand
	#var hand_info = get_hand_info(test_cards)
	#print("Best hand: ", hand_info["hand_type"])
	#print("Score: ", hand_info["score"])
	#print("Multiplier: ", hand_info["multiplier"])
	#print("Chips: ", hand_info["chips"])
