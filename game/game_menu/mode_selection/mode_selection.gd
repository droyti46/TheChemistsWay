extends Control

func _on_back_button_click():
	Game.main.to_main_menu()

func _on_roguelike_mode_click():
	Game.main.play()
	#Game.main.change_screen(preload("res://game/game_menu/character_selection/character_selection.tscn").instantiate())
	#add_child(preload("res://game/game_menu/character_selection/character_selection.tscn").instantiate())
