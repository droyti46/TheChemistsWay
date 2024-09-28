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
