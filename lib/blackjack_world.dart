import 'dart:async';
import 'dart:math';

import 'package:blackjack/components/player_pile.dart';
import 'package:blackjack/components/rank_sprite.dart';
import 'package:blackjack/entities/card/card.dart';
import 'package:blackjack/entities/card/rank.dart';
import 'package:blackjack/entities/card/suit.dart';
import 'package:blackjack/entities/player/blackjack_player.dart';
import 'package:blackjack/entities/player/computer_player.dart';
import 'package:blackjack/entities/player/human_player.dart';
import 'package:blackjack/pile.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'blackjack_game.dart';
import 'components/card_component.dart';
import 'components/flat_button.dart';
import 'components/stock_pile.dart';

class BlackjackWorld extends World with HasGameReference<BlackjackGame> {
  final cardGap = BlackjackGame.cardGap;
  final topGap = BlackjackGame.topGap;
  final cardSpaceWidth = BlackjackGame.cardSpaceWidth;
  final cardSpaceHeight = BlackjackGame.cardSpaceHeight;
  final cardHeight = BlackjackGame.cardHeight;
  final blackjackValue = BlackjackGame.blackjackValue;

  final stock = StockPile(position: Vector2(0.0, 0.0));
  final villianPile = PlayerPile(position: Vector2(0.0, 0.0));
  final heroPile = PlayerPile(position: Vector2(0.0, 0.0));
  final List<CardComponent> cards = [];
  late Vector2 playAreaSize;
  late ComputerPlayer villian;
  late HumanPlayer hero;

  @override
  Future<void> onLoad() async {
    await Flame.images.load('blackjack-sprites.png');

    stock.position = Vector2(cardGap, topGap);
    villianPile.position =
        Vector2(cardSpaceWidth * 3 + cardGap, cardSpaceHeight + topGap);
    heroPile.position =
        Vector2(cardSpaceWidth * 3 + cardGap, 4 * cardSpaceHeight + topGap);

    // Add a Base Card to the Stock Pile, above the pile and below other cards.
    final baseCard = CardComponent(Rank.ace, Suit.club, isBaseCard: true);
    baseCard.position = stock.position;
    baseCard.priority = -1;
    baseCard.pile = stock;
    stock.priority = -2;

    for (final rank in Rank.values) {
      for (final suit in Suit.values) {
        final card = CardComponent(rank, suit);
        card.position = stock.position;
        cards.add(card);
      }
    }

    add(stock);
    add(villianPile);
    add(heroPile);
    addAll(cards);
    add(baseCard);

    playAreaSize =
        Vector2(7 * cardSpaceWidth + cardGap, 6 * cardSpaceHeight + topGap);
    final gameMidX = playAreaSize.x / 2;
    final gameMidY = playAreaSize.y / 2;

    final heroValueBox =
        TextComponent(position: heroPile.position + Vector2(cardSpaceWidth, 0));
    final villianValueBox = TextComponent(
        position: villianPile.position + Vector2(cardSpaceWidth, 0));

    final stayButton = FlatButton('Stay',
        size: Vector2(gameMidX - cardGap * 2, cardHeight),
        position: Vector2(cardGap, playAreaSize.y - cardSpaceHeight),
        anchor: Anchor.topLeft);
    final hitButton = FlatButton('Hit',
        size: Vector2(gameMidX - cardGap * 2, cardHeight),
        position: Vector2(gameMidX + cardGap, playAreaSize.y - cardSpaceHeight),
        anchor: Anchor.topLeft);

    add(stayButton);
    add(hitButton);

    hero = HumanPlayer(heroPile, heroValueBox, stayButton, hitButton);

    villian = ComputerPlayer(villianPile, villianValueBox, hero);

    final camera = game.camera;
    camera.viewfinder.visibleGameSize = playAreaSize;
    camera.viewfinder.position = Vector2(gameMidX, gameMidY);
    camera.viewfinder.anchor = Anchor.center;

    deal();
  }

