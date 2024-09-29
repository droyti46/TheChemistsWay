class_name DungeonGenerator
extends Node

# TODO: для генерации используется очень примитивный и
# неоптимизированный алгоритм с хабра, поэтому код надо будет
# полностью переписать

"""
Генерация подземелья с указанными размерами и количеством комнат.

Пример:
	Сцена:
		- Main (main.gd)
			- DungeonGenerator
	Код:
		main.gd:
			$DungeonGenerator.setup(5, 10, 1)
			var rooms_array: Array = $DungeonGenerator.generate_dungeon()
			print(rooms_array)

Код был основан на этом материале:
https://habr.com/ru/articles/747660/
Так что работающим над проектом советую ознакомиться с первоисточником
"""

# Координаты комнаты, если она создана неуспешно
const INVALID_ROOM: Vector2i = Vector2i(-1, -1)

# Словрь, в котором хранится информация о том, является ли клетка
# (i, j) комнатой или не является
var _dungeon_map: Dictionary
# Массив со всеми комнатами, который мы возвращаем при вызове функции
# generate_dungeon()
var _rooms: Array

var _dungeon_size: int
var _room_count: int
var _random_max: int

func setup(
	dungeon_size: int,
	room_count: int,
	random_max: int = 1):
	
	"""
	Функция для настройки генерации
	!!! Обязательная для вызова !!!
	
	Параметры:
		dungeon_size (int): размеры подземелья
		room_count (int): количество комнат
		random_max (int): чем больше число, тем выше вероятность, что
						  на данном месте появится комната
	"""
	
	_dungeon_size = dungeon_size
	_room_count = room_count
	_random_max = random_max
	
	_dungeon_map = {}
	_rooms = []

func generate_dungeon() -> Array:
	
	"""
	Функция для рекурсивной генерации подземелья
	
	Возвращаемое значение:
		rooms (Array):
			Массив со всеми координатами комнат
			Например: [(5, 5), (3, 3), (4, 4)]
	"""
	
	# Проверяем, настроен ли класс
	if (not _dungeon_size):
		print("Перед вызовом этого метода необходимо вызвать " +
			  "метод setup() с параметрами")
		return []
	
	# Сначала заполняем массив нулями
	for i in range(_dungeon_size):
		for j in range(_dungeon_size):
			_dungeon_map[Vector2i(i, j)] = 0
			
	# Если случайно вышло так, что должно быть больше комнат,
	# Чем всего на карте, то меняем это, во избежание бесконечной рекурсии
	if _dungeon_map.size() < _room_count:
		_room_count = _dungeon_map.size()
		
	# Точкой начала выбираем центр подземелья
	var central_room: Vector2i = Vector2i(round(_dungeon_size / 2),
										  round(_dungeon_size / 2))
	_dungeon_map[central_room] = 1
	_rooms.append(central_room)
	
	# Так как мы уже использовали одну комнату (центральную), то
	# уменьшаем счётчик
	_room_count -= 1
	# Так как есть вероятность, что ни одной комнаты не добавится,
	# то вызываем в цикле
	while _room_count > 0:
		# Вызываем функцию добавления комнаты
		_add_rooms(round(_dungeon_size / 2), round(_dungeon_size / 2))
		# Функция рекурсивная, поэтому закончится, 
		# когда отработают все вызванные функции
		# Увеличиваем счётчик, чтобы быстрее сгенерировать комнаты
		_random_max += 1
		
	return _rooms

func _add_one_room(i: int, j: int) -> Vector2i:
	
	"""
	Функция для создания одной комнаты
	
	Параметры:
		i, j (int): координаты ячейки массива _labirint_array
	
	Возвращаемое значение:
		room_coords (Vecor2):
			Координаты созданной комнаты или [-1, -1], если
			комната не была создана
	"""
	
	# Проверили нужны-ли ещё комнаты
	if (_room_count > 0):
		# Генерируем случайное число
		var room = randi_range(0, _random_max)
		# Если сгенерировали не 0
		if (room >= 1):
			# То делаем проверку:
			# Проверяем не выходят ли переменные, за границы
			# Проверяем нет ли уже комнаты по этим координатам
			if ((i >= 0) && (i < _dungeon_size) && (j >= 0) && (j < _dungeon_size) && (_dungeon_map[Vector2i(i, j)] != 1)):
				# И добавляем комнату в массив
				_dungeon_map[Vector2i(i, j)] = 1
				# Уменьшаем количество комнат, которые необходимо
				# сгенерировать
				_room_count -= 1
				# Возвращаем вектор, если создали комнату
				return Vector2i(i, j)
				
	# В случае неудачи возвращаем вектор [-1, -1]
	return INVALID_ROOM

func _add_rooms(i: int, j: int) -> void:
	
	# TODO: Добавить ограничение по глубине рекурсии, чтобы
	# подземелье не строилось только в одну сторону
	
	"""
	Рекурсивная функция для добавления комнат вокруг переданной комнаты
	
	Параметры:
		i, j (int): координаты комнаты, вокруг которой необходимо
					сгенерировать остальные комнаты
	"""
	
	var add: Vector2i
	# Перебираем смещения (комнаты вокруг)
	# Например, комната слева находится со смещением [-1, 0]
	# И так перебираем 4 направления (слева, справа, сверху, снизу)
	for offset in [Vector2i.LEFT,
				   Vector2i.RIGHT,
				   Vector2i.UP,
				   Vector2i.DOWN]:
		# Пытаемся добавить комнату
		add = _add_one_room(i + offset[0], j + offset[1])
		
		# Если комната добавилась успешно, то 
		if (add != INVALID_ROOM):
			_rooms.append(add)
			_add_rooms(int(add.x), int(add.y))
