enum Achievement {
  speedDealer('Speed Dealer', 'Win any game in under 1 minute'),
  grandSlam('Grand Slam', 'In Golf Solitaire, make a chain of 10 consecutive cards'),
  suitedUp('Suited Up', 'In Solitaire, complete one entire suit foundation before starting others'),
  deckWhisperer('Deck Whisperer', 'Win a Solitaire game without restarting the deck'),
  fullHouse('Full House', 'Complete all games in Classic mode'),
  holeInOne('Hole in One', 'Win Golf Solitaire with only 1 card remaining in the draw pile'),
  stackTheDeck('Stack the Deck', 'Win 5 games in a row'),
  royalFlush('Royal Flush', 'Complete all games in Royal mode'),
  cleanSweep('Clean Sweep', 'Win an Ace Solitaire game without undoing any moves'),
  perfectPlanning('Perfect Planning', 'Win an Ace Free Cell game without undoing any moves'),
  aceUpYourSleeve('Ace Up Your Sleeve', 'Complete all games in Ace mode');

  final String name;
  final String description;

  const Achievement(this.name, this.description);
}
