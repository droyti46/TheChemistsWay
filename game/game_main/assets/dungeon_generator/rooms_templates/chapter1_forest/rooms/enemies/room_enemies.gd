extends "res://game/game_main/assets/dungeon_generator/rooms_templates/room_base.gd"

# Минимальное и максимальное количество препятствий
# в комнате соответственно
const MIN_COUNT_OBSTACLES: int = 1
const MAX_COUNT_OBSTACLES: int = 7
# Количество препятствий
const OBSTACLES_COUNT = 2
# ID атласа в TileMap.tile_set, на котором находятся все
# препятствия
const OBSTACLES_ATLAS_ID = 6

# Минимальное и максимальное количество монстров
# в комнате соответственно
const MIN_COUNT_ENEMIES: int = 1
const MAX_COUNT_ENEMIES: int = 1

var enemy = preload("res://characters/enemies/Fish/fish.tscn")

func _processing_tiles_for_create(tiles: Array) -> Array:
	var new_tiles: Array = []
	
	for tile in tiles:
		if (tile.x > 1 and tile.x < (SpritesInfo.ROOM_COUNT_TILES_X - 2)) and \
		   (tile.y > 1 and tile.y < (SpritesInfo.ROOM_COUNT_TILES_Y - 2)):
			new_tiles.append(tile)
	
	return new_tiles
	
func _create_obstacles(all_coords: Array) -> void:
	
	"""
	Создает в комнате случайные препятствия
	
	Параметры:
		all_coords (Array):
			координаты всех клеток, на которых можно ставить
			препятствия
			
	Изменяет переданный список, удаляя из него координаты,
	на которых появились преграды
	"""
	
	# Случайное количество препятствий в комнате
	var count_obstacles: int = randi_range(
		MIN_COUNT_OBSTACLES,
		MAX_COUNT_OBSTACLES
	)
	
	# Создание препятсвий
	for _i in range(count_obstacles):
		# Случайный индекс позиции из массива с координатами
		var random_obstacle_pos_index: int = randi() % all_coords.size()
		# Выбор случайной позиции для препятвия
		var random_obstacle_position: Vector2 = all_coords[random_obstacle_pos_index]
		# Создание препятсвия
		set_cell(SpritesInfo.OBSTACLES_TILEMAP_LAYER,
				 random_obstacle_position,
				 OBSTACLES_ATLAS_ID,
				 Vector2i(randi_range(0, OBSTACLES_COUNT - 1), 0))
		# Удаление этих координат из списка для создания
		# (т.к. нельзя сгенерировать два препятвия на одном месте)
		all_coords.remove_at(random_obstacle_pos_index)
		
func _create_enemies(all_coords: Array) -> void:
	
	"""
	Создает в комнате случайных монстров
	
	Параметры:
		all_coords (Array):
			координаты всех клеток, на которых можно ставить
			монстров
			
	Изменяет переданный список, удаляя из него координаты,
	на которых появились монстры
	"""
	
	# Случайное количество монстров в комнате
	var count_enemies: int = randi_range(
		MIN_COUNT_ENEMIES,
		MAX_COUNT_ENEMIES
	)
	
	# Создание монстров
	for _i in range(count_enemies):
		# Случайный индекс позиции из массива с координатами
		var random_enemy_pos_index: int = randi() % all_coords.size()
		# Выбор случайной позиции для препятвия
		var random_enemy_position: Vector2 = all_coords[random_enemy_pos_index]
		# Создание монстра
		var enemy_scene = enemy.instantiate()
		$Enemies.add_child(enemy_scene)
		enemy_scene.position = map_to_local(random_enemy_position)
		enemy_scene.set_coords(random_enemy_position)
		
		# Удаление этих координат из списка для создания
		# (т.к. нельзя сгенерировать два монстра на одном месте)
		all_coords.remove_at(random_enemy_pos_index)

func _ready():
	# Получение всех клеток в комнате
	var tiles_for_create: Array = get_used_cells(1)
	# Обработка клеток (удаляет соседние)
	tiles_for_create = _processing_tiles_for_create(tiles_for_create)
	# Создание препятствий
	_create_obstacles(tiles_for_create)
	_create_enemies(tiles_for_create)

func make_moves(player_coords: Vector2i) -> void:
	for enemy in $Enemies.get_children():
		var other_enemies_coords = []
		for other_enemy in $Enemies.get_children():
			if other_enemy == enemy:
				continue
			other_enemies_coords.append(other_enemy.get_coords())
		
		var enemy_move: Vector2 = enemy.make_move(
			self,
			player_coords,
			other_enemies_coords
		)
		enemy.step_animate(enemy_move)
		await enemy.step_finished
