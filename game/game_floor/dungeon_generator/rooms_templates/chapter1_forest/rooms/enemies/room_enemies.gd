extends "res://game/game_floor/dungeon_generator/rooms_templates/room_base.gd"

# Все монстры сделали ходы
signal enemies_finished_moves
# Комната пройдена (все враги убиты)
signal room_is_passed

# Минимальное и максимальное количество препятствий
# в комнате соответственно
const MIN_COUNT_OBSTACLES: int = 4
const MAX_COUNT_OBSTACLES: int = 7
# Количество видов препятствий
# (нужно, чтобы выбирать случайное среди имеющихся)
const OBSTACLES_COUNT = 2
# ID атласа в TileMap.tile_set, на котором находятся все
# препятствия
const OBSTACLES_ATLAS_ID = 6
# ID атласа в TileMap.tile_set, на котором находится индикатор
# атакованного тайла
const ATTACKED_TILE_ATLAS_ID = 2

# Максимальное количество монстров в комнате
const MAX_COUNT_ENEMIES: int = 7

const PATH_TO_ENEMMIES: String = "res://characters/enemies/"
const ENEMIES_NAMES: Array[String] = ["fish", "bomb", "circular_mushroom", "turtle"]
#const ENEMIES_NAMES: Array[String] = ["bomb"]

var enemies_loads: Array[PackedScene] = []

var enemies_list: Array = []
var count_enemies_completed_step = 0

# Количество очков для спавна монстров
var spawn_points: float = 0.0
# Список для хранения координат всех препятствий
var obstacles_coords: Array[Vector2i] = []

#var attacked_tile = preload("res://game/game_floor/dungeon_generator/rooms_templates/attacked_tile.tscn")
# Список индикаторов атаки
var attacked_tiles: Array = []

var chest = preload("res://game/game_floor/dungeon_generator/rooms_templates/chest/chest.tscn")

func _process(delta):
	# Выделение тайлов
	var mouse_position = get_local_mouse_position()
	var hovering_tile_coords = local_to_map(mouse_position)
	$HoveringTile.position = hovering_tile_coords * SpritesInfo.TILE_SIZE

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
		# Выбор случайной позиции для препятвия
		var random_obstacle_position: Vector2i = all_coords.pick_random()
		# Добавление координат в массив с координатами с препятствиями
		obstacles_coords.append(random_obstacle_position)
		# Создание препятсвия
		set_cell(SpritesInfo.OBSTACLES_TILEMAP_LAYER,
				 random_obstacle_position,
				 OBSTACLES_ATLAS_ID,
				 Vector2i(randi_range(0, OBSTACLES_COUNT - 1), 0))
		# Удаление этих координат из списка для создания
		# (т.к. нельзя сгенерировать два препятвия на одном месте)
		all_coords.erase(random_obstacle_position)

func _on_enemy_died(enemy: Node2D) -> void:
	
	"""Срабатывает, когда враг умер"""
	
	# Убираем врага из массива
	enemies_list.erase(enemy)
	# Вызов метода, который удаляет все созданные 
	# монстром объекты, если он такие может создать
	if enemy.has_method("delete_created_objects"):
		enemy.delete_created_objects()
	# Удаление всех индикаторов атаки, принадлежащих этому монстру
	for indicator in enemy.indicators:
		indicator.delete()

	# Если игрок убил всех врагов (т.е. в списке с врагами
	# их не осталось)
	if not enemies_list:
		# Меняем тип на третий (пройденная комната)
		room_type = 3
		# Вызываем сигнал
		emit_signal("room_is_passed")

func _on_enemy_finished_step() -> void:
	
	"""
	Функция срабатывает, когда враг закончил ход
	"""
	
	# Увеличиваем число походивших монстров
	count_enemies_completed_step += 1
	# Если все монстры походили
	if count_enemies_completed_step >= len(enemies_list):
		# Обнуляем переменную
		count_enemies_completed_step = 0
		
		# Передаем новую информацию о позиции каждого монстра игроку
		var enemies_coords = []
		for enemy in $Enemies.get_children():
			enemies_coords.append(enemy.get_coords())
		
		# Вызываем сигнал, ведь все монстры походили
		emit_signal("enemies_finished_moves")

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
	
	# Создание монстров
	while spawn_points:
		# Если уже заспавнилось максимальное количество монстров,
		# то прекращение спавна
		if len(enemies_list) >= MAX_COUNT_ENEMIES:
			break
		
		# Выбор случайной позиции для препятвия
		var random_enemy_position: Vector2i = all_coords.pick_random()
		# Создание монстра
		var enemies_available = enemies_loads.filter(
			func (x): return x.instantiate().cost <= spawn_points
		)
		
		# Если нельзя создать никакого монстра, то у игры слишком
		# мало очков
		if not enemies_available:
			break
			
		var enemy_scene = enemies_available.pick_random().instantiate()
		spawn_points -= enemy_scene.cost
		
		$Enemies.add_child(enemy_scene)
		enemy_scene.position = map_to_local(random_enemy_position)
		enemy_scene.set_coords(random_enemy_position)
		enemy_scene.connect("died", _on_enemy_died)
		enemy_scene.connect("enemy_is_ready_to_attacked", Game.game.ui._on_enemy_is_ready_to_attacked)
		enemy_scene.connect("enemy_is_ready_to_attacked", _on_enemy_is_ready_to_attacked)
		enemy_scene.connect("enemy_mouse_leaved", Game.game.ui._on_enemy_mouse_leaved)
		enemy_scene.connect("enemy_mouse_leaved", _on_enemy_mouse_leaved)
		#enemy_scene.connect("step_finished", _on_enemy_finished_step)
		
		enemies_list.append(enemy_scene)
		
		# Удаление этих координат из списка для создания
		# (т.к. нельзя сгенерировать два монстра на одном месте)
		all_coords.erase(random_enemy_position)

