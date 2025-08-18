import 'package:flutter/material.dart';
import '../../utils/route_transitions.dart';
import 'menu_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_newController.text != _confirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("New password and confirm password do not match."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Proceed with password change logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password changed successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 800),
        ),
      );
      Future.delayed(const Duration(milliseconds: 900), () {
        Navigator.pushReplacement(
          context,
          fadeRoute(const MenuScreen(currentIndex: 6)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () => Navigator.pushReplacement(
            context,
            fadeRoute(const MenuScreen(currentIndex: 6)),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
                _FieldLabelAndInput(
                  label: "Current Password",
                  child: _PasswordField(
                    controller: _currentController,
                    hint: "Enter Current Password",
                    obscure: !_showCurrent,
                    onToggle: () => setState(() => _showCurrent = !_showCurrent),
                    icon: _showCurrent ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                const SizedBox(height: 18),
                _FieldLabelAndInput(
                  label: "New Password",
                  child: _PasswordField(
                    controller: _newController,
                    hint: "New Password",
                    obscure: !_showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    icon: _showNew ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                const SizedBox(height: 18),
                _FieldLabelAndInput(
                  label: "Confirm Password",
                  child: _PasswordField(
                    controller: _confirmController,
                    hint: "Confirm Password",
                    obscure: !_showConfirm,
                    onToggle: () => setState(() => _showConfirm = !_showConfirm),
                    icon: _showConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E6FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      child: const Text("Submit"),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final IconData icon;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      obscuringCharacter: '●',
      style: TextStyle(
        color: Colors.white, 
        fontSize: 17,
        fontFamily: 'SF Pro Display',
        letterSpacing: obscure ? 2.0 : 0.0,
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
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(icon, color: const Color(0xFFBDBDBD)),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Required";
        return null;
      },
    );
  }
}