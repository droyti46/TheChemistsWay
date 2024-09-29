# Enemies

## Основная информация
Противники, которые случайно спавняться в комнате. Могут отличаться характеристиками, передвижением, спрайтами и т.д. Все противники наследуются от базовой сцены ```characters/enemies/enemy_base.tscn```, а каждый наследник находится во внутренних папках директории ```characters/enemies```. Базовая структура наследников должна выглядеть так:
```
<EnemyName>
├── sprites
│   ├── behind
│   │    └── ...
│   │
│   ├── front
│   │    └── ...
│   │
│   └── side
│        └── ...
│
├── enemy_name.gd
└── enemy_name.tscn
```

## Перемещение
Чтобы совершить ход, требуется вызвать метод ```make_move()```
```gdscript
func make_move(map: TileMap, player_coords: Vector2i, other_enemies_coords: Array) -> Vector2i
```
Пример вызова:
```gdscript
@onready var enemy: Sprite2D = $Enemies/Enemy
@onready var room: TileMap = $Room

var player_pos: Vector2 = Vector2i(2, 3)
var other_enemies_pos: Array = [Vector2i(0, 0), Vector2i(4, 5)]

var enemy_move: Vector2 = enemy.make_move(room, player_pos, other_enemies_pos)
```

Этот метод прописывается не у базового класса, а у каждого наследника. Например, так будет выглядеть противник, которые постоянно перемещается вправо:
```gdscript
func make_move(...) -> ...:
	return Vector2i.RIGHT
```
Функция должна возвращать направление в виде вектора, в котором перемещается монстр
```gdscript
var enemy_move: Vector2i = enemy.make_move(room, player_pos, other_enemies_pos)
```

Позже переменную ```enemy_move``` можно использовать, чтобы переместить монстра по комнате при помощи метода ```step_animate()```:
```gdscript
enemy.step_animate(enemy_move)
```
Этот метод прописан у базового класса, а потому нет необходимости объявлять его для каждого наследника
