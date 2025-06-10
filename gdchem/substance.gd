class_name Substance
extends Node

enum CLASSES {METAL, NONMETAL, OXIDE, BASE, SALT, ACID}

const RU_CLASS_NAMES = ["Металл", "Неметалл", "Оксид", "Основание",
						"Соль", "Кислота"]

# Коэффициент в реакции
# Например, если вещество H2 участвует в реакции
# 2H2 + O2 -> 2H20, то коэффициент равен 2
var coefficient: int = 1

# Первый и второй ион
# Например, если вещество H2O, то первый ион H, а второй -
# O; а для K2SO4 первый ион K, а второй SO4
var ion1: Ion
var ion2: Ion

# Класс вещества (металл, неметалл, оксид,
# гидроксид, соль, кислота)
var chemical_class: int

"""Характеристики вещества"""
# Является ли вещество простым
var _is_simple: bool
# Фаза (газ, жидкость, твердое вещество)
var phase: String
# Электроотрицательность
var electronegativity: float
# Валентность
var valence: int

func _get_formula() -> String:
	"""Получение текстовой формулы"""
	var formula: String = ""
	
	formula += str(ion1)
	if (ion1.count != 1):
		formula += str(ion1.count)
	
	if ion2:
		if (ion2.count != 1):
			if not (ion2.is_simple()):
				formula += "(" + str(ion2) + ")"
				formula += str(ion2.count)
			else:
				formula += str(ion2) + str(ion2.count)
		else:
			formula += str(ion2)

	return formula

func _to_string():
	"""Текстовое представление вещества"""
	return _get_formula()

func _define_class():
	"""Определяет класс вещества"""
	match ion2.ion_str:
		# Если второй ион это O
		"O":
			# То класс оксид
			chemical_class = CLASSES.OXIDE
		# Если второй ион это OH
		"OH":
			# то класс основание
			chemical_class = CLASSES.BASE
		# Иначе смотрим на первый ион
		_:
			match ion1.ion_str:
				# Если это водород, то класс кислота
				"H":
					chemical_class = CLASSES.ACID
				# Иначе это соль
				_:
					chemical_class = CLASSES.SALT

func from_element(element_from: String) -> Substance:
	
	"""
	Функция принимает название элемента и возвращает вещество
	Например, приняв "Cl" функция вернёт объект, который
	будет являться представлением вещества Cl2
	"""
	
	# Загрузка элемента из таблицы Менделеева
	var ion = Ion.new().from_element(element_from)
	
	# Вещество простое
	_is_simple = true
	# Проверка на то, является вещество металлом или неметаллом
	if not "nonmetal" in ion.category:
		chemical_class = CLASSES.METAL
	else:
		chemical_class = CLASSES.NONMETAL
	
	var count = 1
	# Проверка на то, состоит ли вещество из двух
	# атомов
	if "diatomic" in ion.category:
		# Если состоит из 2-х атомов, 
		# то количество в формуле 2
		count = 2
	
	ion1 = ion
	ion.count = count
	
	return self

func from_formula(formula: String) -> Substance:
	
	"""
	На основе формулы возврвщает объект вещества
	
	Примеры формул:
	K2SO4
	HCl
	Ca(OH)2
	"""
	
	# Если формула состоит всего из одного элемента
	if Utils.count_upper(formula) == 1:
		# То для генерации используем метод from_element
		return from_element(Utils.delete_digits(formula))
	
	# TODO: желательно попробовать переписать парсящий код
	# более понятно
	var element: String = formula[0]
	var ion2_start_index: int
	
	# Парсинг первого иона
	# (начиная со второго символа, так как первый
	# уже добавлен в element)
	for i in range(formula.substr(1).length()):
		# Получение символа по индексу
		var c: String = formula.substr(1)[i]
		# Если это число
		if Utils.is_digit(c):
			# То мы уже спарсили один элемент,
			# добавляем его
			var count = int(c)
			var ion = Ion.new().from_element(element)
			ion.count = count
			# Первый ион
			ion1 = ion
			ion2_start_index = i + 2
			break
		# Если начался новый ион, то мы тоже уже спарсили первый
		elif Utils.is_upper(c) or c == "(":
			var ion = Ion.new().from_element(element)
			ion.count = 1
			# Первый ион
			ion1 = ion
			ion2_start_index = i + 1
			break
		# Если это строчная буква, например, l в Cl
		elif Utils.is_lower(c):
			# То добавляем это к элементу
			element += c
	
	# Парсинг второго иона, если первый уже спарсен
	var ion_formula: String = ""
	# Проход от начала второго иона
	for i in range(ion2_start_index, formula.length()):
		var c: String = formula[i]
		# Скобки пропускаем
		if c in "()":
			continue
		# Если символ это число
		if Utils.is_digit(c):
			# Если за этим числом стояла скобка
			# Например, как в Sr(OH)2 или если
			# второй ион состоит из одного элемента
			if formula[i - 1] == ")" or Utils.count_upper(formula.substr(ion2_start_index)) == 1:
				var count = int(c)
				var ion = Ion.new().from_formula(ion_formula)
				ion.count = count
				ion2 = ion
				continue
		
		if not Utils.is_digit(c) and i < formula.length() - 1:
			ion_formula += str(c)

		if i == formula.length() - 1:
			ion_formula += c
			var ion = Ion.new().from_formula(ion_formula)
			if not ion:
				ion = Ion.new().from_element(ion_formula)
			ion.count = 1
			ion2 = ion
	
	# У иона может быть непостоянная валентность
	if not ion1.is_main_subgroup() or \
	   ion1.ion_str in ["S", "N", "P", "Fe", "Cu", "C", "Si", "Cl", "Br", "I"]:
		# Поэтому мы высчитываем валентность исходя из
		# первого иона
		# Например, если формула Fe3(PO4)2, то
		# valence Fe = (valence PO4 * count PO4) / count Fe
		# valence Fe = (3 * 2) / 3 = 2
		ion1.valence = (ion2.valence * ion2.count) / ion1.count
	
	# Проверка на класс
	_define_class()

	return self

