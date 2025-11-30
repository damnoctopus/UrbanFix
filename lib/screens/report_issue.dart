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

  // For visual polish: Severity labels and colors
  String get _severityLabel {
    if (_severity <= 1) return 'Low Impact';
    if (_severity <= 3) return 'Moderate Issue';
    return 'Critical Emergency';
  }

  Color get _severityColor {
    if (_severity <= 1) return Colors.green;
    if (_severity <= 3) return Colors.orange;
    return Colors.red;
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Enable location services')));
      }
      return;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location permission denied')));
      }
      return;
    }
    // Set loading state for location if needed, or just await
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
    });
  }

  Future<void> _submit() async {
    if (_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please add a photo evidence')));
      return;
    }
    if (_desc.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Description must be at least 10 chars')));
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('GPS Location is required')));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated || auth.token == null || auth.userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('You must be logged in')));
      return;
    }

    setState(() => _loading = true);
    final fields = {
      'user_id': auth.userId.toString(),
      'description': _desc.text.trim(),
      'latitude': _lat!.toString(),
      'longitude': _lng!.toString(),
      'severity': _severity.toInt().toString(),
    };

    final res = await ApiService.postComplaint(
        token: auth.token!, fields: fields, image: _image);
    setState(() => _loading = false);

    if (!mounted) return;

    if (res != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report submitted successfully!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report. Try again.')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3F8CFF)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF3F8CFF)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access theme for colors
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        title: const Text('New Report'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _loading
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Submitting report...', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evidence',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Improved Image Picker UI
                  InkWell(
                    onTap: _showImageSourceSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _image != null ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: _image == null
                            ? Border.all(color: Colors.grey.shade300, width: 2) // Dashed border simulation
                            : null,
                        boxShadow: _image != null
                            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
                            : null,
                        image: _image != null
                            ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add_a_photo_rounded, size: 32, color: primaryColor),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to upload photo',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.edit, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: TextFormField(
                      controller: _desc,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue (e.g., deep pothole on the left lane...)',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Severity Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Severity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _severityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _severityLabel,
                          style: TextStyle(color: _severityColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _severityColor,
                      inactiveTrackColor: _severityColor.withOpacity(0.2),
                      thumbColor: _severityColor,
                      overlayColor: _severityColor.withOpacity(0.1),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _severity,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (v) => setState(() => _severity = v),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location Card
                  const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _lat != null ? Colors.green.withOpacity(0.5) : Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _lat != null ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _lat != null ? Icons.check : Icons.gps_fixed,
                            color: _lat != null ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lat != null ? 'Location Locked' : 'Acquiring GPS...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _lat != null ? Colors.green.shade700 : Colors.black87,
                                ),
                              ),
                              if (_lat != null)
                                Text(
                                  '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _fetchLocation,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh Location',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Submit Report',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}