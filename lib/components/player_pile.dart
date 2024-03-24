import 'package:flame/components.dart';

import '../blackjack_game.dart';
import '../pile.dart';
import 'card.dart';

class PlayerPile extends PositionComponent
    with HasGameReference<BlackjackGame>
    implements Pile {
  PlayerPile({super.position}) : super(size: BlackjackGame.cardSize);

  /// Which cards are currently placed onto this pile. The first card in the
  /// list is at the bottom, the last card is on top.
  final List<Card> _cards = [];
  final Vector2 _fanOffset = Vector2(BlackjackGame.cardWidth * 0.2, 0);

  //#region Pile API

  @override
  bool canMoveCard(Card card, MoveMethod method) => false;

  @override
  bool canAcceptCard(Card card) => false;

  @override
  void removeCard(Card card, MoveMethod method) =>
      throw StateError('cannot remove cards');

  @override
  // Card cannot be removed but could have been dragged out of place.
  void returnCard(Card card) => card.priority = _cards.indexOf(card);

  @override
  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.pile = this;
    card.position = position + _fanOffset * _cards.length.toDouble();
    card.priority = _cards.length;
    _cards.add(card);
  }

  //#endregion

  /// total score of this pile
  int get sumOfValue {
    var aceCnt = 0;
    var sum = 0;

    for (final card in _cards) {
      if (card.rank.value >= 10) {
        sum += 10;
      } else if (card.rank.value == 1) {
        sum += 11;
        aceCnt++;
      } else {
        sum += card.rank.value;
      }
    }

    while (sum > BlackjackGame.blackjackValue && aceCnt > 0) {
      sum -= 10;
      aceCnt--;
    }

    return sum;
  }
}
