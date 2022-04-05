import 'dart:async';

import 'package:faker/faker.dart';

import '../../data/models/player.dart';

abstract class PlayerRepository {
  Stream<Player> get stream;
}

class FakePlayerRepository extends PlayerRepository {
  late final List<Player> players;
  FakePlayerRepository() {
    var list = <Player>[];
    for (int i = 0; i < 5; i++) {
      String name = Faker().person.name();
      final player = Player(name);
      list.add(player);
      list.add(player);
    }
    players = list;
  }

  @override
  Stream<Player> get stream async* {
    yield* Stream.periodic(const Duration(seconds: 1), (index) {
      return players[index % players.length];
    });
  }
}
