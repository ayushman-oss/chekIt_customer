import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Optimized slide content type enum
enum WalkthroughContentType {
  backgroundImage,
  imageWithText,
  imageGrid,
  map,
}

// Optimized slide model with better validation
class WalkthroughSlide {
  final String? title;
  final String? subtitle;
  final List<String> images; // Made non-nullable with default empty list
  final String? buttonText;
  final String? extraText;
  final WalkthroughContentType contentType;

  const WalkthroughSlide({
    this.title,
    this.subtitle,
    this.images = const [],
    this.buttonText,
    this.extraText,
    required this.contentType,
  });

  // Helper method to check if slide has images
  bool get hasImages => images.isNotEmpty;
  String? get primaryImage => hasImages ? images.first : null;
}

// Extracted constants for better maintainability
class WalkthroughConstants {
  static const Color primaryBlue = Color(0xFF4DD0E1);
  static const Color accentBlue = Color.fromARGB(255, 80, 148, 244);
  static const Color orange = Color(0xFFFF6200);
  static const Color lightBlue = Color(0xFF6DDCFF);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color darkGray = Color(0xFF48474C);
  
  static const double defaultPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double largePadding = 32.0;
  static const double buttonBorderRadius = 24.0;
  static const double imageBorderRadius = 28.0;
  
  static const Duration animationDuration = Duration(milliseconds: 200);
}

// Optimized main screen widget
class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  
  // Moved slides data to a static method for better organization
  static const List<WalkthroughSlide> _walkthroughSlides = [
    WalkthroughSlide(
      title: 'PROACTIVE WILDFIRE\nHOME PROTECTION\n   ',
      subtitle: '\nCHEKiT GEL – COATS YOUR HOME\nBEFORE THE FIRE HITS\n\n\n',
      images: ['assets/images/luke-flynt-9jErXqFwAYs-unsplash 2.png'],
      buttonText: 'SUBSCRIBE',
      extraText: '\nAS A SUBSCRIBER YOU GET 48 Hr Guaranteed Response',
      contentType: WalkthroughContentType.backgroundImage,
    ),
    WalkthroughSlide(
      title: '\n\n\nABOUT',
      subtitle: 'When homes are threatened by wildfire, our fleet of ChekiT vehicles spray your home with a proven, extremely heat resistant, biodegradable fire-blocking gel.',
      images: ['assets/images/Rectangle 73.png'],
      contentType: WalkthroughContentType.imageWithText,
    ),
    WalkthroughSlide(
      title: 'WILDFIRE HOME PROTECTION',
      subtitle: 'How it works',
      images: ['assets/images/Screenshot_3-removebg-preview 1.png'],
      buttonText: 'SUBSCRIBE',
      extraText: '\nCHEKiT App keeps you informed of danger, evacuations, and updated notifications on the protection of your property.',
      contentType: WalkthroughContentType.imageWithText,
    ),
    WalkthroughSlide(
      title: '\n\n\nCHEKiT GEL-COAT\nwill save your home',
      images: [
        'assets/images/Rectangle 24.png',
        'assets/images/Rectangle 25.png',
      ],
      contentType: WalkthroughContentType.imageGrid,
    ),
    WalkthroughSlide(
      title: 'Currently serving the following communities\n\n',
      images: ['assets/images/Rectangle 24 (1).png'],
      extraText: '',
      contentType: WalkthroughContentType.map,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _walkthroughSlides.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return WalkthroughPage(slide: _walkthroughSlides[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: _buildPageIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _walkthroughSlides.length,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: WalkthroughConstants.animationDuration,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 10,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        color: isActive ? WalkthroughConstants.cyan : Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// Optimized slide widget with better separation of concerns
class WalkthroughPage extends StatelessWidget {
  final WalkthroughSlide slide;

  const WalkthroughPage({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    switch (slide.contentType) {
      case WalkthroughContentType.backgroundImage:
        return _BackgroundImageSlide(slide: slide);
      case WalkthroughContentType.imageWithText:
        return _ImageWithTextSlide(slide: slide);
      case WalkthroughContentType.imageGrid:
        return _ImageGridSlide(slide: slide);
      case WalkthroughContentType.map:
        return _MapSlide(slide: slide);
    }
  }
}

// Extracted slide components for better maintainability
class _BackgroundImageSlide extends StatelessWidget {
  final WalkthroughSlide slide;

  const _BackgroundImageSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (slide.hasImages)
          Image.asset(
            slide.primaryImage!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey,
              child: const Icon(Icons.error, color: Colors.white),
            ),
          ),
        Container(color: Colors.black.withOpacity(0.4)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WalkthroughConstants.defaultPadding,
              vertical: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (slide.title != null) _buildTitle(slide.title!),
                if (slide.subtitle != null) ...[
                  const SizedBox(height: 16),
                  _buildSubtitle(slide.subtitle!),
                ],
                if (slide.buttonText?.isNotEmpty == true) ...[
                  const SizedBox(height: 28),
                  _buildButton(slide.buttonText!, WalkthroughConstants.orange),
                ],
                if (slide.extraText?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _buildExtraText(slide.extraText!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.oswald(
        fontSize: 38,
        fontWeight: FontWeight.bold,
        color: WalkthroughConstants.accentBlue,
        height: 1.2,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        fontSize: 20,
        color: Colors.white,
        height: 1.4,
      ),
    );
  }

  Widget _buildButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {}, // TODO: Implement button action
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildExtraText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        fontSize: 14,
        color: WalkthroughConstants.accentBlue,
      ),
    );
  }
}

class _ImageWithTextSlide extends StatelessWidget {
  final WalkthroughSlide slide;

  const _ImageWithTextSlide({required this.slide});

  bool get _hasButton => slide.buttonText?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    if (_hasButton) {
      return _buildSubscriptionSlide(context);
    }
    return _buildAboutSlide();
  }

  Widget _buildSubscriptionSlide(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/luke-flynt-9jErXqFwAYs-unsplash 2 (3).png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.white),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.5)),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (slide.title != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 48.0,
                    left: WalkthroughConstants.defaultPadding,
                    right: WalkthroughConstants.defaultPadding,
                  ),
                  child: _buildMontserratTitle(slide.title!, 28),
                ),
              if (slide.subtitle != null) ...[
                const SizedBox(height: 8),
                _buildMontserratSubtitle(slide.subtitle!, 22),
              ],
              const SizedBox(height: 28),
              _buildSubscriptionButton(),
              const SizedBox(height: 18),
              _buildAvailabilityText(),
              const SizedBox(height: 18),
              if (slide.hasImages) _buildSlideImage(),
              const SizedBox(height: 18),
              if (slide.extraText?.isNotEmpty == true)
                _buildMontserratExtraText(slide.extraText!),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSlide() {
    return Container(
      color: WalkthroughConstants.darkGray,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (slide.title != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: WalkthroughConstants.largePadding,
                  left: WalkthroughConstants.defaultPadding,
                  right: WalkthroughConstants.defaultPadding,
                ),
                child: _buildMontserratTitle(slide.title!, 32),
              ),
            if (slide.subtitle != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: WalkthroughConstants.defaultPadding,
                ),
                child: _buildMontserratSubtitle(slide.subtitle!, 20, FontWeight.bold),
              ),
            ],
            const Spacer(),
            if (slide.hasImages) _buildFullWidthImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildMontserratTitle(String title, double fontSize) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildMontserratSubtitle(String subtitle, double fontSize, [FontWeight? fontWeight]) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: Colors.white,
        height: 1.3,
      ),
    );
  }

  Widget _buildSubscriptionButton() {
    return ElevatedButton(
      onPressed: () {}, // TODO: Implement subscription logic
      style: ElevatedButton.styleFrom(
        backgroundColor: WalkthroughConstants.primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 48.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        elevation: 0,
      ),
      child: Text(
        slide.buttonText!,
        style: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildAvailabilityText() {
    return Text(
      "AVAILABLE BY SUBSCRIPTION ONLY",
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildSlideImage() {
    return Image.asset(
      slide.primaryImage!,
      fit: BoxFit.fitHeight,
      height: 500,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 500,
        color: Colors.grey,
        child: const Icon(Icons.error, color: Colors.white),
      ),
    );
  }

  Widget _buildMontserratExtraText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WalkthroughConstants.defaultPadding),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFullWidthImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Image.asset(
        slide.primaryImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 320,
          color: Colors.grey,
          child: const Icon(Icons.error, color: Colors.white),
        ),
      ),
    );
  }
}

