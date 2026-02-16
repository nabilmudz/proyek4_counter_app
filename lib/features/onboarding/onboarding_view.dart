import 'package:counter_app/features/auth/login_view.dart';
import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  @override
  State<StatefulWidget> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  Color get backgroundColor {
    switch (step) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  Color get textColor {
    switch (step) {
      case 1:
        return Colors.white;
      case 2:
        return Colors.black;
      case 3:
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }

  String get textLabel {
    switch (step) {
      case 1:
        return "Selamat Datang!";
      case 2:
        return "Logbook Counter";
      case 3:
        return "Siap, Lanjut!";
      default:
        return "Logbook Counter";
    }
  }

  Widget get stepImage {
    switch (step) {
      case 1:
        return Image.asset('assets/images/coding.png', width: 200, height: 200);
      case 2:
        return Image.asset('assets/images/ux.png', width: 200, height: 200);
      case 3:
        return Image.asset(
          'assets/images/smartphone.png',
          width: 200,
          height: 200,
        );
      default:
        return const SizedBox();
    }
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: step == index ? 12 : 8,
      height: step == index ? 12 : 8,
      decoration: BoxDecoration(
        color: step == index ? const Color.fromARGB(255, 0, 0, 0) : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            stepImage,
            const SizedBox(height: 20),
            Text(textLabel, style: TextStyle(fontSize: 48, color: textColor)),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildDot(1), buildDot(2), buildDot(3)],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'next',
            onPressed: () {
              setState(() {
                if (step < 3) {
                  setState(() {
                    step++;
                  });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                }
              });
            },
            child: Icon(Icons.arrow_forward_sharp),
          ),
        ],
      ),
    );
  }
}
