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

func build_dungeon(dungeon_setting: Dictionary):
	
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
				enemies_rooms_folder (String):
					Папка со сценами комнат со врагами
				special_rooms_folder (String):
					Папка со сценами особых комнат
	'''
	
	# Распаковка переменных из словаря настроек
	var rooms: Array = dungeon_setting["rooms"]
	var special_room_chance: float = dungeon_setting["special_room_chance"]
	var room_size: Vector2 = dungeon_setting["room_size"]
	var enemies_rooms_folder: String = dungeon_setting["enemies_rooms_folder"]
	var special_rooms_folder: String = dungeon_setting["special_rooms_folder"]

	_fill_rooms_arrays(enemies_rooms_folder, special_rooms_folder)
	
	for room in rooms:
		# Выбор случайной комнаты из списка
		var random_room_load = rooms_enemies_loads[randi() % rooms_enemies_loads.size()].instantiate()
		random_room_load.position = room * room_size
		dungeon_node.add_child(random_room_load)
		
		# Пытаемся добавить дверь
		for offset in [Vector2.LEFT,
					   Vector2.RIGHT, 
					   Vector2.UP,
					   Vector2.DOWN]:
			# Если дверь добавлять надо
			if room + offset in rooms:
				# То мы ее добавляем в этой стороне
				random_room_load.create_door(offset)
