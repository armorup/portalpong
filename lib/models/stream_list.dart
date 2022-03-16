import 'dart:async';

abstract class HasId {
  String get id;
  set id(String id);
}

/// List of Players or Balls for example
class StreamList<T extends HasId> {
  final _list = <String, T>{};
  final _controller = StreamController.broadcast();
  List<T> get list => _list.values.toList();

  // Clear and first item to list
  StreamList({required T initialValue}) {
    _init(initialValue);
  }

  // Return a stream of all items in the game
  Stream<List<T>> get stream =>
      _controller.stream.map((map) => map.values.toList());

  void update(T value) {
    _list.update(
      value.id,
      (val) => value,
      ifAbsent: () => value,
    );
    _controller.sink.add(_list);
  }

  /// Remove value from list
  void remove(T value) {
    _list.remove(value);
    _controller.sink.add(_list);
  }

  void _init(T value) {
    _list.clear();
    _list.putIfAbsent(value.id, () => value);
  }
}
