# Utils

## Основная информация
Это глобальный скрипт, в котором содержатся дополнительные полезные функции, часто необходимые в разных скриптах

## Описание функций
### merge_arrays()
Объединяет несколько массивов в один
```gdscript
func merge_arrays(arrays: Array [Array], no_repetitions: bool = false) -> Array
```
Пример использования:
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
