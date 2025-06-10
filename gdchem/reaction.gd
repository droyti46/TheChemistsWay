class_name Reaction
extends Node

const ANION_BY_OXIDE = {
	"SO2": "SO3",
	"SO3": "SO4",
	"N2O3": "NO2",
	"N2O5": "NO3",
	"P2O5": "PO4",
	"CO2": "CO3",
	"Cl2O7": "ClO4",
	"SiO2": "SiO3",
	"H2O": "OH"
}

var problems: Dictionary = Utils.load_json("res://gdchem/resources/problems.json")

# Таблица растворимости
var SOLUBILITY_TABLE = SolubilityTable.new()

var substance1: Substance
var substance2: Substance

var left: Array [Substance] = []
var right: Array [Substance] = []

var problem: String = ""

func _reaction_to_str() -> String:
	"""Представление реакции в текстовом виде"""
	var reaction_str: String = ""
	
	# TODO: тут используется похожий участок кода два раза,
	# следует вынести его в отдельную функцию, например,
	# get_reaction_part(part: Array) -> String
	
	# Проход по левой части (до ->)
	for substance in left:
		# Если коэффициент не равен 1
		if substance.coefficient != 1:
			# Пишем его
			reaction_str += str(substance.coefficient)
		# Добавляем само вещество
		reaction_str += str(substance)
		# Если вещество не последнее, то между ними должен
		# стоять знак +
		if substance != left[-1]:
			reaction_str += " + "
	
	# Между обоими чистями реакции стоит стрелочка
	reaction_str += " -> "
	
	# Проход по правой части (после ->)
	# Аналогично с первым циклом
	for substance in right:
		if substance.coefficient != 1:
			reaction_str += str(substance.coefficient)
		reaction_str += str(substance)
		if substance != right[-1]:
			reaction_str += " + "
	
	return reaction_str

func _to_string():
	return _reaction_to_str()

func _reaction_simple():
	"""Простое вещество с простым веществом"""
	if substance1.is_metal() and substance2.is_metal():
		problem = "Металлы не реагируют с металлами"
		return
		
	# Есть ли среди веществ кислород
	var is_oxygen: bool = false
	
	# Если первое вещество кислород
	if str(substance1.ion1) == "O":
		is_oxygen = true
	
	# Если второе вещество кислород, то
	# меняем их местами, чтобы кислородом оказалось первое вещество
	if str(substance2.ion1) == "O":
		is_oxygen = true
		var tmp = substance1
		substance1 = substance2
		substance2 = tmp
	
	# Если кислород есть
	if is_oxygen:
		# То смотрим на второе вещество
		# И обрабатываем его отдельно, ведь с некоторыми
		# веществами кислород образуед пероксид
		match str(substance2.ion1):
			"Na":
				right = [Substance.new().from_formula("Na2O2")]
				return
			"K":
				right = [Substance.new().from_formula("KO2")]
				return
			"Cs":
				right = [Substance.new().from_formula("CsO2")]
				return
			"Rb":
				right = [Substance.new().from_formula("RbO2")]
				return
	
	# Делаем так, чтобы самый substance2 был самый электроотрицательный
	# элемент, то есть меняем местами substance1 и substance2, если
	# это не так
	if substance2.is_metal() or \
	   substance2.ion1.electronegativity < substance1.ion1.electronegativity:
		var tmp = substance1
		substance1 = substance2
		substance2 = tmp
		
	var product = Substance.new().from_ions(
		substance1.ion1, substance2.ion1
	)

	right = [product]

func _salt_and_metal():
	"""
	Соль с металлом
		Ме + соль -> др. Ме + др. соль
	"""
	var metal1 = substance2
	var salt1 = substance1
	
	var metal2 = Substance.new().from_element(str(salt1.ion1))
	var salt2 = Substance.new().from_ions(
		metal1.ion1, salt1.ion2
	)
	
	# Каждый предыдущий металл должен вытеснять последующий
	# из раствора его солей
	if not (metal1.ion1.electronegativity < metal2.ion1.electronegativity) \
	   and not metal1.ion1.is_alkali_metal():
		problem = problems["metal_displaces_metal"] % [str(metal1), str(metal2)]
		return
	
	# Соль, которая образется, должна быть растворимая
	if not salt2.is_soluble():
		problem = problems["salt_is_not_soluble"] % str(salt2)
		return
	
	right = [metal2, salt2]

