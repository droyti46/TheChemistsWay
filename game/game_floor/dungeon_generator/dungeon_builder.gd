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
			var dungeon_params = {
				"rooms": [[1, 2], [1, 2], [3, 4]],
				"special_room_chance": 0.3,
				"room_size": Vector2(100, 50),
				"enemies_rooms_folder": "res:/enemies_rooms_folder",
				"special_rooms_folder": "res:/special_rooms_folder"
			}
			$DungeonBuilder.build_dungeon(dungeon_params)
"""

# Нода, в которую будут добавлены комнаты
@export var dungeon_node: Node

const CHEST_ROOM_CHANCE = 0.35
# Максимальное количество комнат с сундуками
const MAX_CHEST_ROOMS = 3

# Может ли сейчас заспавниться сундук
var chest_room_can_spawn: bool = false
# Сколько уже комнат с сундуками заспавнилось
var current_chest_rooms_count = 0

# Переменная для хранения
# лоадов всех комнат (комнат с врагами и специальных)
var rooms_enemies_loads: Array [PackedScene] = []
var rooms_special_loads: Array [PackedScene] = []

func _fill_rooms_arrays(enemies_rooms_folder: String, special_rooms_folder: String) -> void:
	"""
	Функция для заполнения массивов лоадами комнат
	
	Параметры:
		enemies_rooms_folder (String): папка с комнатами с врагами
		special_rooms_folder (String): папка со специальными комнатами
	"""
	
	# По сути проходимся по индексам и пытаемся загрузить
	# соответствующую сцену. Если такая сцена существует, то
	# добавляем в массив лоад комнаты
	
	# TODO: эти два цикла while лучше обернуть в одну функцию
	var room_index: int = 1
	while true:
		var room_path: String = "%s/room_enemies%d.tscn" % [enemies_rooms_folder, room_index]
		if ResourceLoader.exists(room_path):
			var room_load: PackedScene = load(room_path)
			rooms_enemies_loads.append(room_load)
			room_index += 1
		else:
			break
	
	# Тут точно так же
	room_index = 1
	while true:
		var room_path: String = "%s/special_enemies%d.tscn" % [special_rooms_folder, room_index]
		if ResourceLoader.exists(room_path):
			var room_load: PackedScene = load(room_path)
			rooms_special_loads.append(room_load)
			room_index += 1
		else:
			break
			
func _add_doors(room_coords: Vector2i, room_scene: TileMap, rooms: Array):
	for offset in [Vector2i.LEFT,
				   Vector2i.RIGHT, 
				   Vector2i.UP,
				   Vector2i.DOWN]:
		# Если дверь добавлять надо
		if room_coords + offset in rooms:
			# То мы ее добавляем в этой стороне
			room_scene.create_door(offset)

func build_dungeon(dungeon_setting: Dictionary) -> Dictionary:
	
	'''
	Метод для построения подземелья (комнат, дверей, врагов и т.д.)
	
	Параметры:
		dungeon_setting (Dictionary):
			Словарь со всеми настройками подземелья
			Настройки:
				rooms (Array <Vector2>):
					Список координат комнат
				special_room_chance (float):
					Шанс на выпадения особой комнаты вместо комнаты
					со врагами
				room_size (Vector2):
					Размер комнаты по ширине и длине (в пикселях)
				enemies_room (PackedScene):
					Загруженная сцена со врагами
				special_rooms_folder (String):
					Папка со сценами особых комнат

	Возвращаемое значение:
		rooms_loads (Dictionary):
			словарь вида {координаты комнаты: сцена комнаты}
	'''
	
	# Словарь, в который будут помещаться координаты комнат
	# в качестве ключа и сцена комнаты в качестве значения
	var rooms_loads: Dictionary
	
	# Распаковка переменных из словаря настроек
	var rooms: Array = dungeon_setting["rooms"]
	var special_room_chance: float = dungeon_setting["special_room_chance"]
	var room_size: Vector2i = dungeon_setting["room_size"]
	var start_room: PackedScene = dungeon_setting["start_room"]
	var enemies_room: PackedScene = dungeon_setting["enemies_room"]
	var chest_room: PackedScene = dungeon_setting["chest_room"]

	#_fill_rooms_arrays(enemies_rooms_folder, special_rooms_folder)
	
	# Создание стартовой комнаты
	var start_room_coords = rooms[0]
	var start_room_scene = start_room.instantiate()
	start_room_scene.position = start_room_coords * room_size
	dungeon_node.add_child(start_room_scene)
	rooms_loads[start_room_coords] = start_room_scene
	_add_doors(start_room_coords, start_room_scene, rooms)
	
	var last_room_distance: int = 0
	var last_room_coords: Vector2i
	
	# Нахождение самой дальней комнаты, чтобы сделать её последней
	for room in rooms.slice(1):
		var room_distance: float = sqrt(
			(start_room_coords.x - room.x) ** 2 + (start_room_coords.y - room.y) ** 2
		)
		if room_distance > last_room_distance:
			last_room_distance = room_distance
			last_room_coords = room

	for room in rooms.slice(1):
		var room_load
		var random_num = randf()
		
		# Если комната слишком близко находится к последней
		# комнате, то в ней не сможет заспавниться сундук,
		# потому что могут быть случаи, когда до последней
		# комнаты ведет путь только из комнат с сундуками
		if (abs(room.x - last_room_coords.x) <= 1) and \
		   (abs(room.y - last_room_coords.y) <= 1):
			chest_room_can_spawn = false
		
		# Если у комнаты такие же координаты, как и у 
		# финальной комнаты, то это финальная комната
		if room == last_room_coords:
			room_load = start_room.instantiate()
			room_load.room_type = 4
		
		# Если выпала комната с сундуками
		# и текущее количество комнат с сундуками меньше, чем
		# максимальное и комната с сундуками может заспавниться
		elif (random_num <= CHEST_ROOM_CHANCE and \
			 current_chest_rooms_count < MAX_CHEST_ROOMS and \
			 chest_room_can_spawn):
			room_load = chest_room.instantiate()
			chest_room_can_spawn = false
			current_chest_rooms_count += 1
		else:
			room_load = enemies_room.instantiate()
			chest_room_can_spawn = true

		# Задаем комнате количество очков для спавна монстров
		if room_load.get_type() == "Enemies":
			room_load.spawn_points = randi_range(4, 6)
		
		room_load.position = room * room_size
		dungeon_node.add_child(room_load)
		
		# Прячем комнату
		room_load.hide_room()
		
		# Добавляем в словарь
		rooms_loads[room] = room_load
		
		# Пытаемся добавить дверь
		_add_doors(room, room_load, rooms)
		
	
	return rooms_loads
