extends Node2D

func metal():
	var cu = Substance.new().from_element("Cu")
	var fe = Substance.new().from_element("Fe")
	
	var fecl2 = Substance.new().from_formula("FeCl2")
	var cucl2 = Substance.new().from_formula("CuCl2")
	
	var cu_fecl2 = Reaction.new().reaction(cu, fecl2)
	if (cu_fecl2.get_problem()):
		print(cu_fecl2.get_problem())

	var fe_cucl2 = Reaction.new().reaction(fe, cucl2)
	print(fe_cucl2)

func acid():
	var bacl2 = Substance.new().from_formula("BaCl2")
	print(bacl2)
	var h2so4 = Substance.new().from_formula("H2SO4")
	print(h2so4)
	var reaciton = Reaction.new().reaction(bacl2, h2so4)
	print(reaciton)
	if reaciton.get_problem(): print(reaciton.get_problem())

func _ready():
	metal()
	acid()
