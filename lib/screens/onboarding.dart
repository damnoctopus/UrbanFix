import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Text('Welcome to UrbanFix', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Report civic issues with photos, location and track status until resolution.', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 30),
              Expanded(child: Image.asset('assets/onboarding.png', fit: BoxFit.contain, errorBuilder: (_,__,___)=>const Icon(Icons.location_city, size: 180, color: Color(0xFF3F8CFF)))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F8CFF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Get Started', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
