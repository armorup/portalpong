import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portalpong/presentation/screens/wait_screen/bloc/room_bloc.dart';
import '../../../data/models/player.dart';
import '../../../domain/network/network.dart';
import '../../../game.dart';
import '../../../main.dart';

class WaitScreen extends StatefulWidget {
  const WaitScreen({required this.game, Key? key}) : super(key: key);
  final PortalPongGame game;

  @override
  State<WaitScreen> createState() => _WaitScreenState();
}

class _WaitScreenState extends State<WaitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: BlocBuilder<RoomBloc, RoomState>(
            builder: (context, state) {
              return state.when(
                initial: () {
                  context.read<RoomBloc>().add(const RoomEvent.started());
                  return buildInitial();
                },
                loading: () => buildLoading(),
                loaded: (players) => buildLoaded(players),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildInitial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Avatar(name: data.player.name)),
        const SizedBox(height: 50),
        if (net.server != null)
          ElevatedButton(
            onPressed: () => launch(),
            child: const Text('Launch!'),
          ),
        ElevatedButton(
          onPressed: () async => cancel(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget buildLoading() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget buildLoaded(List<Player> players) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, i) {
              return Avatar(name: players[i].name);
            },
          ),
        ),
        const SizedBox(height: 50),
        if (net.server != null)
          ElevatedButton(
            onPressed: () => launch(),
            child: const Text('Launch!'),
          ),
        ElevatedButton(
          onPressed: () async =>
              context.read<RoomBloc>().add(const RoomEvent.cancel()),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  // called by host
  void launch() {
    data.player.launch = true;
    // The host starts with ball
    //data.balls.add(BallData(curOwner: data.player.name));
    net.client!.write();
    data.player.launch = false;
    game.startGame();
    game.overlays.remove('wait');
  }

  void cancel() async {
    // stop the server if it exists
    await net.server?.cancel();
    net.server = null;
    // stop trying to join
    await net.client?.cancel();
    net.client = null;

    game.overlays.add('join');
    game.overlays.remove('wait');
  }
}
