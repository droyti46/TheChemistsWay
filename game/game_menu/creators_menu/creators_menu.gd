extends Control

func _on_back_button_click():
	Game.main.to_main_menu()

func _on_animation_animation_finished(anim_name):
	Game.main.to_main_menu()
