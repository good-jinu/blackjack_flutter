import 'dart:ui';

import 'package:flame/components.dart';

import '../blackjack_game.dart';
import '../pile.dart';
import 'card_component.dart';

class StockPile extends PositionComponent
    with HasGameReference<BlackjackGame>
    implements Pile {
  StockPile({super.position}) : super(size: BlackjackGame.cardSize);

  /// Which cards are currently placed onto this pile. The first card in the
  /// list is at the bottom, the last card is on top.
  final List<CardComponent> _cards = [];

  //#region Pile API

  @override
  bool canMoveCard(CardComponent card, MoveMethod method) => method == MoveMethod.auto;

  @override
  bool canAcceptCard(CardComponent card) => false;

  @override
  void removeCard(CardComponent card, MoveMethod method) {
    assert(_cards.contains(card));
    final index = _cards.indexOf(card);
    _cards.removeRange(index, index + 1);
  }

  @override
  // Card cannot be removed but could have been dragged out of place.
  void returnCard(CardComponent card) => card.priority = _cards.indexOf(card);

  @override
  void acquireCard(CardComponent card) {
    assert(card.isFaceDown);
    card.pile = this;
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
  }

  //#endregion

  CardComponent get topCard {
    assert(_cards.isNotEmpty);
    return _cards.last;
  }

  //#region Rendering

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);
  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 100
    ..color = const Color(0x883F5B5D);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(BlackjackGame.cardRRect, _borderPaint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      BlackjackGame.cardWidth * 0.3,
      _circlePaint,
    );
  }

  //#endregion
}