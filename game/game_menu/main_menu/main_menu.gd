extends Control

func _on_exit_button_clicked():
	get_tree().quit()

func _on_play_button_clicked():
	#Game.main.play()
	var mode_selection_menu = preload("res://game/game_menu/mode_selection/mode_selection.tscn")
	Game.main.change_screen(mode_selection_menu.instantiate())

func _on_creators_button_button_clicked():
	var creators_menu = preload("res://game/game_menu/creators_menu/creators_menu.tscn")
	Game.main.change_screen(creators_menu.instantiate())
