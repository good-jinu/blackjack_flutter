import 'dart:async';

import 'package:blackjack/blackjack_game.dart';
import 'package:blackjack/components/card_component.dart';
import 'package:blackjack/components/player_pile.dart';
import 'package:blackjack/entities/card/card.dart';
import 'package:blackjack/entities/player/blackjack_player.dart';
import 'package:flame/components.dart';

class ComputerPlayer implements BlackjackPlayer {
  ComputerPlayer(this._pile, this._valueBox, this._oponent);

  final PlayerPile _pile;
  final TextComponent _valueBox;
  final BlackjackPlayer _oponent;

  @override
  bool isStayed = false;

  @override
  Future<PlayerAction> decidePlayerAction() {
    final completer = Completer<PlayerAction>();

    if ((cardTotalValue > BlackjackGame.blackjackValue - 5 &&
            cardTotalValue >= _oponent.cardTotalValue) ||
        _oponent.cardTotalValue > BlackjackGame.blackjackValue ||
        (_oponent.isStayed && cardTotalValue >= _oponent.cardTotalValue)) {
      completer.complete(PlayerAction.stay);
    } else {
      completer.complete(PlayerAction.hit);
    }

    return completer.future;
  }

  @override
  void acquireCard(Card card) {
    assert(card is CardComponent);
    _pile.acquireCard(card as CardComponent);
    _valueBox.text = cardTotalValue.toString();
  }

  @override
  int get cardTotalValue => _pile.sumOfValue;

  @override
  List<Card> get cards => _pile.cardList;
}
