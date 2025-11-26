import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String role = 'farmer'; // default: allow farmer/buyer toggle later
  bool loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> register() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final phone = _phone.text.trim();
    final address = _address.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || address.isEmpty) {
      _showMessage('Name, email, password and address are required');
      return;
    }

    setState(() => loading = true);
    final res = await AuthService.register({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone.isNotEmpty ? phone : null,
      'address': address,
    });
    if (!mounted) return;
    setState(() => loading = false);
    final code = res['statusCode'];
    final body = res['body'];
    if (code == 201 || code == 200) {
      _showMessage('Registered — please login');
      Navigator.pop(context);
    } else {
      final msg = (body is Map && body['message'] != null)
          ? '${body['message']}'
          : 'Registration failed';
      _showMessage(msg);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration:
                  const InputDecoration(labelText: 'Phone Number (Optional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Full Address'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'farmer',
                    groupValue: role,
                    title: const Text('Farmer'),
                    onChanged: (v) => setState(() => role = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'buyer',
                    groupValue: role,
                    title: const Text('Buyer'),
                    onChanged: (v) => setState(() => role = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Register',
              onPressed: register,
              loading: loading,
            ),
          ],
        ),
      ),
    );
  }
}
