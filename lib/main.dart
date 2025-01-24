import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame {
  late SpriteComponent background;
  late SpriteComponent player;
  late SpriteComponent object1;
  late SpriteComponent object2;

  @override
  Future<void> onLoad() async {
    // Carrega e adiciona o fundo
    background = SpriteComponent()
      ..sprite = await Sprite.load('teste.webp')
      ..size = size
      ..position = Vector2.zero();

    // Carrega e adiciona o jogador
    player = SpriteComponent()
      ..sprite = await Sprite.load('player.webp')
      ..position = Vector2(100, 100)
      ..size = Vector2(50, 50);

    object1 = SpriteComponent()
      ..sprite = await Sprite.load('pilar.jpg')
      ..position = Vector2(500, 400)
      ..size = Vector2(60, 700);

    object2 = SpriteComponent()
      ..sprite = await Sprite.load('pilar.jpg')
      ..position = Vector2(500, 0)
      ..size = Vector2(60, 100);

    add(background);
    add(player);
    add(object1);
    add(object2);
  }
}