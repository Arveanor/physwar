extends Node

var warrior_sequence = [0, 0, 0, 0, 0, 0, 1]
var archer_sequence = [1, 1, 1, 0]
var flanker_sequence = [1, 1, 0]

var warrior_sequence_counter = 0
var archer_sequence_counter = 0
var flanker_sequence_counter = 0

func choose_next_warrior_upgrade():
	var choice = warrior_sequence[warrior_sequence_counter]
	warrior_sequence_counter = (warrior_sequence_counter + 1) % warrior_sequence.size()
	return choice

func choose_next_archer_upgrade():
	var choice = archer_sequence[archer_sequence_counter]
	archer_sequence_counter = (archer_sequence_counter + 1) % archer_sequence.size()
	return choice

func choose_next_flanker_upgrade():
	var choice = flanker_sequence[flanker_sequence_counter]
	flanker_sequence_counter = (flanker_sequence_counter + 1) % flanker_sequence.size()
	return choice
