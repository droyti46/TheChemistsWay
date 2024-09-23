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
			$DungeonBuilder.build_dungeon(rooms)
"""

@export var dungeon_node: Node

func build_dungeon(dungeon_map: Array):
	
	'''
	Метод для построения подземелья (комнат, проходов, дверей, врагов и т.д.)
	
	Параметры:
		dungeon_map (Array): Массив с координатами, в которых должны быть комнаты
	'''
	
	pass
