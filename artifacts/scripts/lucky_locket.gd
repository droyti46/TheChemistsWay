extends Node

# Повышает количество ходов на 1

func activate(game: Node2D) -> void:
	game.player.max_moves += 1
