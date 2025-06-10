extends Node2D

const ACCEPTABLE_SUBSTANCES: Array[String] = [
	"H",
	"Li",
	"Be",
	"B",
	"C",
	"N",
	"O",
	"F",
	"Al",
	"Na",
	"Mg",
	"P",
	"S",
	"K",
	"Ca",
	"Br",
	"Cs",
	"Ba",
	
	"Na2O",
	"K2O",
	"CO2",
	"FeO",
	"CaO",
	"CuO",
	"FeO",
	"CrO",
	"SO2",
	"SO3",
	"P2O5",
	"CrO3",
	"Mn2O7",
	
	"LiOH",
	"NaOH",
	"KOH",
	"RbOH",
	"CsOH",
	"Ca(OH)2",
	"Sr(OH)2",
	"Ba(OH)2",
	"Mg(OH)2",
	"Fe(OH)2",
	"Zn(OH)2",
	"Fe(OH)3",
	
	"NaCl",
	"Na2SO4",
	"CaSO4",
	"CaCl2",
	"K2SO4",
	"K3PO4",
	"NaNO3",
	"AlPO4",
	"Al2SO4",
	"Na3PO4",
	"CaCO3",
	"MgS",
	"MgSO4",
	
	"H2SO4",
	"HNO3",
	"HCl",
	"H3PO4",
	"H2CO3",
	"H2SO3",
	"HNO2",
	"H2S",
	"H2SiO3"
]

var chest_object = preload("res://game/game_floor/dungeon_generator/rooms_templates/chest/chest_object.tscn")

var is_open = false
# var substances_in_chest = {}
var objects_in_chest = []

func _ready():
	#var count_substances = randi_range(1, 3)
	#for _i in range(count_substances):
	var count = randi_range(2, 5)
	var substance_formula = ACCEPTABLE_SUBSTANCES.pick_random()
	var substance = Substance.new().from_formula(substance_formula)
	var obj_scene = chest_object.instantiate()
	obj_scene.set_substance(substance, count)
	obj_scene.hide()
	add_child(obj_scene)
	objects_in_chest.append(obj_scene)

func _on_player_handler_body_entered(body):
	if is_open:
		return
	
	$OpenAudio.play()
	$AnimatedSprite.play("open")
	is_open = true
	
	var tweens = {}
	for obj in objects_in_chest:
		obj.show()
		var tween = create_tween()
		randomize()
		#var new_position = obj.position + Vector2(randi_range(-50, 50), -20)
		var new_position = obj.position + Vector2(0, -20)
		tween.tween_property(
			obj,
			"position",
			new_position,
			0.4
		).set_trans(Tween.TRANS_SINE)
		tween.chain().tween_property(
			obj,
			"position",
			new_position + Vector2(0, 50),
			0.4
		).set_trans(Tween.TRANS_QUART)

func show_anim() -> void:
	$DropAudio.play()
	$ShowAnimation.play("show")
	
func prepare_anim() -> void:
	$AnimatedSprite.modulate = "#ffffff00"
