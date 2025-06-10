extends Control

const INDEX_FONT_SIZE = 40
const BOTTOM_ALIGMENT = 2

var symbol_label: PackedScene = preload("res://gdchem/scenes/formula_label/symbol_label.tscn")

func setup(formula: String) -> void:
	
	"""
	Метод, чтобы задать лейблу текст по формуле
	
	Параметры:
		formula (String): формула
						  Примеры: H2SO4, HCl, Ca(OH)2, F2
	"""
	
	# Проход по каждому символу в формуле
	for symbol in formula:
		# Создание лейбла для символа
		var label: Label = symbol_label.instantiate()
		# Установка текста
		label.set_text(symbol)
		# Если символ - это число (т.е. индекс)
		if Utils.is_digit(symbol):
			# То текст делается меньше, а выравнивание по вертикали
			# устанавливается BOTTOM
			label.add_theme_font_size_override("font_size", INDEX_FONT_SIZE)
			label.vertical_alignment = BOTTOM_ALIGMENT
		label.pivot_offset = label.size / 2
		$SymbolsContainer.add_child(label)
