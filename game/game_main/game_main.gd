extends Node2D

func _ready():
	%DungeonGenerator.setup(5, 10, 1)
	var rooms_array: Array = %DungeonGenerator.generate_dungeon()
	print(rooms_array)
