import 'dart:async';

import 'package:blackjack/components/card_component.dart';
import 'package:blackjack/components/player_pile.dart';
import 'package:blackjack/entities/card/card.dart';
import 'package:blackjack/entities/player/blackjack_player.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class HumanPlayer implements BlackjackPlayer {
  HumanPlayer(this._pile, this._valueBox, this._stayButton, this._hitButton);

  final PlayerPile _pile;
  final TextComponent _valueBox;
  final ButtonComponent _stayButton;
  final ButtonComponent _hitButton;

  @override
  bool isStayed = false;

  @override
  Future<PlayerAction> decidePlayerAction() {
    final completer = Completer<PlayerAction>();

    _stayButton.onReleased = () => completer.complete(PlayerAction.stay);
    _hitButton.onReleased = () => completer.complete(PlayerAction.hit);

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
