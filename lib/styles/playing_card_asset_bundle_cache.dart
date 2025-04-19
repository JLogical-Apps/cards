import 'package:card_game/card_game.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:vector_graphics/vector_graphics.dart';

class PlayingCardAssetBundleCache {
  static final Map<SuitedCard, AssetBytesLoader> _loaderByCard = {};
  static final Map<CardBack, AssetBytesLoader> _loaderByCardBack = {};
  static final Map<CardSuit, AssetBytesLoader> _loaderBySuit = {};

  PlayingCardAssetBundleCache._();

  static Future<void> preloadAssets() async {
    await Future.wait(SuitedCard.deck.map((card) async {
      final loader = AssetBytesLoader('assets/faces/${_getSuitName(card.suit)}-${_getValueName(card.value)}.svg.vec');
      _loaderByCard[card] = loader;
      await loader.loadBytes(null);
    }));

    await Future.wait(CardBack.values.map((back) async {
      final loader = AssetBytesLoader('assets/backs/${back.assetName}.svg.vec');
      _loaderByCardBack[back] = loader;
      await loader.loadBytes(null);
    }));

    await Future.wait(CardSuit.values.map((suit) async {
      final loader = AssetBytesLoader('assets/faces/${_getSuitName(suit)}.svg.vec');
      _loaderBySuit[suit] = loader;
      await loader.loadBytes(null);
    }));
  }

  static AssetBytesLoader getCardLoader(SuitedCard card) => _loaderByCard[card]!;
  static AssetBytesLoader getSuitLoader(CardSuit suit) => _loaderBySuit[suit]!;
  static AssetBytesLoader getCardBackLoader(CardBack back) => _loaderByCardBack[back]!;

  static String getCardSvgPath(SuitedCard card) =>
      'assets/faces/${_getSuitName(card.suit)}-${_getValueName(card.value)}.svg';

  static String _getSuitName(CardSuit suit) => switch (suit) {
        CardSuit.hearts => 'HEART',
        CardSuit.diamonds => 'DIAMOND',
        CardSuit.clubs => 'CLUB',
        CardSuit.spades => 'SPADE',
      };

  static String _getValueName(SuitedCardValue value) => switch (value) {
        NumberSuitedCardValue(:final value) => value.toString(),
        JackSuitedCardValue() => '11-JACK',
        QueenSuitedCardValue() => '12-QUEEN',
        KingSuitedCardValue() => '13-KING',
        AceSuitedCardValue() => '1',
      };
}