class _ImageGridSlide extends StatelessWidget {
  final WalkthroughSlide slide;

  const _ImageGridSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/luke-flynt-9jErXqFwAYs-unsplash 2 (1).png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.white),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.4)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WalkthroughConstants.defaultPadding,
              vertical: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (slide.title != null) _buildTitle(),
                const SizedBox(height: WalkthroughConstants.largePadding),
                if (slide.images.length >= 2) ..._buildImageGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      slide.title!,
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    );
  }

  List<Widget> _buildImageGrid() {
    return [
      _buildGridImage(slide.images[0], 260),
      const SizedBox(height: WalkthroughConstants.largePadding),
      _buildGridImage(slide.images[1], 280),
    ];
  }

  Widget _buildGridImage(String imagePath, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(WalkthroughConstants.imageBorderRadius),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: Colors.grey,
          child: const Icon(Icons.error, color: Colors.white),
        ),
      ),
    );
  }
}

class _MapSlide extends StatelessWidget {
  final WalkthroughSlide slide;

  const _MapSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/luke-flynt-9jErXqFwAYs-unsplash 2 (2).png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.white),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.4)),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (slide.title != null) ...[
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 24),
              ],
              if (slide.hasImages) _buildMapImage(),
              const Spacer(),
              _buildProceedButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WalkthroughConstants.defaultPadding),
      child: Text(
        slide.title!,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildMapImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WalkthroughConstants.smallPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WalkthroughConstants.largePadding),
        child: Image.asset(
          slide.primaryImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 320,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 320,
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WalkthroughConstants.largePadding),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/signin');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: WalkthroughConstants.lightBlue,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 60.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WalkthroughConstants.buttonBorderRadius),
          ),
        ),
        child: const Text(
          "Proceed",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}