import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class FeedbackScreen extends StatefulWidget {
  final int id;
  const FeedbackScreen({super.key, required this.id});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _satisfied = true;
  final _comment = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;
    setState(()=>_loading=true);
    final payload = {'satisfied': _satisfied, 'comment': _comment.text};
    final ok = await ApiService.postFeedback(widget.id, payload, token: auth.token);
    setState(()=>_loading=false);
    if (ok) Navigator.pop(context);
    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Are you satisfied?'),
          Row(children: [
            ChoiceChip(label: const Text('Yes'), selected: _satisfied, onSelected: (v)=>setState(()=>_satisfied=true)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('No'), selected: !_satisfied, onSelected: (v)=>setState(()=>_satisfied=false)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _comment, decoration: const InputDecoration(labelText: 'Comments (optional)')),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: _loading?null:_submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F8CFF), foregroundColor: Colors.white), child: _loading?const CircularProgressIndicator(color: Colors.white):const Text('Submit'))
        ]),
      ),
    );
  }
}
