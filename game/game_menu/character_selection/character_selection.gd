extends Control

const CHARACTERS = [
	"tony", "caroline", "brian", "amelia"
]

func _ready():
	for character in CHARACTERS:
		var char_btn = preload("res://game/game_menu/character_selection/assets/character_button.tscn").instantiate()
		char_btn.init(character)
		$CharactersButtonsContainer.add_child(char_btn)

func _on_back_button_click():
	queue_free()
