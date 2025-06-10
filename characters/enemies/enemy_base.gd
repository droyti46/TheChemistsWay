extends Node2D

"""
Класс базового монстра
Также служит и родителем для пуль и атак
Подробности в docs/enemies.md
"""

@onready var health_bar = $EnemyInfo/InfoContainer/HealthBar
@onready var animated_sprite = $AnimatedSprite

# Можно ли атаковать сущность (например, пули, которые тоже
# наследуют этот класс, нельзя атаковать)
@export var attacked = true
# Количество урона
@export var damage_count: int
# Имя монстра
@export var enemy_name: String
# Здоровье монстра
@export var health: int
# Стоимость врага для спавна в комнате
@export var cost: float = 1

signal enemy_is_ready_to_attacked
signal enemy_mouse_leaved
signal step_finished
signal died

const CHEM_CLASSES = ["Металл", "Неметалл", "Оксид", "Основание",
					  "Соль", "Кислота"]

var enemy_coords: Vector2i
var weakness_class: String

var last_direction: String = "front"

# Урон игрока, если он сейчас навёл веществом на врага
var player_damage: int = 0
# Наведена ли мышка на врага
var is_hovering: bool = false

# Индикаторы атаки
var indicators: Array[Indicator] = []

func set_step_animation(dir: Vector2i, only_flip: bool = false) -> void:
	
	"""
	Функция для настройки спрайта персонажа,
	в зависимости от того, в какую сторону он идет
	
	Параметры:
		dir (String):
			В зависимости от направления может принимать
			4 значения:
			player_left, player_right, player_up, player_down
	"""
	
	match dir:
		Vector2i.LEFT:
			# Поворот спрайта персонажа
			animated_sprite.flip_h = true
			if only_flip: return
			# Проигрывание анимации
			animated_sprite.play("step_side")
			# Последнее направление
			last_direction = "side"
		Vector2i.RIGHT:
			# Поворот спрайта персонажа
			animated_sprite.flip_h = false
			if only_flip: return
			# Проигрывание анимации
			animated_sprite.play("step_side")
			# Последнее направление
			last_direction = "side"
		Vector2i.UP:
			if only_flip: return
			# Проигрывание анимации
			animated_sprite.play("step_behind")
			# Последнее направление
			last_direction = "behind"
		Vector2i.DOWN:
			if only_flip: return
			# Проигрывание анимации
			animated_sprite.play("step_front")
			# Последнее направление
			last_direction = "front"

func set_coords(new_coords: Vector2i) -> void:
	"""Функция ставит координаты монстра"""
	enemy_coords = new_coords
	
func get_coords() -> Vector2i:
	"""Метод для получения координат врага"""
	return enemy_coords

func step_animate(direction: Vector2i, idle_anim: bool = false, animation_time=0.3) -> void:
	
	"""
	Метод для перемещения монстра
	
	Параметры:
		direction (Vector2): направление перемещения
			Может принимать одно из четырех значений:
			Vector2.LEFT, Vector2.RIGHT, Vector2.UP или
			Vector2.DOWN
			
			Если случай особенный и требуется, например, чтобы
			монстр переместился на 2 клетки вправо, то можно
			передать Vector2(2, 0)
	"""

	# Перемещение
	var tween: Tween = create_tween()
	tween.tween_property(self, "position",
		Utils.v2_and_v2i_to_v2(position, direction * SpritesInfo.TILE_SIZE),
		animation_time
	)
		
	# Ждем пока монстр переместится
	await tween.finished
	# Вызов сигнала, ведь враг переместился
	emit_signal("step_finished")
	# Проигрывание анимации спокойствия
	if idle_anim:
		animated_sprite.play("idle_%s" % last_direction)

func delete_indicators() -> void:
	"""Удаляет все индикаторы атаки"""
	# Поскольу индикатор удаляет сам себя из списка,
	# используется такой костыль
	for _i in len(indicators):
		indicators[0].delete()