  deal() {
    assert(cards.length == 52, 'There are ${cards.length} cards: should be 52');

    if (game.action != Action.sameDeal) {
      // New deal: change the Random Number Generator's seed.
      game.seed = Random().nextInt(BlackjackGame.maxInt);
      if (game.action == Action.changeDraw) {
        game.blackjackDraw = (game.blackjackDraw == 3) ? 1 : 3;
      }
    }
    // For the "Same deal" option, re-use the previous seed, else use a new one.
    cards.shuffle(Random(game.seed));

    // Each card dealt must be seen to come from the top of the deck!
    var dealPriority = 1;
    for (final card in cards) {
      card.priority = dealPriority++;
    }

    // Change priority as cards take off: so later cards fly above earlier ones.
    var cardToDeal = cards.length - 1;
    var nMovingCards = 0;
    for (var i = 0; i < 2; i++) {
      final destination = i == 0 ? villianPile : heroPile;
      for (var j = 0; j < 2; j++) {
        final card = cards[cardToDeal--];
        card.flip();
        card.doMove(destination.position,
            speed: 15.0,
            start: nMovingCards * 0.15,
            startPriority: 100 + nMovingCards, onComplete: () async {
          destination.acquireCard(card);
          nMovingCards--;
          if (nMovingCards == 0) {
            print(await villian.decidePlayerAction());
          }
        });
        nMovingCards++;
      }
    }

    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
  }

  void checkWin() {
    if ((heroPile.sumOfValue > villianPile.sumOfValue &&
            heroPile.sumOfValue <= blackjackValue) ||
        villianPile.sumOfValue > blackjackValue) {
      print('hero won');
    } else {
      print('villian won');
    }
  }

  void letsCelebrate({int phase = 1}) {
    // Deal won: bring all cards to the middle of the screen (phase 1)
    // then scatter them to points just outside the screen (phase 2).
    //
    // First get the device's screen-size in game co-ordinates, then get the
    // top-left of the off-screen area that will accept the scattered cards.
    // Note: The play area is anchored at TopCenter, so topLeft.y is fixed.

    final cameraZoom = game.camera.viewfinder.zoom;
    final zoomedScreen = game.size / cameraZoom;
    final screenCenter = (playAreaSize - BlackjackGame.cardSize) / 2;
    final topLeft = Vector2(
      (playAreaSize.x - zoomedScreen.x) / 2 - BlackjackGame.cardWidth,
      -BlackjackGame.cardHeight,
    );
    final nCards = cards.length;
    final offscreenHeight = zoomedScreen.y + BlackjackGame.cardSize.y;
    final offscreenWidth = zoomedScreen.x + BlackjackGame.cardSize.x;
    final spacing = 2.0 * (offscreenHeight + offscreenWidth) / nCards;

    // Starting points, directions and lengths of offscreen rect's sides.
    final corner = [
      Vector2(0.0, 0.0),
      Vector2(0.0, offscreenHeight),
      Vector2(offscreenWidth, offscreenHeight),
      Vector2(offscreenWidth, 0.0),
    ];
    final direction = [
      Vector2(0.0, 1.0),
      Vector2(1.0, 0.0),
      Vector2(0.0, -1.0),
      Vector2(-1.0, 0.0),
    ];
    final length = [
      offscreenHeight,
      offscreenWidth,
      offscreenHeight,
      offscreenWidth,
    ];

    var side = 0;
    var cardsToMove = nCards;
    var offScreenPosition = corner[side] + topLeft;
    var space = length[side];
    var cardNum = 0;

    while (cardNum < nCards) {
      final cardIndex = phase == 1 ? cardNum : nCards - cardNum - 1;
      final card = cards[cardIndex];
      card.priority = cardIndex + 1;
      if (card.isFaceDown) {
        card.flip();
      }
      // Start cards a short time apart to give a riffle effect.
      final delay = phase == 1 ? cardNum * 0.02 : 0.5 + cardNum * 0.04;
      final destination = (phase == 1) ? screenCenter : offScreenPosition;
      card.doMove(
        destination,
        speed: (phase == 1) ? 15.0 : 5.0,
        start: delay,
        onComplete: () {
          cardsToMove--;
          if (cardsToMove == 0) {
            if (phase == 1) {
              letsCelebrate(phase: 2);
            } else {
              // Restart with a new deal after winning or pressing "Have fun".
              game.action = Action.newDeal;
              game.world = BlackjackWorld();
            }
          }
        },
      );
      cardNum++;
      if (phase == 1) {
        continue;
      }

      // Phase 2: next card goes to same side with full spacing, if possible.
      offScreenPosition = offScreenPosition + direction[side] * spacing;
      space = space - spacing;
      if ((space < 0.0) && (side < 3)) {
        // Out of space: change to the next side and use excess spacing there.
        side++;
        offScreenPosition = corner[side] + topLeft - direction[side] * space;
        space = length[side] + space;
      }
    }
  }
}
