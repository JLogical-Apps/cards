import 'package:card_game/card_game.dart';
import 'package:vector_graphics/vector_graphics.dart';

class PlayingCardAssetBundleCache {
  static final Map<SuitedCard, AssetBytesLoader> _loaderByCard = {};
  static late final AssetBytesLoader cardBackLoader;

  PlayingCardAssetBundleCache._();

  static Future<void> preloadAssets() async {
    await Future.wait(SuitedCard.deck.map((card) async {
      final loader = AssetBytesLoader('assets/faces/${getSuitName(card)}-${getValueName(card)}.svg.vec');
      _loaderByCard[card] = loader;
      await loader.loadBytes(null);
      return loader;
    }));

    cardBackLoader = AssetBytesLoader('assets/backs/back.svg.vec');
    await cardBackLoader.loadBytes(null);
  }

  static AssetBytesLoader getLoader(SuitedCard card) => _loaderByCard[card]!;

  static String getSvgPath(SuitedCard card) => 'assets/faces/${getSuitName(card)}-${getValueName(card)}.svg';

  static String getSuitName(SuitedCard card) => switch (card.suit) {
        CardSuit.hearts => 'HEART',
        CardSuit.diamonds => 'DIAMOND',
        CardSuit.clubs => 'CLUB',
        CardSuit.spades => 'SPADE',
      };

  static String getValueName(SuitedCard card) => switch (card.value) {
        NumberSuitedCardValue(:final value) => value.toString(),
        JackSuitedCardValue() => '11-JACK',
        QueenSuitedCardValue() => '12-QUEEN',
        KingSuitedCardValue() => '13-KING',
        AceSuitedCardValue() => '1',
      };
}
