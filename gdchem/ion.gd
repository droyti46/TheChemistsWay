class_name Ion
extends Node

# Валентность некоторых ионов и кислотных оснований
const IONS_VALENCE = {
	"O": 2,
	"OH": 1,
	"NO3": 1,
	"F": 1,
	"Cl": 1,
	"Br": 1,
	"I": 1,
	"S": 2,
	"NO2": 1,
	"SO3": 2,
	"SO4": 2,
	"CO3": 2,
	"SiO3": 2,
	"PO4": 3,
	"CrO4": 2
}

var count: int

var _is_main_subgroup: bool = false
var _is_simple: bool

var ion_str: String
var electronegativity: float
var valence: int = 1
var damage: int
var category: String
var element_name: String = ""

func _set_is_simple() -> void:
	var cnt_atoms: int = 0
	for c in ion_str:
		if not Utils.is_digit(c) and Utils.is_upper(c):
			cnt_atoms += 1
	if cnt_atoms == 1:
		_is_simple = 1

func _to_string() -> String:
	return ion_str

func from_element(element_from: String, _valence = 0) -> Ion:
	# Загрузка таблицы Менделеева и таблицы растворимости
	var periodic_table: Dictionary = Utils.load_periodic_table()
	var solubility_table: SolubilityTable = SolubilityTable.new()
	# Т.к. ион - это элемент, то ион простой
	_is_simple = true
	# Проход по названию каждого элемента из таблицы
	# Менделеева
	for element in periodic_table["order"]:
		# Информация об элемента
		var element_info: Dictionary = periodic_table[element]

		# Если это элемент, который нужен (т.е. с тем же символом)
		if element_info["symbol"] == element_from:
			# То ставим формулу этого элемента
			ion_str = element_info["symbol"]
				
			# Заполнение остальных характеристик элемента
			electronegativity = element_info["electronegativity_pauling"]
			element_name = element_info["name"]
			var group = element_info["group"]
			if (_valence):
				valence = _valence
			elif (group == 1 or group == 2):
				valence = group
			elif (group == 13):
				valence = 3
			elif (group == 14):
				valence = 4
			elif (group == 15):
				valence = 3
			elif (group == 16):
				valence = 2
			elif (group == 17):
				valence = 1
			# Если элемент не из главной подгруппы, то
			# пытаемся выщить из таблицы растворимости
			else:
				var val_from_solubility_table = solubility_table.get_valence(element_from)
				if val_from_solubility_table:
					valence = val_from_solubility_table
			
			if (group <= 2 or group >= 13):
				_is_main_subgroup = true
			
			category = element_info["category"]
			damage = element_info["number"]

	return self

func from_formula(formula: String) -> Ion:
	"""
	Получение иона из формулы
	"""
	# Если иона нет в словаре, то возвращает null
	if formula not in IONS_VALENCE.keys():
		# print("Нет такого иона: " + formula)
		return
	
	# Иначе ставит валентность и текстовый вид
	ion_str = formula
	valence = IONS_VALENCE[formula]
	
	# Установка того, простое вещество или нет
	_set_is_simple()
	
	return self

func calculate_damage() -> int:
	# Если ион простой, то достаточно просто прибавить его
	# урон, домноженный на количество
	if (is_simple()):
		return Ion.new().from_element(ion_str).damage * count
	
	# Иначе считаем урон
	else:
		var damage: int = 0
		var elem: String = ""
		for c in ion_str + "W":
			if Utils.is_digit(c):
				damage += Ion.new().from_element(elem).damage * int(c)
				elem = ""
			elif Utils.is_upper(c) and len(elem) :
				damage += Ion.new().from_element(elem).damage
				elem = ""
			if not Utils.is_digit(c):
				elem += c
		
		return damage
	
	return 0

func copy() -> Ion:
	"""Полное копирование иона"""
	# Создание новой копии иона
	var new_ion = Ion.new().from_formula(ion_str)
	if not new_ion:
		new_ion = Ion.new().from_element(ion_str)
	
	# Ставит все аттрибуты
	new_ion.category = category
	new_ion.valence = valence
	new_ion.count = count
	new_ion._is_main_subgroup = _is_main_subgroup
	new_ion.electronegativity = electronegativity
	
	return new_ion

func is_main_subgroup() -> bool:
	"""Проверяет, находится ли ион в главной подгруппе"""
	return _is_main_subgroup

func is_simple() -> bool:
	"""Проверяет, простой ион или нет"""
	return _is_simple

func is_metal() -> bool:
	"""Проверяет, является ли ион металлом"""
	return not "nonmetal" in category

func is_alkali_metal() -> bool:
	"""Проверяет, является ли ион щелочным металлом"""
	return ion_str in ["Li", "Na", "K", "Rb", "Cs", "Ca", "Sr", "Ba"]
