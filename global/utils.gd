extends Node

func coords_is_valid(coords: Vector2i,
					 obstacles_coords: Array):

	return coords not in obstacles_coords and \
		   coords.x != -1 and \
		   coords.x != SpritesInfo.ROOM_COUNT_TILES_X and \
		   coords.y != -1 and \
		   coords.y != SpritesInfo.ROOM_COUNT_TILES_Y

func distance(vector1, vector2) -> float:
	"""Считает расстояние между двумя векторами"""
	var dist: float = sqrt(
		(vector1.x - vector2.x) ** 2 + (vector1.y - vector2.y) ** 2
	)
	return dist

func v2_and_v2i_to_v2(v1, v2) -> Vector2:
	# Функция складыватет два вектора и возвращает Vector2
	return Vector2(v1.x + v2.x, v1.y + v2.y)

func merge_arrays(arrays: Array, no_repetitions: bool = false) -> Array:
	
	"""
	Функция для объединения двух массивов
	
	Параметры:
		arrays (Array [Array]):
			массив всех массивов, которые нужно объединить
		no_repetitions (bool), optional:
			нужно ли исключать повторения в новом массиве
	
	Возвращаемое значение:
		new_array (Array):
			массив, в котором содержатся элементы из всех массивов
	"""
	
	# Новый массив
	var new_array: Array = []
	
	# Проход по каждому массиву
	for array in arrays:
		# Если это массив
		if typeof(array) == TYPE_ARRAY:
			# Проход по каждому элементу и добавление их в новый массив
			for elem in array:
				# Проверка на то, нужно ли исключать повторения
				if (no_repetitions and elem not in new_array) or (not no_repetitions):
					new_array.append(elem)
		else:
			new_array.append(array)
	
	# Возвращение нового массива
	return new_array

func load_json(path_to_file: String) -> Dictionary:
	var file = FileAccess.open(path_to_file, FileAccess.READ)
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	if error == OK:
		var data_received = json.data
		return data_received
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", path_to_file, " at line ", json.get_error_line())

	return {}

func load_periodic_table() -> Dictionary:
	return load_json("res://gdchem/resources/periodic_table.json")

func calculate_lcm(x: int, y: int) -> int:
	
	"""Функция для вычисления НОК"""
	
	var greater: int
	var lcm: int
	
	if x > y: 
		greater = x 
	else: 
		greater = y 
		
	while true: 
		if (greater % x == 0) and (greater % y == 0): 
			lcm = greater 
			break 
		greater += 1 
		
	return lcm   

func is_digit(string: String) -> bool:
	
	"""
	Проверка на то, является ли строка числом
	
	Пример:
		func _ready() -> void:
			var s = "123"
			if Utils.is_digit(s):
				s = int(s)
	"""
	
	# Проход по каждому символу в строке
	for c in string:
		# Проверка, является ли символ цифрой
		if c not in "123456789":
			# Если не является, то это уже не число
			return false
	# Если все символы в строке являются цифрами, то это число
	return true

func is_upper(string: String) -> bool:
	
	"""
	Проверяет, написана строка в верхнем регистре или нет
	"""
	
	return string == string.to_upper()

func is_lower(string: String) -> bool:
	
	"""
	Проверяет, написана строка в нижнем регистре или нет
	"""
	
	return string == string.to_lower()

func count_upper(string: String) -> int:
	"""Считает количество заглавных букв в строке"""
	var count = 0
	for c in string:
		if is_upper(c) and not is_digit(c):
			count += 1
	return count

func delete_spaces(string: String) -> String:
	
	"""
	Функция удаляет все пробелы в строке
	Например, "Химия     лучшая" превратится в
	"Химиялучшая"
	"""
	
	var new_str: String = ""
	
	# Проход по каждому символу в строке
	for c in string:
		# Если символ это не пробел
		if c != " ":
			# То её необходимо добавить в новую строку
			new_str += c

	return new_str

func delete_digits(string: String) -> String:
	
	"""
	Функция удаляет все числа из строки
	Например, "Химия123456 лучшая" превратится
	в "Химия лучшая"
	"""
	
	var new_str: String = ""
	
	# Проход по каждому символу в строке
	for c in string:
		# Если символ это не число
		if not is_digit(c):
			# То её необходимо добавить в новую строку
			new_str += c

	return new_str

func convert_reaction_text(reaction_text: String, index_size: int) -> String:
	
	"""
	Функция конвертирует строку с реакцией в форматированную
	строку с маленькими индексами
	
	Параметры:
		reaction_text (String):
			Исходная строка с реакцией
			Пример:
				O2 + Na -> Na2O2
	
	Возвращаемое значение:
		new_text (String):
			Новый форматированный текст
			Пример:
				O[font_size=10]2[/font_size] + Na ->
				Na[font_size=10]2[/font_size]O[font_size=10]2[/font_size]
	"""
	
	var new_text = ""
	
	# Проходимся по каждому символу
	for i in len(reaction_text):
		# Прибавляем к новому тексту этот символ
		new_text += reaction_text[i]
		# Если после символа стоит число
		# Условие i != len(reaction_text) - 1 добавлено, чтобы
		# избежать случаев, когда сейчас перебирается последний
		# в строке символ, а вторая проверка проверяет по
		# индексу i + 1
		if i != len(reaction_text) - 1 and \
		   Utils.is_digit(reaction_text[i + 1]):
			# Прибавляем тег для размера шрифта
			new_text += "[font_size=" + str(index_size) + "]"
		# Если текущий символ это цифра
		elif Utils.is_digit(reaction_text[i]):
			# Прибавляем закрывающий тег
			new_text += "[/font_size]"

	return new_text
