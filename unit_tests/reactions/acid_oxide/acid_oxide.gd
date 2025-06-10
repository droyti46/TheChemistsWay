extends Node2D

func water():
	var h2o = Substance.new().from_formula("H2O")
	
	var so2 = Substance.new().from_formula("SO2")
	var so3 = Substance.new().from_formula("SO3")
	var n2o3 = Substance.new().from_formula("N2O3")
	var n2o5 = Substance.new().from_formula("N2O5")

	print(Reaction.new().reaction(so2, h2o))
	print(Reaction.new().reaction(so3, h2o))
	print(Reaction.new().reaction(n2o3, h2o))
	print(Reaction.new().reaction(n2o5, h2o))

func alkali():
	var so2 = Substance.new().from_formula("SO2")
	var so3 = Substance.new().from_formula("SO3")
	
	var naoh = Substance.new().from_formula("NaOH")
	var lioh = Substance.new().from_formula("LiOH")
	
	print(Reaction.new().reaction(so2, naoh))
	print(Reaction.new().reaction(so2, lioh))
	print(Reaction.new().reaction(so3, naoh))
	print(Reaction.new().reaction(so3, lioh))
	
func basic_oxide():
	var co2 = Substance.new().from_formula("CO2")
	var cao = Substance.new().from_formula("CaO")
	
	print(Reaction.new().reaction(co2, cao))
	
func _ready():
	#water()
	#alkali()
	basic_oxide()
