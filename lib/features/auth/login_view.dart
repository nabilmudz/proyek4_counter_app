import 'package:counter_app/features/logbook/counter_view.dart';
import 'package:flutter/material.dart';
import 'login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  int _fail = 0;
  bool _isLocked = false;
  bool _isObscure = true;

  void _handleLogin() {
    if (_isLocked) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      _fail = 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CounterView(username: user)),
      );
    } else {
      setState(() {
        _fail++;
      });

      if (_fail >= 3) {
        _lockButton();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Gagal! Gunakan admin/123")),
      );
    }
  }

  void _lockButton() {
    setState(() {
      _isLocked = true;
    });

    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _isLocked = false;
        _fail = 0;
      });
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text(_isLocked ? "Tunggu 10 detik..." : "Masuk"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
