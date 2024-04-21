import 'package:blackjack/entities/card/suit.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import '../blackjack_game.dart';

@immutable
class SuitSprite {
  factory SuitSprite.fromSuit(Suit index) {
    return _singletons[index.value];
  }

  SuitSprite._(this.suit, double x, double y, double w, double h)
      : sprite = blackjackSprite(x, y, w, h);

  final Suit suit;
  final Sprite sprite;

  int get value => suit.value;
  String get label => suit.label;

  static final List<SuitSprite> _singletons = [
    SuitSprite._(Suit.heart, 1176, 17, 172, 183),
    SuitSprite._(Suit.diamond, 973, 14, 177, 182),
    SuitSprite._(Suit.club, 974, 226, 184, 172),
    SuitSprite._(Suit.spade, 1178, 220, 176, 182),
  ];

  /// Hearts and Diamonds are red, while Clubs and Spades are black.
  bool get isRed => value <= 1;
  bool get isBlack => value >= 2;
}