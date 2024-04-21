enum Suit {
  heart(0, '♥'),
  diamond(1, '♦'),
  club(2, '♣'),
  spade(3, '♠');

  const Suit(
    this._value,
    this._label
  );

  final int _value;
  final String _label;

  int get value => _value;
  String get label => _label;
}