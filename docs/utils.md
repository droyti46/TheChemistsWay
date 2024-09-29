# Utils

## Основная информация
Это глобальный скрипт, в котором содержатся дополнительные полезные функции, часто необходимые в разных скриптах

## Описание функций
### merge_arrays(...) -> Array
Объединяет несколько массивов в один
```gdscript
func merge_arrays(arrays: Array [Array], no_repetitions: bool = false) -> Array
```
#### Пример использования:
```gdscript
var arr1: Array = [1, 2, 3]
var arr2: Array = [4, 5, 6]
var arr3: Array = [7, 8, 9]

var merged_array: Array = Utils.merge_arrays([arr1, arr2, arr3])
print(merged_array)
```
Вывод:
```
[1, 2, 3, 4, 5, 6, 7, 9]
```
Функция имеет необязательные параметр ```no_repetitions```. Если он равен ```true```, то в новом массиве будут только уникальные элементы из всех переданных массивов.
```gdscript
var arr1: Array = [1, 2, 1]
var arr2: Array = [2, 3, 4]
```
```gdscript
var with_repetitions: Array = Utils.merge_arrays([arr1, arr2])
var no_repetitions: Array = Utils.merge_arrays([arr1, arr2], true)

print(with_repetitions)
print(no_repetitions)
```
Вывод:
```
[1, 2, 1, 2, 3, 4]
[1, 2, 3, 4]
```

### coords_is_valid(...) -> bool
Проверяет, являются ли координаты допустимыми
```gdscript
func coords_is_valid(coords: Vector2i, obstacles_coords: Array) -> bool
```
#### Описание параметров
**coords (Vector2i)** - координаты, которые надо проверить
**obstacles_coords (Array)** - массив с координатами препятствий на карте
#### Пример использования:
```gdscript
var _current_coords: Vector2i = Vector2i(1, 1)
var _direction: Vector2i = Vector2i.UP
var _obstacles_coords: Array = [Vector2i(2, 2), Vector2i(3, 4)]

func _move() -> void:
	var _new_coords: Vector2i = _current_coords + _direction
	if Utils.coords_is_valid(_new_coords, _obstacles_coords):
		_current_coords += _direction

func _ready() -> void:
	_move()
```

Если объектов на карте, на которые игрок не может наступать, много (например, враги, NPC и т.д.), то можно использовать **Utils.merge_arrays(...)**
```gdscript
Utils.coords_is_valid(_new_coords, Utils.merge_arrays(_obstacles_coords, _enemies_coords, _npc_coords))
```
