import 'dart:async';
import 'package:flutter/material.dart';
import 'property_location_screen.dart';
import '../subscription.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '+1');
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _otpSent = false;
  bool _otpVerified = false;
  int _timer = 30;
  Timer? _otpTimer;
  late final FocusNode _otpFocusNode;
  late final FocusNode _addressFocusNode;

  @override
  void initState() {
    super.initState();
    _otpFocusNode = FocusNode();
    _addressFocusNode = FocusNode();

    _mobileController.addListener(_onPhoneChanged);
    _nameController.addListener(() => setState(() {}));
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _nameController.dispose();
    _countryCodeController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _addressController.dispose();
    _otpFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_otpSent) {
      setState(() {
        _otpSent = false;
        _otpVerified = false;
        _otpController.clear();
        _timer = 30;
      });
    }
    setState(() {}); // To update arrow button state
  }

  void _onOtpChanged() {
    // Simulate OTP verification (replace with real logic)
    if (_otpController.text.length == 4) {
      setState(() {
        _otpVerified = true;
      });
      // Stop the timer if verified
      _otpTimer?.cancel();
    } else {
      setState(() {
        _otpVerified = false;
      });
    }
  }

  void _sendOtp() {
    setState(() {
      _otpSent = true;
      _timer = 30;
      _otpVerified = false;
      _otpController.clear();
    });
    // Cancel any previous timer
    _otpTimer?.cancel();
    // Start timer
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 0 && mounted && !_otpVerified) {
        setState(() => _timer--);
      } else {
        timer.cancel();
      }
    });
    FocusScope.of(context).requestFocus(_otpFocusNode);
  }

  void _resendOtp() {
    if (_timer == 0) _sendOtp();
  }

  bool get _isPhoneValid =>
      _mobileController.text.trim().length == 10 &&
      RegExp(r'^\d{10}$').hasMatch(_mobileController.text.trim());

  bool get _canSendOtp =>
      _isPhoneValid &&
      !_otpSent;

  bool get _showProceed =>
      _nameController.text.trim().isNotEmpty &&
      _otpVerified &&
      _addressController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Secure Your Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90), // Enough space for the button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Full Name',
                      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF232323),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mobile Number',
                      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: _countryCodeController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF232323),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                              ),
                              onChanged: (_) {
                                setState(() {
                                  // Reset OTP state if country code changes
                                  if (_otpSent) {
                                    _otpSent = false;
                                    _otpVerified = false;
                                    _otpController.clear();
                                    _timer = 30;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _mobileController,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: const Color(0xFF232323),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _canSendOtp ? const Color(0xFF6DDCFF) : Colors.grey,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: _canSendOtp ? _sendOtp : null,
                              child: Icon(
                                Icons.arrow_forward,
                                color: _canSendOtp ? const Color(0xFF6DDCFF) : Colors.grey,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Enter OTP',
                      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _otpController,
                      focusNode: _otpFocusNode,
                      enabled: _otpSent,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      style: const TextStyle(color: Colors.white, letterSpacing: 8),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: const Color(0xFF232323),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _otpVerified = val.length == 4;
                        });
                      },
                    ),
                    if (_otpVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Color(0xFF6DDCFF), size: 20),
                            SizedBox(width: 6),
                            Text(
                              "Number Verified",
                              style: TextStyle(color: Color(0xFF6DDCFF), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          "Didn't get the OTP ",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: _timer == 0 && _otpSent ? _resendOtp : null,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: _timer == 0 && _otpSent ? const Color(0xFF6DDCFF) : Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _otpSent ? '00:${_timer.toString().padLeft(2, '0')}' : '',
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Property Address',
                      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PropertyLocationScreen(),
                          ),
                        );
                        if (result != null && result is Map) {
                          setState(() {
                            _addressController.text = result['address'] ?? '';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _addressController,
                          focusNode: _addressFocusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF232323),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            hintText: 'Property Address',
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (_showProceed)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // left, top, right, bottom
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6DDCFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Subscription()),
                        );
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}