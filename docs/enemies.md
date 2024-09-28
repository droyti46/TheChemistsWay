# Enemies
Противники, которые случайно спавняться в игре.

Все противники наследуются от базовой сцены ```characters/enemies/enemy_base.tscn```

Чтобы совершить ход, требуется вызвать метод ```make_move()```
```gdscript
func make_move(map: TileMap, player_pos: Vector2, other_enemies_pos: Array) -> Vector2:
```
Пример вызова:
```gdscript
@onready var enemy: Sprite2D = $Enemies/Enemy
@onready var room: TileMap = $Room

var player_pos: Vector2 = Vector2(2, 3)
var other_enemies_pos: Array = [Vector2(0, 0), Vector2(4, 5)]

var enemy_move: Vector2 = enemy.make_move(room, player_pos, other_enemies_pos)
```

Этот метод прописывается не у базового класса, а у каждого наследника. Например, так будет выглядеть противник, которые постоянно перемещается вправо:
```gdscript
func make_move(...) -> ...:
	return Vector2.RIGHT
```
Функция должна возвращать направление в виде вектора, в котором перемещается монстр
```gdscript
var enemy_move: Vector2 = enemy.make_move(room, player_pos, other_enemies_pos)
```

Позже переменную ```enemy_move``` можно использовать, чтобы переместить монстра по комнате при помощи метода ```step()```:
```gdscript
enemy.step(enemy_move)
```
