import 'package:flutter/material.dart';
import '../../utils/route_transitions.dart';
import 'profile_screen.dart';
import '../Login/property_location_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String mobile;
  final String location;
  final String area;

  const EditProfileScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.location,
    required this.area,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _locationController;
  late TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _mobileController = TextEditingController(text: widget.mobile);
    _locationController = TextEditingController(text: widget.location);
    _areaController = TextEditingController(text: widget.area);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _submit() {
    // Add your update logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated!"),
        backgroundColor: Colors.green,
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Color.fromARGB(255, 197, 197, 197),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // No trailing icon for edit screen, but keep the space for symmetry
                Opacity(
                  opacity: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SizedBox(height: 8),
            _FieldLabelAndInput(
              label: "Full Name",
              child: _ProfileField(
                controller: _nameController,
                hint: "Full Name",
              ),
            ),
            const SizedBox(height: 18),
            _FieldLabelAndInput(
              label: "Email Address",
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color:  const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 17,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _FieldLabelAndInput(
              label: "Mobile Number",
              child: _ProfileField(
                controller: _mobileController,
                hint: "Mobile Number",
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 18),
            _FieldLabelAndInput(
              label: "Property Location",
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PropertyLocationScreen(),
                    ),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      _locationController.text = result['address'] ?? '';
                      _areaController.text = result['area'] ?? '';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _ProfileField(
                    controller: _locationController,
                    hint: "Property Location",
                    suffix: const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _FieldLabelAndInput(
              label: "Property Area",
              child: _ProfileField(
                controller: _areaController,
                hint: "Property Area",
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 48),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E6FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              elevation: 0,
            ),
            onPressed: _submit,
            child: const Text("Submit"),

          ),
        ),
      ),
    );
  }
}

class _FieldLabelAndInput extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldLabelAndInput({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _ProfileField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontFamily: 'SF Pro Display',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFBDBDBD),
          fontSize: 17,
          fontFamily: 'SF Pro Display',
        ),
        filled: true,
        fillColor: const Color(0xFF323335),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        suffixIcon: suffix,
      ),
    );
  }
}