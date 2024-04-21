import 'dart:math';
import 'dart:ui';

import 'package:blackjack/entities/card/card.dart';
import 'package:blackjack/entities/card/rank.dart';
import 'package:blackjack/entities/card/suit.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../blackjack_game.dart';
import '../blackjack_world.dart';
import '../pile.dart';
import 'rank_sprite.dart';
import 'suit_sprite.dart';

class CardComponent extends PositionComponent
    with HasWorldReference<BlackjackWorld>
    implements Card {
  CardComponent(Rank rank, Suit suit, {this.isBaseCard = false})
      : rankSprite = RankSprite.fromRank(rank),
        suitSprite = SuitSprite.fromSuit(suit),
        super(
          size: BlackjackGame.cardSize,
        );

  final RankSprite rankSprite;
  final SuitSprite suitSprite;
  Pile? _pile;

  @override
  Rank get rank => rankSprite.rank;
  @override
  Suit get suit => suitSprite.suit;

  Pile? get pile => _pile;

  set pile(Pile? value) {
    if (_pile != null) {
      try {
        _pile!.removeCard(this, MoveMethod.auto);
      } catch (e) {
        // pile has no this card
      }
    }
    _pile = value;
  }

  // A Base Card is rendered in outline only and is NOT playable. It can be
  // added to the base of a Pile (e.g. the Stock Pile) to allow it to handle
  // taps and short drags (on an empty Pile) with the same behavior and
  // tolerances as for regular cards (see BlackjackGame.dragTolerance) and using
  // the same event-handling code, but with different handleTapUp() methods.
  final bool isBaseCard;

  bool _faceUp = false;
  bool _isAnimatedFlip = false;
  bool _isFaceUpView = false;

  final List<CardComponent> attachedCards = [];

  bool get isFaceUp => _faceUp;
  bool get isFaceDown => !_faceUp;
  void flip() {
    if (_isAnimatedFlip) {
      // Let the animation determine the FaceUp/FaceDown state.
      _faceUp = _isFaceUpView;
    } else {
      // No animation: flip and render the card immediately.
      _faceUp = !_faceUp;
      _isFaceUpView = _faceUp;
    }
  }

  @override
  String toString() => rankSprite.label + suitSprite.label; // e.g. "Q♠" or "10♦"

  //#region Rendering

  @override
  void render(Canvas canvas) {
    if (isBaseCard) {
      _renderBaseCard(canvas);
      return;
    }
    if (_isFaceUpView) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  static final Paint backBackgroundPaint = Paint()
    ..color = const Color(0xff380c02);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color(0xffdbaf58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color(0x5CEF971B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRRect = RRect.fromRectAndRadius(
    BlackjackGame.cardSize.toRect(),
    const Radius.circular(BlackjackGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
  static final Sprite flameSprite = blackjackSprite(1367, 6, 357, 501);

  void _renderBack(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
    flameSprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }

  void _renderBaseCard(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBorderPaint1);
  }

  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color(0xff000000);
  static final Paint redBorderPaint = Paint()
    ..color = const Color(0xffece8a3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint blackBorderPaint = Paint()
    ..color = const Color(0xff7ab2e8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final blueFilter = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x880d8bff),
      BlendMode.srcATop,
    );
  static final Sprite redJack = blackjackSprite(81, 565, 562, 488);
  static final Sprite redQueen = blackjackSprite(717, 541, 486, 515);
  static final Sprite redKing = blackjackSprite(1305, 532, 407, 549);
  static final Sprite blackJack = blackjackSprite(81, 565, 562, 488)
    ..paint = blueFilter;
  static final Sprite blackQueen = blackjackSprite(717, 541, 486, 515)
    ..paint = blueFilter;
  static final Sprite blackKing = blackjackSprite(1305, 532, 407, 549)
    ..paint = blueFilter;

  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      suitSprite.isRed ? redBorderPaint : blackBorderPaint,
    );

    final rankSpriteFinal = suitSprite.isBlack ? rankSprite.blackSprite : rankSprite.redSprite;
    final suitSpriteFinal = suitSprite.sprite;
    _drawSprite(canvas, rankSpriteFinal, 0.1, 0.08);
    _drawSprite(canvas, suitSpriteFinal, 0.1, 0.18, scale: 0.5);
    _drawSprite(canvas, rankSpriteFinal, 0.1, 0.08, rotate: true);
    _drawSprite(canvas, suitSpriteFinal, 0.1, 0.18, scale: 0.5, rotate: true);
    switch (rankSprite.value) {
      case 1:
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.5, scale: 2.5);
        break;
      case 2:
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.25);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.25, rotate: true);
        break;
      case 3:
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.5);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.2, rotate: true);
        break;
      case 4:
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.25);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.25);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.25, rotate: true);
        break;
      case 5:
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.25);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.25);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.25, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.5);
        break;
      case 6:
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.25);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.25);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.5);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.5);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.25, rotate: true);
        break;
      case 7:
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.35);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.5);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.5);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2, rotate: true);
        break;
      case 8:
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.35);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.5);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.5);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.35, rotate: true);
        break;
      case 9:
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.3);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.4);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.4);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.4, rotate: true);
        break;
      case 10:
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.3);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.4);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.4);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.5, 0.3, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSpriteFinal, 0.7, 0.4, rotate: true);
        break;
      case 11:
        _drawSprite(canvas, suitSprite.isRed ? redJack : blackJack, 0.5, 0.5);
        break;
      case 12:
        _drawSprite(canvas, suitSprite.isRed ? redQueen : blackQueen, 0.5, 0.5);
        break;
      case 13:
        _drawSprite(canvas, suitSprite.isRed ? redKing : blackKing, 0.5, 0.5);
        break;
    }
  }

  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    if (rotate) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(pi);
      canvas.translate(-size.x / 2, -size.y / 2);
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }

  //#endregion

  //#region Effects

  void doMove(
    Vector2 to, {
    double speed = 10.0,
    double start = 0.0,
    int startPriority = 100,
    Curve curve = Curves.easeOutQuad,
    VoidCallback? onComplete,
  }) {
    assert(speed > 0.0, 'Speed must be > 0 widths per second');
    final dt = (to - position).length / (speed * size.x);
    assert(dt > 0, 'Distance to move must be > 0');
    add(
      CardMoveEffect(
        to,
        EffectController(duration: dt, startDelay: start, curve: curve),
        transitPriority: startPriority,
        onComplete: () {
          onComplete?.call();
        },
      ),
    );
  }

  void doMoveAndFlip(
    Vector2 to, {
    double speed = 10.0,
    double start = 0.0,
    Curve curve = Curves.easeOutQuad,
    VoidCallback? whenDone,
  }) {
    assert(speed > 0.0, 'Speed must be > 0 widths per second');
    final dt = (to - position).length / (speed * size.x);
    assert(dt > 0, 'Distance to move must be > 0');
    priority = 100;
    add(
      MoveToEffect(
        to,
        EffectController(duration: dt, startDelay: start, curve: curve),
        onComplete: () {
          turnFaceUp(
            onComplete: whenDone,
          );
        },
      ),
    );
  }

  void turnFaceUp({
    double time = 0.3,
    double start = 0.0,
    VoidCallback? onComplete,
  }) {
    assert(!_isFaceUpView, 'Card must be face-down before turning face-up.');
    assert(time > 0.0, 'Time to turn card over must be > 0');
    assert(start >= 0.0, 'Start tim must be >= 0');
    _isAnimatedFlip = true;
    anchor = Anchor.topCenter;
    position += Vector2(width / 2, 0);
    priority = 100;
    add(
      ScaleEffect.to(
        Vector2(scale.x / 100, scale.y),
        EffectController(
          startDelay: start,
          curve: Curves.easeOutSine,
          duration: time / 2,
          onMax: () {
            _isFaceUpView = true;
          },
          reverseDuration: time / 2,
          onMin: () {
            _isAnimatedFlip = false;
            _faceUp = true;
            anchor = Anchor.topLeft;
            position -= Vector2(width / 2, 0);
          },
        ),
        onComplete: () {
          onComplete?.call();
        },
      ),
    );
  }

  //#endregion
}

class CardMoveEffect extends MoveToEffect {
  CardMoveEffect(
    super.destination,
    super.controller, {
    super.onComplete,
    this.transitPriority = 100,
  });

  final int transitPriority;

  @override
  void onStart() {
    super.onStart(); // Flame connects MoveToEffect to EffectController.
    parent?.priority = transitPriority;
  }
}
