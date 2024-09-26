extends TileMap

const DOORS_INFO = {
	Vector2.LEFT: {
		"alternative_index": 1,
		"coords": Vector2i(0, 3),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_left.tscn")
	},
	Vector2.DOWN: {
		"alternative_index": 2, 
		"coords": Vector2i(5, 6),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_bottom.tscn")
	},
	Vector2.RIGHT: {
		"alternative_index": 3,
		"coords": Vector2i(10, 3),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_right.tscn")
	},
	Vector2.UP: {
		"alternative_index": 4,
		"coords": Vector2(5, 0),
		"scene": preload("res://game/game_main/assets/dungeon_generator/rooms_templates/chapter1_forest/environment/doors/forest_door_top.tscn")
	}
}

func create_door(direction: Vector2) -> void:
	
	'''
	Функция для добавления двери в комнату
	
	Параметры:
		direction (String):
			left, rigth, top или bottom (сторона, в которую
			необходимо добавить дверь)
		next_pos: позиция, в которую ведет дверь
	'''
	
	if direction not in DOORS_INFO.keys():
		print("direction может принимать лишь значения " + 
			  "left, right, top и bottom")
		return
	
	# Загрузка информации из DOORS_INFO
	var alternative_index: int = DOORS_INFO[direction]["alternative_index"]
	var door_coords: Vector2i = DOORS_INFO[direction]["coords"]
	var door_scene: StaticBody2D = DOORS_INFO[direction]["scene"].instantiate()
	
	# Установка положения двери
	door_scene.position = map_to_local(door_coords)
	# Добавление ноды двери
	add_child(door_scene)
	
	# Удаление стены (клетки, на которой
	# сейчас находится дверь)
	erase_cell(0, door_coords)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
