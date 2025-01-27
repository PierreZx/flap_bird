import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with TapDetector {
  double gravity = 300;
  double velocityY = 0;
  double groundLevel = 780;
  double objectSpeed = 200;
  Random random = Random();

  late SpriteComponent background;
  late SpriteComponent player;
  late SpriteComponent object1;
  late SpriteComponent object2;

  @override
  Future<void> onLoad() async {

    background = SpriteComponent()
      ..sprite = await Sprite.load('Lukewarm_Ocean.webp')
      ..size = size
      ..position = Vector2.zero();

    player = SpriteComponent()
      ..sprite = await Sprite.load('player.png')
      ..position = Vector2(100, 220)
      ..size = Vector2(100, 100);

    object1 = SpriteComponent()
      ..sprite = await Sprite.load('pilar.png')
      ..position = Vector2(500, 400)
      ..size = Vector2(60, 700);

    object2 = SpriteComponent()
      ..sprite = await Sprite.load('pilar.png')
      ..position = Vector2(800, -500)
      ..size = Vector2(60, 700);

    add(background);
    add(player);
    add(object1);
    add(object2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocityY += gravity * dt;
    player.position.y += velocityY * dt;

    if (player.position.y >= groundLevel) {
      player.position.y = groundLevel;
      velocityY = 0;
    }

    object1.position.x -= objectSpeed * dt;

    if (object1.position.x + object1.size.x < 0) {
      object1.position.x = size.x;
      object1.position.y = random.nextDouble() * (groundLevel - 200);
    }

    object2.position.x -= objectSpeed * dt;

    if (object2.position.x + object2.size.x < 0) {
      object2.position.x = size.x + 300;
      object2.position.y = random.nextDouble() * (-200);
    }
  }

  @override
  void onTap() {
    velocityY = -200;
  }
}
