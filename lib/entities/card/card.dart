import 'package:blackjack/entities/card/rank.dart';
import 'package:blackjack/entities/card/suit.dart';

abstract class Card {
  Rank get rank;
  Suit get suit;
}
