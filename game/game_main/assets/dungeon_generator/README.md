## Генерация подземелья
Тут находятся ассеты, все шаблоны комнат, спрайты и все, что связано с генерацией

dungeon_generator.gd содержит класс DungeonGenerator, который генерирует карту данжа (то есть координаты комнат)

dungeon_builder.gd содержит класс DungeonBuilder, который благодаря сгенерированным DungeonGenerator комнатам строит само подземелье, используя заготовки из папки rooms_templates