func add_enemy(enemy_scene) -> void:
	pass

func _ready() -> void:
	# Наполнение массива с лоадами монстров
	for enemy_name in ENEMIES_NAMES:
		var enemy_load = load(
			PATH_TO_ENEMMIES + enemy_name + "/" + enemy_name \
							 + ".tscn"
		)
		enemies_loads.append(enemy_load)
	
	# Получение всех клеток в комнате
	var tiles_for_create: Array = get_used_cells(1)
	# Обработка клеток (удаляет соседние)
	tiles_for_create = _processing_tiles_for_create(tiles_for_create)
	# Создание препятствий и врагов
	_create_obstacles(tiles_for_create)
	_create_enemies(tiles_for_create)

func _on_enemy_is_ready_to_attacked(enemy) -> void:
	$HoveringTile.modulate = "#b6ee75"

func _on_enemy_mouse_leaved() -> void:
	$HoveringTile.modulate = "#ffffff64"

func _tile_next_to_player(coords: Vector2i) -> bool:
	"""Функция для фильтрации ближних к игроку клеток"""
	var dist = abs(coords - player.player_coords)
	return dist.x <= 3 and dist.y <= 3 and dist != Vector2i.ZERO

func _tile_is_not_obstacle(coords: Vector2i) -> bool:
	"""Функция для фильтрации клеток, не являющихся препятствием"""
	var obstacles = get_used_cells(SpritesInfo.OBSTACLES_TILEMAP_LAYER)
	return coords not in obstacles

func fight_started() -> void:
	$HoveringTile.show()

func fight_finished() -> void:
	$HoveringTile.hide()

func spawn_chest() -> void:
	
	"""
	Функция для спавна сундука в комнате
	(например, после победы)
	"""
	
	# Получение всех клеток
	var coords_for_spawn = get_used_cells(SpritesInfo.GRASS_TILEMAP_LAYER)
	
	# Фильтрация клеток (нужно оставить только те, которые близко
	# расположены к игроку и на которых нет препятствия
	coords_for_spawn = coords_for_spawn.filter(_tile_next_to_player)
	coords_for_spawn = coords_for_spawn.filter(_tile_is_not_obstacle)
	coords_for_spawn = _processing_tiles_for_create(coords_for_spawn)
	
	# Выбираем случайные координаты для спавна
	var chest_coords = coords_for_spawn.pick_random()
	var chest_scene = chest.instantiate()
	chest_scene.position = map_to_local(chest_coords)
	
	# Спавним сундук
	chest_scene.prepare_anim()
	add_child(chest_scene)
	chest_scene.show_anim()

func make_moves(player_coords: Vector2i) -> void:
	# Проходимся по каждому врагу и делаем для него ход
	for enemy in $Enemies.get_children():
		# Если монстр умер, он не сможет походить
		if enemy.is_died(): continue
		# Собираем информацию о координатах других монстров,
		# чтобы передать их врагу, которых ходит сейчас
		var other_enemies_coords = []
		for other_enemy in $Enemies.get_children():
			if other_enemy == enemy:
				continue
			other_enemies_coords.append(other_enemy.get_coords())
		# Совершение хода
		enemy.make_move(
			self,
			player_coords,
			other_enemies_coords
		)
		# await get_tree().create_timer(0.05).timeout
	
	## Добавление инфомации о координатах игроку
	#var enemies_coords = []
	#for enemy in $Enemies.get_children():
		#enemies_coords.append(enemy.get_coords())
	#player.set_coords("enemies", enemies_coords)

func get_obstacles_coords() -> Array[Vector2i]:
	"""Возвращает список """
	return obstacles_coords

#func add_attacked_tile(coords: Vector2i, enemy):
	#var attacked_tile_scene = attacked_tile.instantiate()
	#attacked_tile_scene.position = map_to_local(coords)
	#$AttackedTiles.add_child(attacked_tile_scene)
	#attacked_tile_scene.coords = coords
	#attacked_tile_scene.enemy = enemy
	#attacked_tiles.append(attacked_tile_scene)
#
#func move_attacked_tile(old_coords: Vector2i, direction: Vector2i, enemy):
	#var new_coords = old_coords + direction
	#var new_position = map_to_local(new_coords)
	#var tile = find_attacked_tile(old_coords, enemy)
	#if tile:
		#tile.coords = new_coords
		#tile.move_to(new_position)
#
#func delete_attacked_tile(coords: Vector2i, enemy):
	#var tile = find_attacked_tile(coords, enemy)
	#if tile:
		#attacked_tiles.erase(tile)
		#tile.delete()
#
#func find_attacked_tile(coords: Vector2i, enemy):
	#for tile in attacked_tiles:
		#if is_instance_valid(tile) and "enemy" in tile:
			#if (tile.enemy == enemy) and (tile.coords == coords):
				#return tile
	#return null

func get_enemies_coords() -> Array[Vector2i]:
	"""Возвращает все координаты врагов"""
	var enemies_coords: Array[Vector2i] = []
	for enemy in enemies_list:
		enemies_coords.append(enemy.get_coords())
	return enemies_coords