func from_ions(from_ion1: Ion, from_ion2: Ion) -> Substance:
	"""
	Функция получает два объекта класса Ion и возвращает
	вещество на их основе
	
	Пример:
		var k = Ion.new().from_element("K")
		var so3 = Ion.new().from_formula("SO3")
		var substance = Substance.new().from_ions(k, so3)
		
		print(substance) # K2SO3
	"""
	
	# Рассчитывание НОК обоих ионов
	var lcm = Utils.calculate_lcm(from_ion1.valence,
								  from_ion2.valence)

	# Расчитываем валентность для каждого элемента
	var count1 = lcm / from_ion1.valence
	var count2 = lcm / from_ion2.valence
	
	ion1 = from_ion1.copy()
	ion1.count = count1
	
	ion2 = from_ion2.copy()
	ion2.count = count2
	
	# Определение ласса
	_define_class()
	
	return self

func calculate_damage() -> int:
	var damage: int = ion1.calculate_damage()
	if ion2:
		if ion2.is_simple():
			damage += ion2.calculate_damage()
		else: damage += ion2.calculate_damage() * ion2.count
	return damage

func is_simple() -> bool:
	return _is_simple

func is_metal() -> bool:
	return chemical_class == CLASSES.METAL

func is_nonmetal() -> bool:
	return chemical_class == CLASSES.NONMETAL
	
func is_salt() -> bool:
	return chemical_class == CLASSES.SALT

func is_oxide() -> bool:
	"""Проверяет, является ли вещество оксидом"""
	return chemical_class == CLASSES.OXIDE

func is_metal_oxide() -> bool:
	"""Проверка, является ли вещество оксидом металла"""
	return is_oxide() and ion1.is_metal()

func is_acid_oxide() -> bool:
	"""Проверяет, является ли вещество кислотным оксидом"""
	# Кислотный оксид - оксид металлов и неметаллов с
	# валентностью >= 4
	return is_oxide() and (ion1.valence >= 4 or
						   not ion1.is_metal())

func is_basic_oxide() -> bool:
	"""Проверяет, является ли вещество основным оксидом"""
	# Основной оксид - оксид металлов с
	# валентностью 1 или 2, кроме ZnO, BeO, PbO, SnO
	return (chemical_class == CLASSES.OXIDE) and \
			(ion1.is_metal()) and \
			(ion1.valence == 1 or ion1.valence == 2) and \
			(ion1.ion_str not in ["Zn", "Be", "Pb", "Sn"])

func is_base() -> bool:
	"""Проверяет, является ли вещество гидроксидом"""
	return chemical_class == CLASSES.BASE

func is_alkali() -> bool:
	"""Проверяет, является ли вещество щелочью"""
	return (is_base() and \
			(ion1.valence == 1 or ion1.valence == 2))

func is_alkali_metal() -> bool:
	"Проверяет, является ли вещество щёлочным металлом"
	return (is_simple() and ion1.is_alkali_metal())

func is_not_alkale() -> bool:
	"""Проверяет, является ли вещество нерастворимым
	основанием"""
	# Нерастворимое основание - все оставльные основания
	return (is_base() and not is_alkali())

func is_acid() -> bool:
	return chemical_class == CLASSES.ACID

func is_soluble() -> bool:
	"""Проверяет, раствориммое ли вещество"""
	return SolubilityTable.new().get_solubility(
		str(ion1), str(ion2)
	) == "Р"

func get_ru_class() -> String:
	return RU_CLASS_NAMES[chemical_class]
