extends Node

"""
Тут находятся все скрипты для перемещения монстров
"""

func random_step(my_coords: Vector2i,
				 obstacles: Array) -> Vector2i:
					
	# Создание массива ходов, которыми монстр может походить
	var available_offsets: Array = []
	# Перебор каждого хода и проверка на валидность
	for offset in [Vector2i.LEFT,
				   Vector2i.RIGHT,
				   Vector2i.UP,
				   Vector2i.DOWN]:
		var new_enemy_coords = my_coords + offset
		if Utils.coords_is_valid(
			new_enemy_coords,
			obstacles
		):
			# Если монстр может так походить, то добавляем
			available_offsets.append(offset)
	
	# Проверка, есть ли вообще доступные направления
	# Может быть так, что монстр заперт и доступных путей нет
	if available_offsets:
		# Если есть возможные пути, то
		# Выбор случайного направления
		var random_offset: Vector2i = available_offsets.pick_random()
		return random_offset
		
	# Иначе никуда не двигаемся, то есть возвращаем нулевой вектор
	return Vector2i.ZERO

func step_to_player(my_coords: Vector2i,
					target_coords: Vector2i,
					obstacles: Array) -> Vector2i:
	
	"""
	Метод для совершения одного шага в сторону игрока
	
	Параметры:
		my_coords (Vector2i):
			текущие координаты, из которых мы хотим добраться к target_coords
		target_coords (Vector2i): конечные координаты
		obstacles (Array[Vector2i]): список координат препятствий на поле
	
	Возвращаемое значение:
		direction (Vector2i):
			Направление, в котором на данном шагу надо походить монстру
			Может принимать значения:
				Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
	"""

	# TODO: весь следующий код написал ChatGPT,
	# возможно стоит переписать позже
	# Исходные комментарии ChatGPT сохранены

	# Размеры поля
	var max_x = SpritesInfo.ROOM_COUNT_TILES_X
	var max_y = SpritesInfo.ROOM_COUNT_TILES_Y

	# Проверка, если уже на цели
	if my_coords == target_coords:
		return Vector2.ZERO

	# Структуры для алгоритма A*
	var open_set = [my_coords]
	var came_from = {}
	var g_score = {my_coords: 0}
	var f_score = {my_coords: Utils.distance(my_coords, target_coords)}

	# Массив с направлениями (вверх, вниз, влево, вправо)
	var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]

	# A* алгоритм
	while open_set.size() > 0:
		# Находим узел с минимальным f_score
		var current = open_set[0]
		for node in open_set:
			if f_score.get(node, INF) < f_score.get(current, INF):
				current = node

		# Если цель достигнута, возвращаем первый шаг
		if current == target_coords:
			while current in came_from and came_from[current] != my_coords:
				current = came_from[current]
			return current - my_coords

		open_set.erase(current)

		for direction in directions:
			var neighbor = current + direction
			if Utils.coords_is_valid(neighbor, obstacles):
				var tentative_g_score = g_score.get(current, INF) + 1
				if tentative_g_score < g_score.get(neighbor, INF):
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g_score
					f_score[neighbor] = tentative_g_score + Utils.distance(neighbor, target_coords)
					if neighbor not in open_set:
						open_set.append(neighbor)

	# Если путь не найден, возвращаем Vector2.ZERO
	return Vector2i.ZERO
