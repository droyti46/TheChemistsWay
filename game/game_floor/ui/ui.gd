extends Control

const CountMovesText: String = "Осталось ходов: "
const MAX_SUSTANCES_INVENTORY = 15

@onready var mini_map = $SubViewportContainer/SubViewport/MiniMap
@onready var health_bar = $HealthBar

# Прелоад сцены с веществом
var substance_preload = preload("res://gdchem/scenes/game_substance.tscn")

# Максимальное количество ходов игрока
var max_moves: int
# Текущее количество ходов игрока
var count_moves: int

# Происходит ли сейчас бой
var is_fight: bool = false

# Инвентарь с веществами
"""
{
	"H2O" : GameSubstance
}
"""
var substances_inventory: Dictionary = {}

# Вещество, которое в данный момент перемещается мышкой
# (Drag and Drop) для создания реакций
var moving_substance = null
# Реакция, которая в данные момент времени получается
# при наведении одного вещества на другое
var reaction: Reaction = null
# Массив с веществами, которые нужно добавить
var substances_to_add: Array[Substance] = []
var substances_to_reduce: Array[Substance] = []

# Монстр, на которого навели мышь
var enemy_hovering

func _input(event):
	if event is InputEventMouseButton:
		# Если мы отжали кнопку мыши
		if not event.pressed:
			if enemy_hovering and moving_substance:
				enemy_hovering.damage()
				moving_substance.reduce(1)
				reduce_moves()
				Game.game.player.reduce_moves()
			
			# Если реакция существует
			if reaction and reaction.right:
				substances_to_add = reaction.right
				substances_to_reduce = reaction.left
				# Проигрывание анимации
				Game.game.player.reaction_anim()

			moving_substance = null
			reaction = null

func _on_enemy_is_ready_to_attacked(enemy) -> void:
	enemy_hovering = enemy

func _on_enemy_mouse_leaved() -> void:
	enemy_hovering = null

func _substance_finished_moving():
	if substances_to_add:
		# Если игрок сейчас находится в комнате с монстрами
		if Game.game.get_current_room().get_type() == "Enemies":
			# Сокращаем количество ходов
			reduce_moves()
			Game.game.player.reduce_moves()

	for substance in substances_to_reduce:
		if substance and str(substance) in substances_inventory.keys():
			substances_inventory[str(substance)].reduce(1)

	for substance in substances_to_add:
		# Проигрываем звук создания
		$NewSubstancePlayer.play()
		# Добавляем новое вещество
		add_substance(substance, 1)
		await get_tree().create_timer(0.2).timeout
		
	substances_to_add = []

func _substance_is_moving(substance) -> void:
	"""Когда вещество перемещается мышкой"""
	# Устанавливаем перемещающееся вещество
	moving_substance = substance

func _substance_is_hovering(hovering_substance) -> void:
	"""Наведено на вещество"""
	# Если мы просто наводим мышь, а не 
	# объекдиняем одно вещество с другим, то скип
	if not moving_substance:
		return
	
	# Показываем меню с реакцией
	$ReactionBG.show()
	# Задаём реакцию
	reaction = Reaction.new().reaction(
		moving_substance.substance,
		hovering_substance.substance
	)
	
	# Устанавливаем текст
	var reaction_text: String
	if reaction.right:
		reaction_text = Utils.convert_reaction_text(str(reaction), 10)
	elif reaction.get_problem():
		reaction_text = reaction.get_problem()
	else:
		reaction_text = "Вещества не реагируют или разработчик забыл продумать этот момент " + \
						"(ради справедливости, у разработчика было мало времени, а химия большая)"
	$ReactionBG/ReactionLabel.set_text("[center]" + reaction_text)

func _update_inventory_count_label() -> void:
	"""Функция задает новое количество веществ в  инвентаре игрока"""
	$InventoryCountLabel.set_text(
		str(len(substances_inventory)) + "/" + str(MAX_SUSTANCES_INVENTORY)
	)
	$InventoryCountLabel/Animation.play("update")

func _on_substance_is_over(substance) -> void:
	"""Когда какое-либо вещество заканчивается"""
	substances_inventory.erase(str(substance))
	substance.queue_free()
	# Обновляем Label, в котором показано количество веществ
	# у игрока
	_update_inventory_count_label()

func _substance_mouse_leaved() -> void:
	"""Если мышка отведена от вещества"""
	$ReactionBG.hide()
	reaction = null

func _on_player_died() -> void:
	$DeathScreen.show()

func _ready():
	health_bar.connect("died", _on_player_died)

func set_moves(count: int) -> void:
	
	"""
	Функция, чтобы задать интерфейсу количество ходов у персонажа
	count - количество ходов
	"""
	
	max_moves = count
	count_moves = count
	$CountMovesLabel.set_text(CountMovesText + str(count_moves))

func add_substance(substance: Substance, count) -> void:
	"""Добавляет в интерфейс новое вещество"""
	if len(substances_inventory) >= MAX_SUSTANCES_INVENTORY:
		$MessageLabel.show()
		await get_tree().create_timer(1).timeout
		$MessageLabel.hide()
		return
	
	# Если вещества еще нет в инвентаре, мы его добавляем
	if str(substance) not in substances_inventory.keys():
		var substance_scene = substance_preload.instantiate()
		
		substance_scene.connect("substance_is_moving", _substance_is_moving)
		substance_scene.connect("substance_is_hovering", _substance_is_hovering)
		substance_scene.connect("substance_mouse_leaved", _substance_mouse_leaved)
		substance_scene.connect("substance_finished_moving", _substance_finished_moving)
		substance_scene.connect("substance_is_over", _on_substance_is_over)
		
		# Добавление в словарь
		substances_inventory[str(substance)] = substance_scene
		
		# Передаем интерфейс (себя) и вещество, на основе которого
		# будет создано игровое вещество
		substance_scene.setup(substance, count, self)
		$SubstancesContainer.add_child(substance_scene)
		
		# Изменяем Label, в котором показано количество веществ
		# у игрока
		_update_inventory_count_label()
	
	else:
		# Если вещество уже есть в инвентаре, то мы просто
		# увеличиваем его количество
		substances_inventory[str(substance)].add(count)

func set_substances(substances: Array[Substance]) -> void:
	
	"""
	Функция задаёт начальные вещества
	
	Пример:
		var substances = [
			Substance.new().from_formula("H2O"),
			Substance.new().from_formula("Ca(OH)2"),
			Substance.new().from_formula("HCl")
		]
		ui.set_substances(substances)
	"""
	
	for substance in substances:
		add_substance(substance, "inf")

func reduce_moves() -> void:
	# Если сейчас не бой, ничего делать не надо
	if not is_fight: return
	$FightAnimations.play("reduce_moves")
	count_moves -= 1
	$CountMovesLabel.set_text(CountMovesText + str(count_moves))
	# if not count_moves:
		# $FightAnimations.play("player_moves_are_over")
	
func reload_moves() -> void:
	count_moves = max_moves
	$CountMovesLabel.set_text(CountMovesText + str(count_moves))
	Game.game.player.remained_moves = max_moves
	# $FightAnimations.play_backwards("player_moves_are_over")

func fight_finished_animation() -> void:
	is_fight = false
	$FightMessage/Animation.play("on")
	$WinAudio.play()
	%FightMessageLabel.set_text("Бой закончился")
	$FightAnimations.play_backwards("show_fight")
	
func fight_animation() -> void:
	is_fight = true
	$FightMessage/Animation.play("on")
	%FightMessageLabel.set_text("Бой начался")
	$FightStartedAudio.play()
	$FightAnimations.play("show_fight")
