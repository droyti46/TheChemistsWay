class_name DungeonBuilder
extends Node

"""
Построение подземелья на основе массива с координатами комнат

Пример:
	Сцена:
		- Main (main.gd)
			- DungeonBuilder
	Код:
		main.gd:
			rooms = [[1, 1], [2, 2], [3, 3]]
			$DungeonBuilder.build_dungeon(rooms, [5, 5])
"""

@export var dungeon_node: Node

func build_dungeon(dungeon_map: Array, dungeon_size: Array):
	pass