func _salt_and_acid():
	"""
	Соль с кислотой
		соль + кислота -> др. соль + др. кислота
		а) если выделяется газ или осадок
	"""
	# Образование новой соли
	var salt = Substance.new().from_ions(
		substance1.ion1, substance2.ion2
	)
	# Образование новой кислоты
	var acid = Substance.new().from_ions(
		substance2.ion1, substance1.ion2
	)
	
	# Если так случайно получилось, что новая кислота это
	# HH, то просто заменяем на H2
	if (str(acid) == "HH"):
		acid = Substance.new().from_element("H")
	
	# Проверка на выделение газа или осадка
	if (salt.is_soluble() and acid.is_soluble()):
		problem = problems["salt_acid_gas_or_sediment"]
		return
		
	right = [salt, acid]
	
func _salt_and_alkali():
	"""
	Соль с щелочью
		соль + МеOH -> нерастворимое основание + др. соль
	"""
	right = [
		Substance.new().from_ions(substance2.ion1,
								  substance1.ion2),
		Substance.new().from_ions(substance1.ion1,
								  substance2.ion2)
	]
	
func _salt_and_salt():
	"""
	Соль с солью
		соль + соль -> др. соль + др. соль
		а) если выделяется газ или осадок
	"""
	var salt1 = Substance.new().from_ions(
		substance2.ion1, substance1.ion2
	)
	var salt2 = Substance.new().from_ions(
		substance1.ion1, substance2.ion2
	)
	# Проверка на растворимость
	if (salt1.is_soluble() and salt2.is_soluble()):
		problem = problems["salt_salt_gas_or_sediment"]
		return
	right = [salt1, salt2]

func _aсid_oxide_and_water():
	"""
	Кислотный оксид с водой
		кисл. оксид + H2O -> кислота
		а) вещество, которое образуется, должно
		   быть растворимым
	"""
	# Поскольку алгоритм выбора итоговой кислоты сложный и
	# для него необходимо рассчитывать степень окисления,
	# было принято решение просто сверять оксид и по нему
	# выбирать кислоту
	var anion = ANION_BY_OXIDE[str(substance1)]
	var new_acid = Substance.new().from_ions(
		Ion.new().from_element("H"),
		Ion.new().from_formula(anion)
	)
	# Итоговая кислота должна быть растворимой
	if not new_acid.is_soluble():
		problem = problems["oxide_water"] % str(new_acid)
		return
	
	right = [new_acid]

func _aсid_oxide_and_alkali():
	"""
	Кислотный оксид с щёлочью
		кисл. оксид + щёлочь -> соль + H2O
	"""
	if str(substance1) == "H2O":
		problem = "Щёлочи не реагируют с водой"
		return
		
	# Получение аниона по оксиду
	if not str(substance1) in ANION_BY_OXIDE:
		problem = "Непредвиденная ошибка. Невозможно обработать"
		return
		
	var anion = str(ANION_BY_OXIDE[str(substance1)])
	var water = Substance.new().from_formula("H2O")
	var salt = Substance.new().from_ions(
		substance2.ion1,
		Ion.new().from_formula(anion)
	)
	right = [salt, water]

func _basic_oxide_and_water():
	"""
	Основной оксид с водой
		МеО + H2O -> щелочь
		а) вещество, которое образуется, должно
		   быть растворимым
	"""
	var hydroxide = Substance.new().from_ions(
		substance1.ion1,
		Ion.new().from_formula("OH")
	)
	if not hydroxide.is_soluble():
		problem = problems["oxide_water"]
		return
	right = [hydroxide]

func _basic_oxide_and_acid():
	"""
	Основной оксид с кислотой
		меО + кислота -> соль + H2O
	"""
	var salt = Substance.new().from_ions(
		substance1.ion1,
		substance2.ion2
	)
	var water = Substance.new().from_formula("H2O")
	right = [salt, water]

