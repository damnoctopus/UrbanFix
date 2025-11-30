import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/image_helper.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  double _severity = 3;

  final _desc = TextEditingController();
  double? _lat;
  double? _lng;

  Future<void> _pickImage(ImageSource src) async {
    final x = await _picker.pickImage(source: src, imageQuality: 85);
    if (x != null) {
      var f = File(x.path);
      final compressed = await ImageHelper.compressFile(f, quality: 75);
      setState(() => _image = compressed ?? f);
    }
  }

  Future<void> _fetchLocation() async {
    final ok = await Geolocator.isLocationServiceEnabled();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enable location services')));
      return;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() { _lat = pos.latitude; _lng = pos.longitude; });
  }

  Future<void> _submit() async {
    if (_image == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add an image'))); return; }
    if (_desc.text.trim().length < 10) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Description min 10 chars'))); return; }
    // category is handled by backend auto-routing; no client selection required
    if (_lat == null || _lng == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location required'))); return; }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated || auth.token == null || auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login required')));
      return;
    }

    setState(()=>_loading=true);
    final fields = {
      'user_id': auth.userId.toString(),
      'description': _desc.text.trim(),
      'latitude': _lat!.toString(),
      'longitude': _lng!.toString(),
      'severity': _severity.toInt().toString(),
    };

    final res = await ApiService.postComplaint(token: auth.token!, fields: fields, image: _image);
    setState(()=>_loading=false);
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission failed')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo), label: const Text('Gallery')),
            ]),
            const SizedBox(height: 12),
            if (_image != null) Image.file(_image!, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 12),
            TextFormField(controller: _desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')), 
            const SizedBox(height: 12),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline, color: Color(0xFF3F8CFF)),
              title: Text('Category will be auto-detected by the backend'),
              subtitle: Text('You do not need to select a category.'),
            ),
            const SizedBox(height: 12),
            const Text('Severity'),
            Slider(value: _severity, min: 1, max: 5, divisions: 4, label: _severity.toInt().toString(), onChanged: (v)=>setState(()=>_severity=v)),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(onPressed: _fetchLocation, icon: const Icon(Icons.my_location), label: const Text('Use GPS')),
              const SizedBox(width: 12),
              if (_lat!=null && _lng!=null) Text('Lat: ${_lat!.toStringAsFixed(4)}, Lng: ${_lng!.toStringAsFixed(4)}')
            ]),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: _loading?null:_submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F8CFF), foregroundColor: Colors.white), child: _loading?const CircularProgressIndicator(color: Colors.white):const Padding(padding: EdgeInsets.symmetric(vertical: 14.0), child: Text('Submit'))),
          ],
        ),
      ),
    );
  }
}
