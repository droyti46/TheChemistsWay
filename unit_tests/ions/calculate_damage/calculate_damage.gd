extends Node

func _ready():
	var li2co3 = Substance.new().from_formula("Li2CO3")
	print(li2co3.calculate_damage()) # 42
	
	var caoh2 = Substance.new().from_formula("Ca(OH)2")
	print(caoh2.calculate_damage()) # 36

