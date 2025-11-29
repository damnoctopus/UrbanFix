import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v==null||v.isEmpty)? 'Required' : null,),
              const SizedBox(height: 12),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v==null||!v.contains('@'))? 'Enter valid email' : null,),
              const SizedBox(height: 12),
              TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (v) => (v==null||v.length<6)? 'Min 6 chars' : null,),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(()=>_loading=true);
                  final ok = await auth.register(_name.text.trim(), _email.text.trim(), _password.text.trim());
                  setState(()=>_loading=false);
                  if (ok) Navigator.pushReplacementNamed(context, '/home');
                  else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F8CFF), foregroundColor: Colors.white),
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Padding(padding: EdgeInsets.all(12.0), child: Text('Create account'))),
            ],
          ),
        ),
      ),
    );
  }
}
