extends Node

"""
Глобальные константы, относящиеся к графике, тайлам и т.п.
"""

"""Константы, относящиеся ко всем спрайтам"""
# Увеличение размеров всех спрайтов в долях
const SPRITES_SCALE: int = 4

"""Константы, относящиеся к подземельям"""
# Размер тайлов карты в пикселях
const TILE_SIZE: int = 32
# Размер тайлов с учётом увеличения
const TILE_SIZE_FULL: int = TILE_SIZE * SPRITES_SCALE
# Количество тайлов в комнате по ширине
const ROOM_COUNT_TILES_X: int = 11
# Количество тайлов в комнате по высоте
const ROOM_COUNT_TILES_Y: int = 7
# Размер комнаты по ширине в пикселях
const ROOM_SIZE_X: int = TILE_SIZE_FULL * ROOM_COUNT_TILES_X
# Размер комнаты по высоте в пикселях
const ROOM_SIZE_Y: int = TILE_SIZE_FULL * ROOM_COUNT_TILES_Y
# Слой TileMap комнаты, на котором расположены препятсвия 
const WALLS_TILEMAP_LAYER: int = 0
# СлоЙ комнаты, на котором расположена трава
const GRASS_TILEMAP_LAYER: int = 1
# Слой комнаты, на котором расположены препятствия
const OBSTACLES_TILEMAP_LAYER: int = 2
# Слой комнаты, на котором расположен индикатор атакованного тайла
const ATTACKED_TILEMAP_LAYER: int = 3

"""Константы, относящиеся к веществам и элементам"""
const BASE_COLOR = "#d3c188"
const ACID_COLOR = "#c46a85"
const SALT_COLOR = "#d38f67"
const NONMETAL_COLOR = "#7760c8"
const METAL_COLOR = "#74a8ca"
const OXIDE_COLOR = "#cad9a9"

const COLOR_BY_RU_NAME = {
	"Металл": METAL_COLOR,
	"Неметалл": NONMETAL_COLOR,
	"Оксид": OXIDE_COLOR,
	"Основание": BASE_COLOR,
	"Соль": SALT_COLOR,
	"Кислота": ACID_COLOR
}

"""Картинки курсоров"""
var hand_cursor = load("res://resources/sprites/cursor/cursor_hand.png")
var aim_cursor = load("res://resources/sprites/cursor/cursor_aim.png")
