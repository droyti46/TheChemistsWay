extends Control

@onready var mini_map = $SubViewportContainer/SubViewport/MiniMap

const CountMovesText: String = "Ваши ходы: "

# Максимальное количество ходов игрока
var max_moves: int
# Текущее количество ходов игрока
var count_moves: int

func set_moves(count: int) -> void:
	max_moves = count
	count_moves = count

func reduce_moves() -> void:
	$FightAnimations.play("reduce_moves")
	count_moves -= 1
	$CountMovesLabel.set_text(CountMovesText + str(count_moves))
	
func reload_moves() -> void:
	count_moves = max_moves
	$CountMovesLabel.set_text(CountMovesText + str(count_moves))

func fight_animation() -> void:
	$FightAnimations.play("show_fight")
