import 'package:blackjack/entities/card/rank.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../blackjack_game.dart';

@immutable
class RankSprite {
  factory RankSprite.fromRank(Rank value) {
    return _singletons[value.value - 1];
  }

  RankSprite._(
    this.rank,
    double x1,
    double y1,
    double x2,
    double y2,
    double w,
    double h,
  )   : redSprite = blackjackSprite(x1, y1, w, h),
        blackSprite = blackjackSprite(x2, y2, w, h);

  final Rank rank;
  final Sprite redSprite;
  final Sprite blackSprite;

  int get value => rank.value;
  String get label => rank.label;

  static final List<RankSprite> _singletons = [
    RankSprite._(Rank.ace, 335, 164, 789, 161, 120, 129),
    RankSprite._(Rank.two, 20, 19, 15, 322, 83, 125),
    RankSprite._(Rank.three, 122, 19, 117, 322, 80, 127),
    RankSprite._(Rank.four, 213, 12, 208, 315, 93, 132),
    RankSprite._(Rank.five, 314, 21, 309, 324, 85, 125),
    RankSprite._(Rank.six, 419, 17, 414, 320, 84, 129),
    RankSprite._(Rank.seven, 509, 21, 505, 324, 92, 128),
    RankSprite._(Rank.eight, 612, 19, 607, 322, 78, 127),
    RankSprite._(Rank.nine, 709, 19, 704, 322, 84, 130),
    RankSprite._(Rank.ten, 810, 20, 805, 322, 137, 127),
    RankSprite._(Rank.jack, 15, 170, 469, 167, 56, 126),
    RankSprite._(Rank.queen, 92, 168, 547, 165, 132, 128),
    RankSprite._(Rank.king, 243, 170, 696, 167, 92, 123),
  ];
}