extends Node2D

func _ready():
	%DungeonGenerator.setup(5, 10, 1)
	var rooms_array: Array = %DungeonGenerator.generate_dungeon()
	print(rooms_array)

	var dungeon_params = {
		"map": rooms_array,
		"special_room": 0.4,
		"enemies_rooms_folder": Pathes.ROOMS_TEMPLATES_DIRECTORY + '/chapter1_forest/rooms/enemies',
		"special_rooms_folder": Pathes.ROOMS_TEMPLATES_DIRECTORY + '/chapter1_forest/rooms/special'
	}