func _show_damage() -> void:
	"""
	Показывает урон, который нанесется монстру,
	если игрок навел на него вещество
	"""

	# Высчитываем расстояние до игрока
	var disctance_to_player: Vector2i = \
		abs(Game.game.player_coords - enemy_coords)
	
	# Наведено ли на монстра вещество
	if Game.game.ui.moving_substance and is_hovering:
		if disctance_to_player.x <= 1 and \
		   disctance_to_player.y <= 1:
			if not player_damage:
				emit_signal("enemy_is_ready_to_attacked", self)
				$ReadyToBeAttackedAnimation.play("ready")
				Input.set_custom_mouse_cursor(SpritesInfo.aim_cursor, Input.CURSOR_POINTING_HAND)
				
				player_damage = Game.game.ui.moving_substance.damage
				# Если слабость монстра совпадает с классом вещества
				if weakness_class == Game.game.ui.moving_substance.substance.get_ru_class():
					player_damage += player_damage * 1
				
				Game.game.player.ready_to_attack()
				$DamageLabel.set_text(
					"-%d" % player_damage
				)
				$ShowDamageLabel.play("show")
		elif player_damage:
			_cancel_attack()
			emit_signal("enemy_mouse_leaved")
			Input.set_custom_mouse_cursor(SpritesInfo.hand_cursor, Input.CURSOR_POINTING_HAND)

func _on_button_mouse_entered():
	if is_died():
		return
	
	is_hovering = true
	
	# Проверка где должна находиться информаци
	# (сверху или снизу)
	if enemy_coords.y > SpritesInfo.ROOM_COUNT_TILES_Y / 2:
		$EnemyInfo.position.y = -185
	else:
		$EnemyInfo.position.y = -95
		
	$ShowInfoAnimation.play("show")

func _cancel_attack():
	$ShowDamageLabel.play_backwards("show")
	$ReadyToBeAttackedAnimation.play_backwards("ready")
	Game.game.player.cancel_attack()
	player_damage = 0

func _on_button_mouse_exited():
	emit_signal("enemy_mouse_leaved")
	# Наведено ли на монстра вещество
	if player_damage:
		_cancel_attack()
	is_hovering = false
	Input.set_custom_mouse_cursor(SpritesInfo.hand_cursor, Input.CURSOR_POINTING_HAND)
	
	if not $DamageAnimation.is_playing():
		$ShowInfoAnimation.play_backwards("show")

func _death(animation: bool = true):
	
	"""Функция смерти врага"""
	
	# Удаление всех индикаторов атаки
	delete_indicators()
	
	# Удаляем материал, чтобы анимация исчезновения
	# отобаржался нормально
	$AnimatedSprite.material = null
	
	# Вызываем сигнал о смерти
	emit_signal("died", self)
	if animation:
		$DamageAnimation.play("death")
		await $DamageAnimation.animation_finished
	queue_free()

func _ready():
	# Делаем материал уникальным
	$AnimatedSprite.material = $AnimatedSprite.material.duplicate()
	
	$EnemyInfo/InfoContainer/Name.set_text(enemy_name)
	health_bar.setup(health)
	
	# Если этого монстра можно атаковать
	if attacked:
		# Включаем игроку возможность навестись
		$Button.mouse_filter = 1
		
		var info_container = $EnemyInfo/InfoContainer
		
		# Выбор случайной слабости
		weakness_class = CHEM_CLASSES.pick_random()
		var class_color = SpritesInfo.COLOR_BY_RU_NAME[weakness_class]
		info_container.get_node("WeaknessClass").set_text(
			"[color=" + class_color + "]" + weakness_class
		)

func _process(delta):
	$DamageLabel.position = get_local_mouse_position() * 0.5
	_show_damage()

func is_died() -> bool:
	return health_bar.get_health() <= 0 

func damage() -> void:
	
	"""
	Функция для нанесения урона врагу
	"""
	
	if is_died():
		return
	
	# Уменьшение хп в хеллбаре
	health_bar.damage(player_damage)
	# Анимация
	$DamageAnimation.play("damage")
	$DamageAudio.play()
		
	# Ожидания конца анимации
	await $DamageAnimation.animation_finished
	# Прячем инфо и возвращаем все
	$DamageAnimation.play("RESET")
	$ShowInfoAnimation.play("RESET")
	
	# Если игрок все еще наводит курсор на монстра, то после
	# проигрывания анимации урона снова показываем игроку
	# инфо о монстре
	if is_hovering:
		$ShowInfoAnimation.play("show")

	if is_died():
		_death()

func damage_player(map) -> void:
	map.player.game.ui.health_bar.damage(damage_count)

func create_attack_indicator(coords: Vector2i) -> Indicator:
	# Создание индикатора
	var indicator = Indicator.new(
		coords, damage_count, Game.game.get_current_room(), self
	)
	indicators.append(indicator)
	return indicator

func get_indicator_with_coords(coords: Vector2i) -> Indicator:
	for indicator in indicators:
		if indicator.current_coords == coords:
			return indicator
	return null
