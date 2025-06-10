extends Node2D

func _ready():
	print(Reaction.new().str_reaction("H2 + N2"))
	print(Reaction.new().str_reaction("CO + O2"))
	print(Reaction.new().str_reaction("HNO3 + CaO"))
