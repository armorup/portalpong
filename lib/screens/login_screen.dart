import 'package:avatars/avatars.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/network.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.game, Key? key}) : super(key: key);

  final PortalPongGame game;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  String name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (name == '') ? const SizedBox(height: 100) : Avatar(name: name),
              const SizedBox(
                height: 20,
              ),
              Form(
                child: TextFormField(
                  controller: _controller,
                  onChanged: (text) => setState(() {
                    name = text;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Player name',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          name = '';
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        name = Faker().person.name();
                        _controller.text = name;
                      }),
                      child: const Text('Random!'),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: ElevatedButton(
                      onPressed: (name == '' || _controller.text == '')
                          ? null
                          : () => login(context),
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void login(BuildContext context) {
    // TODO: Valid player name?  New login?
    game.player = Player(name);
    // Poll the network to get ip
    net.poll();
    game.overlays.add('join');
    game.overlays.remove('login');
    //context.push('/join');
  }
}
