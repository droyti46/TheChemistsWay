class_name SolubilityTable
extends Node

"""
Класс предназначен для работы с химической таблицей растворимости
Методы можно прочитать ниже
"""

# Загрузка таблицы (используется плагин
# https://github.com/timothyqiu/godot-csv-data-importer)
var table = preload("res://gdchem/resources/solubility_table.csv")

func get_solubility(cation: String, anion: String) -> String:
	
	"""
	Функция возвращает растворимость вещества
	
	Параметры:
		cation (String): катион (первый ион)
		anion (String): анион (второй ион)
		
	Возвращаемое значение:
		solubility (String):
			Одно из значений: "Р", "Н", "?", "–"
			
	Пример:
		var table = SolubilityTable.new()
		
		print(table.get_solubility("K", "Br")) # Р
		print(table.get_solubility("Mn2", "OH")) # Н
		print(table.get_solubility("Cu2", "I")) # ?
	"""
	
	# Проход по строчкам таблицы
	for row in table.records:
		# Если анион в строчке равен переданному аниону
		if row["anion"] == anion:
			# То возвращаем значение строчки по катиону
			if cation in row.keys():
				return row[cation]
			# Если напрямую получить не удаётся, то проходимся
			# по всем катионам
			for cation_table in row.keys().slice(1):
				if cation in cation_table:
					return row[cation_table]
	
	print("Не получается найти вещество с анионом ", anion,
		  " и катионом ", cation)
	return ""

func get_valence(elem: String) -> int:
	
	"""
	Функция для получения валентности по таблице растворимости
	
	Параметры:
		elem (String): элемент, валентность которого надо получить
		
	Возвращаемое значение:
		valence (int): валентность вещества
		
	Пример:
		var table = SolubilityTable.new()
		print(table.get_valence("Mn")) # 2
		print(table.get_valence("H")) # 1
		print(table.get_valence("Al")) # 3
	"""
	
	# Проход по всем катионам в таблице растворимости
	# Взят срез со второго элемента, так как первое поле в таблице -
	# это строка "anion"
	for elem_in_table in table.records[0].keys().slice(1):
		# Если элемент есть в элементе из таблицы, т.е., например,
		# "Sn" есть в "Sn2" или "Cr" в "Cr3"
		if elem in elem_in_table:
			# Если последний символ элемента из таблицы это число
			# Например, "Ba2", 2 - это число
			if Utils.is_digit(elem_in_table[-1]):
				# То просто возвращаем это число, приведённое
				# к типу int
				return int(elem_in_table[-1])
			# Иначе (например, H, K или Na)
			# То валентность равна единице
			return 1
	print("Не получается найти элемент ", elem)
	return 0
