extends Node

func coords_is_valid(coords: Vector2i,
						player_coords: Vector2i,
						obstacles_coords: Array,
						other_enemies_coords: Array):

	return coords not in obstacles_coords and \
		   coords not in other_enemies_coords and \
		   coords != player_coords and \
		   coords.x != -1 and \
		   coords.x != SpritesInfo.ROOM_COUNT_TILES_X and \
		   coords.y != -1 and \
		   coords.y != SpritesInfo.ROOM_COUNT_TILES_Y

func merge_arrays(arrays: Array [Array], no_repetitions: bool = false) -> Array:
	
	"""
	Функция для объединения двух массивов
	
	Параметры:
		arrays (Array [Array]):
			массив всех массивов, которые нужно объединить
		no_repetitions (bool), optional:
			нужно ли исключать повторения в новом массиве
	
	Возвращаемое значение:
		new_array (Array):
			массив, в котором содержатся элементы из всех массивов
	"""
	
	# Новый массив
	var new_array: Array = []
	
	# Проход по каждому массиву
	for array in arrays:
		# Проход по каждому элементу и добавление их в новый массив
		for elem in array:
			# Проверка на то, нужно ли исключать повторения
			if (no_repetitions and elem not in new_array) or (not no_repetitions):
				new_array.append(elem)
	
	# Возвращение нового массива
	return new_array
