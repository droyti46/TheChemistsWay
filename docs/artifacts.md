## Артефакты

Представляют из себя улучшения персонажа. Все скрипты артефактов лежат в подпапках директории ```artifacts/scripts``` \

Чтобы описать действие артефакта, необходимо в скрипте объявить функцию activate(...). Например, так можно выглядеть простейший артефакт для улучшения атаки персонажа на 15%
```gdscript
func activate(game) -> void:
	var player = game.get_current_room().player
	var new_attack = player.get_attack() + player.get_attack() * 0.15
	player.set_attack(new_attack)
```