func _aсid_oxide_and_basic_oxide():
	"""
	Кислотный оксид с основным
		кисл. оксид + МеО -> соль
	"""
	var metal_ion = substance2.ion1
	var anion = ANION_BY_OXIDE[str(substance1)]
	right = [
		Substance.new().from_ions(
			metal_ion,
			Ion.new().from_formula(anion)
		)
	]
	
func _acid_and_metal():
	"""
	Кислота с металлом
		кислота + Ме -> соль + H2
		а) исключая концентрированную серную и азотную
		   кислоту любой концентрации
		б) Ме должен стоять от Mg (включая) до
		   H в ряду напряжения
		в) соль, которая образуется, должна быть
		   растворима
	"""
	var salt = Substance.new().from_ions(
		substance2.ion1,
		substance1.ion2
	)
	var h2 = Substance.new().from_element("H")
	
	# Исключая конц. серную и азотную любой концентрации
	if str(substance1) == "HNO3":
		problem = problems["acid_excluding"]
		return
	
	# Металл должен стоять от Mg до H
	# Просто сравнение электроотрицательности металла
	# с электроотрицательностью магния и водорода
	if substance1.ion1.electronegativity < \
	   Ion.new().from_element("Mg").electronegativity or \
	   substance1.ion1.electronegativity >= \
	   Ion.new().from_element("H").electronegativity:
		problem = problems["metal_from_mg_to_h"]
		return
	
	# Соль, которая образуется, должна быть растворимая
	if salt.is_soluble():
		problem = problems["acid_salt_is_not_soluble"]
		return
	
	right = [salt, h2]

func _acid_and_base():
	"""
	Кислота с основанием
		кислота + МеOH -> соль + H2O
	"""
	var metal = substance2.ion1
	var anion = substance1.ion2
	
	var salt = Substance.new().from_ions(metal, anion)
	var water = Substance.new().from_formula("H2O")
	
	right = [salt, water]

func _make_reaction():
	if substance1.is_simple() and substance2.is_simple():
		_reaction_simple()
		
	if substance1.is_salt():
		if substance2.is_metal():
			_salt_and_metal()
		elif substance2.is_acid():
			_salt_and_acid()
		elif substance2.is_alkali():
			_salt_and_alkali()
		elif substance2.is_salt():
			_salt_and_salt()
	
	elif substance1.is_acid_oxide():
		if str(substance2) == "H2O":
			_aсid_oxide_and_water()
		elif substance2.is_alkali():
			_aсid_oxide_and_alkali()
		elif substance2.is_basic_oxide():
			_aсid_oxide_and_basic_oxide()
	
	elif substance1.is_basic_oxide():
		if str(substance2) == "H2O":
			_basic_oxide_and_water()
		elif substance2.is_acid():
			_basic_oxide_and_acid()
	
	elif substance1.is_acid():
		if substance2.is_metal():
			_acid_and_metal()
		elif substance2.is_base():
			_acid_and_base()

func reaction(substance1: Substance, substance2: Substance) -> Reaction:
	left = [substance1, substance2]
	
	if str(substance1.ion1) == str(substance2.ion1):
		problem = "У веществ одинаковые катионы, поэтому они не могут реагировать"
		return self

	self.substance1 = substance1
	self.substance2 = substance2
	_make_reaction()
	
	if not right and not problem:
		self.substance1 = substance2
		self.substance2 = substance1
		_make_reaction()

	return self

func str_reaction(str_reaction: String) -> Reaction:
	
	"""
	Функция для реакции двух веществ, записанная в виде
	строки.
	
	Например, "Mg + HCl"
	"""
	
	str_reaction = Utils.delete_spaces(str_reaction)
	var substances = str_reaction.split("+")
	
	var substance1 = Substance.new().from_formula(substances[0])
	var substance2 = Substance.new().from_formula(substances[1])
	
	return reaction(substance1, substance2)

func get_problem() -> String:
	return problem
