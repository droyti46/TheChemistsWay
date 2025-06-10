extends Node2D

var game_scene = preload("res://game/game.tscn")

# Переменная, нужная, чтобы кнопки в главном меню нельзя
# было нажать несколько раз
var is_button_pressed = false

func _ready():
	Game.main = self
	Input.set_custom_mouse_cursor(SpritesInfo.hand_cursor, Input.CURSOR_POINTING_HAND)

func _loading() -> void:
	$LoadingAnimation.play("loading")
	var advices_file = FileAccess.open("res://resources/loading.txt", FileAccess.READ)
	var advices: Array = advices_file.get_as_text().split("\n")
	advices.remove_at(len(advices) - 1)
	$LoadingCanvas/BG/AdviceText.set_text(advices.pick_random())

func change_screen(scene):
	$MainMenuCanvas.hide()
	if $Screen.get_child_count():
		$Screen.get_child(0).queue_free()
	$Screen.add_child(scene)

func to_main_menu(with_loading: bool = false):
	if with_loading:
		$MainMenuCanvas/MainMenu.get_node("Buttons").mouse_filter = 1
		_loading()
		await get_tree().create_timer(0.6).timeout
	$MainMenuCanvas.show()
	$Screen.get_child(0).queue_free()

func play():
	if is_button_pressed:
		return
	is_button_pressed = true
	$MainMenuCanvas/MainMenu.get_node("Buttons").mouse_filter = 2
	_loading()
	await get_tree().create_timer(0.6).timeout
	is_button_pressed = false
	change_screen(game_scene.instantiate())
