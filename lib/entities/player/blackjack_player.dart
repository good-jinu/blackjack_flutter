import 'package:blackjack/entities/card/card.dart';

enum PlayerAction { stay, hit }

abstract class BlackjackPlayer {
  /// when player decided to stay then [isStayed] would be true
  bool isStayed = false;

  /// player decides which action to play. returns [PlayerAction] to play.
  Future<PlayerAction> decidePlayerAction();

  /// player takes card.
  void acquireCard(Card card);

  /// returns total sum of card value.
  int get cardTotalValue;

  /// returns card list
  List<Card> get cards;
}
