extends Control

enum STATES {moving, coming_home, idle}

# Сигнал вещество начало перемещаться
signal substance_is_moving
# Сигнал вещество закончило перемещаться
signal substance_finished_moving
# Сигнал на вещество навели мышкой
signal substance_is_hovering
# Сигнал от вещества убрали мышку
signal substance_mouse_leaved
# Вещество закончилось
signal substance_is_over

var substance: Substance = null
# Урон, который наносит вещество
var damage: int

# Графический интерфейс игрока
var ui: Control

var state: int = STATES.idle
# Положение курсора мыши при начале перетаскивания
var initial_mouse_position: Vector2
# Положение вещества при начале перетаскивания
var substance_start_position: Vector2

# Количество веществ в инвентаре
var count = 0

func _to_string():
	return str(substance)

func _on_button_mouse_entered() -> void:
	"""Когда игрок навел курсор"""
	if state == STATES.idle:
		if not ui.moving_substance:
			$InfoAnim.play("hover")
		# Перемещаем вещество на передний план,
		# чтобы оно не закрывалось другими веществами
		z_index = 1
		$Anim.play("hover")
		$HoverAudio.play()
		# Вызываем сигнал
		emit_signal("substance_is_hovering", self)

func _on_button_mouse_exited() -> void:
	"""Когда игрок отвел курсор"""
	if state == STATES.idle:
		if not ui.moving_substance:
			$InfoAnim.play_backwards("hover")
		$Anim.play_backwards("hover")
		# Поскольку мы поместили вещество на передний план,
		# когда наводили мышь, теперь его назад надо
		z_index = 0
		emit_signal("substance_mouse_leaved")

func _on_button_button_down() -> void:
	"""Когда зажали кнопку мыши"""
	# Если состояние отличное от состояния покоя, то
	# просто игнорируем
	if state != STATES.idle:
		return
	$Button.mouse_filter = MOUSE_FILTER_IGNORE
	# Прячем инфо о веществе
	$InfoAnim.play_backwards("hover")
	initial_mouse_position = get_local_mouse_position()
	# Получаем начальное положение вещества, чтобы потом вернуться
	substance_start_position = position
	# Состояние движения
	state = STATES.moving
	# Убираем анимацию наведения
	$Anim.play_backwards("hover")
	# Вызываем сигнал
	emit_signal("substance_is_moving", self)

func _on_button_button_up() -> void:
	"""Когда кнопку мыши отжали"""
	$Button.mouse_filter = MOUSE_FILTER_STOP
	# Состояние возвращения домой (вещество возвращается на место)
	state = STATES.coming_home
	# Анимация возвращения
	var tween: Tween = create_tween()
	tween.tween_property(self, "position",
		substance_start_position, 0.2).set_trans(Tween.TRANS_SINE)
	await tween.finished
	# Когда вернулось, состояние снова обычное
	state = STATES.idle
	# Вызываем сигнал
	emit_signal("substance_finished_moving")

func _process(delta) -> void:
	# Если состояние движения
	if state == STATES.moving:
		# То задаём позицию, как у курсора мыши
		# - get_parent().position необходимо, чтобы 
		# положения родителя при перемещении тоже учитывалось
		position = get_global_mouse_position() - get_parent().position - initial_mouse_position
		
func _ready():
	# КОСТЫЛЬ
	# Почему-то размер этих нод в испекторе постоянно
	# менялся
	$BG.set_deferred("size", $BG.custom_minimum_size)
	$FormulaLabel.set_deferred("size", $FormulaLabel.custom_minimum_size)
	#$FormulaLabel.size = $FormulaLabel.custom_minimum_sizes

func _input(event):
	# КОСТЫЛЬ
	# Так как мы поставили filter у кнопки на ignore, то
	# напрямую она обрабатывать нажатия не может. Следовательно,
	# обрабатываем отжатие кнопки через input
	if event is InputEventMouseButton:
		if event.button_mask == 0:
			if state == STATES.moving:
				_on_button_button_up()

func add(add_count: int):
	$Anim.play("show")
	
	# Если вещества и так бесконечно, то ничего не делаем
	if str(count) == "inf":
		return
	
	count += add_count
	$CountLabel.set_text(str(count))

func reduce(reduce_count: int):
	# Если вещества и так бесконечно, то ничего не делаем
	if str(count) == "inf":
		return
	
	count -= reduce_count
	$CountLabel.set_text(str(self.count))
	
	# Если вещества уже нет, то удаляем его
	if count <= 0:
		emit_signal("substance_is_over", self)

func setup(substance: Substance, count, ui: Control = null) -> void:
	
	"""
	Метод для настойки вещества
	
	Параметры:
		ui (Control): нода пользовательского интерфейса
		substance (Substance): объект вещества, на основе
							   которого создается графическое
							   представление вещества
	"""
	
	if str(count) == "inf":
		$CountLabel.set_text("∞")
	else:
		$CountLabel.set_text(str(count))
	self.count = count
	
	self.substance = substance
	self.ui = ui
	
	$FormulaLabel.setup(str(substance))
	
	# Задаём все параметры для информации
	var info_container = $SubstanceInfo/InfoContainer
	info_container.get_node("Formula").set_text(
		Utils.convert_reaction_text(str(substance), 20)
	)
	
	var second_names = Utils.load_json("res://gdchem/resources/names.json")
	if str(substance) in second_names.keys():
		info_container.get_node("SecondName").set_text(second_names[str(substance)])
	elif substance.is_simple():
		info_container.get_node("SecondName").set_text(substance.ion1.element_name)
	else:
		info_container.get_node("SecondName").hide()
		
	info_container.get_node("MassLabel").set_text(
		"Урон: %s" % substance.calculate_damage()
	)
	damage = substance.calculate_damage()
	
	# Ищем цвет класса
	var class_color: String
	if substance.is_base():
		class_color = SpritesInfo.BASE_COLOR
	elif substance.is_acid():
		class_color = SpritesInfo.ACID_COLOR
	elif substance.is_salt():
		class_color = SpritesInfo.SALT_COLOR
	elif substance.is_oxide():
		class_color = SpritesInfo.OXIDE_COLOR
	elif substance.is_metal():
		class_color = SpritesInfo.METAL_COLOR
	elif substance.is_nonmetal():
		class_color = SpritesInfo.NONMETAL_COLOR
	
	var chemical_class = substance.get_ru_class()
	info_container.get_node("ChemicalClass").set_text(
		"[color=" + class_color + "]" + chemical_class
	)
	
	# Задаём цвет красиви для рамки вещества
	$BG.modulate = class_color
	
	# Устанавливаем картинку, если такая нарисована
	var image_path: String = "res://gdchem/scenes/sprites/substances/%s.png" % str(substance)
	if ResourceLoader.exists(image_path):
		$SubstanceInfo/SubstanceImage.texture = load(image_path)
	else:
		$SubstanceInfo/SubstanceImage.hide()
	
	$Anim.play("show")
