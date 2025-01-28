import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasCollisionDetection, TapDetector {
  double gravity = 300;
  double velocityY = 0;
  double groundLevel = 780;
  double pipeSpeed = 200;
  double timeSinceLastPipe = 0;

  int score = 0;
  late TextComponent scoreText;
  late TextComponent gameOverText;
  bool isGameOver = false;

  GameState gameState = GameState.menu;

  late SpriteComponent background;
  late Player player;

  @override
  Future<void> onLoad() async {

    background = SpriteComponent()
      ..sprite = await Sprite.load('Lukewarm_Ocean.webp')
      ..size = size
      ..position = Vector2.zero();


    player = Player()
      ..position = Vector2(100, 220)
      ..size = Vector2(90, 90);


    scoreText = TextComponent(
      text: '$score',
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );

    gameOverText = TextComponent(
      text: 'GAME OVER',
      position: Vector2(size.x / 2 - 120, size.y / 2 - 40),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 48),
      ),
    );


    add(background);
    add(player);
    add(scoreText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != GameState.playing) return;

    velocityY += gravity * dt;
    player.position.y += velocityY * dt;

    if (player.position.y >= groundLevel) {
      gameOver();
    }

    timeSinceLastPipe += dt;
    if (timeSinceLastPipe > 2 && !isGameOver) {
      timeSinceLastPipe = 0;


      add(PipePair(
        position: Vector2(size.x, 0),
        pipeSpeed: pipeSpeed,
        screenSize: size,
        onPass: increaseScore, 
      ));
    }
  }

  @override
  void onTap() {
    if (gameState == GameState.menu) {
      startGame();
    } else if (gameState == GameState.playing && !isGameOver) {
      velocityY = -200;
    } else if (gameState == GameState.gameOver) {
      restartGame();
    }
  }

  void startGame() {
    gameState = GameState.playing;
    score = 0;
    velocityY = -200;
    player.position = Vector2(100, 220);
    children.whereType<PipePair>().forEach((pipe) => pipe.removeFromParent());
    isGameOver = false;
    gameOverText.removeFromParent();
  }

  void gameOver() {
    gameState = GameState.gameOver;
    isGameOver = true;

    add(gameOverText);


    children.whereType<PipePair>().forEach((pipe) => pipe.stopMoving());
  }

  void restartGame() {
    startGame();
  }

  void increaseScore() {
    score++;
    scoreText.text = '$score';
  }
}

class Player extends SpriteComponent with CollisionCallbacks {
  double velocityY = 0; // Defina a variável velocityY aqui

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
    add(RectangleHitbox()..size = Vector2(1, 1));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Controlando a rotação com base na velocidade Y (direção do movimento vertical)
    double rotationAngle = 30;

    if (velocityY < 0) {
      // Jogador está subindo (pulo)
      rotationAngle = max(-pi / 4, velocityY / -500); // Limita a rotação para não virar muito para cima
    } else if (velocityY > 0) {
      // Jogador está descendo (caindo)
      rotationAngle = min(pi / 4, velocityY / 500); // Limita a rotação para não virar muito para baixo
    }

    // Aplica a rotação calculada ao sprite (em radianos)
    angle = rotationAngle; // Alterado de 'rotation' para 'angle'
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is SpriteComponent) {
      final parentGame = findParent<MyGame>();
      parentGame?.gameOver();
    }
    super.onCollision(intersectionPoints, other);
  }
}


class PipePair extends PositionComponent {
  final double pipeSpeed;
  final Vector2 screenSize;
  final double spacing = 200;
  final Random random = Random();
  final Function onPass;

  bool passedPlayer = false;
  bool _isMoving = true;

  late SpriteComponent topPipe;
  late SpriteComponent bottomPipe;

  PipePair({
    required Vector2 position,
    required this.pipeSpeed,
    required this.screenSize,
    required this.onPass,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    double topPipeHeight = random.nextDouble() * (screenSize.y - spacing - 200);

    topPipe = SpriteComponent()
      ..sprite = await Sprite.load('pilar.png')
      ..size = Vector2(60, 700)
      ..position = Vector2(0, topPipeHeight - 700)
      ..add(RectangleHitbox()..size = Vector2(40, 500));

    bottomPipe = SpriteComponent()
      ..sprite = await Sprite.load('pilar.png')
      ..size = Vector2(60, 700)
      ..position = Vector2(0, topPipeHeight + spacing)
      ..add(RectangleHitbox()..size = Vector2(40, 500));

    add(topPipe);
    add(bottomPipe);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isMoving) {
      position.x -= pipeSpeed * dt;

      if (!passedPlayer && position.x + topPipe.size.x < 100) {
        passedPlayer = true;
        onPass();
      }

      if (position.x + topPipe.size.x < 0) {
        removeFromParent();
      }
    }
  }

  void stopMoving() {
    _isMoving = false;
  }
}

enum GameState { menu, playing, gameOver }
