import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/product_service.dart';
import 'product_details_page.dart';
import 'product_not_found_page.dart';
import 'search_results_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  String _searchQuery = '';
  late MobileScannerController _cameraController;
  bool _hasPermission = false;
  bool _isScanning = true;
  bool _isLoading = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cameraController.start();
    } else if (state == AppLifecycleState.paused) {
      _cameraController.stop();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _initializeCamera();
    }
  }

  void _initializeCamera() {
    _cameraController = MobileScannerController(
      autoStart: true,
      torchEnabled: false,
    );
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (!_isScanning || _isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
        setState(() {
          _lastScannedCode = barcode.rawValue;
          _searchController.text = barcode.rawValue!;
          _searchQuery = barcode.rawValue!;
          _isScanning = false;
        });

        // Resume scanning after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isScanning = true;
            });
          }
        });

        // Fetch product info based on barcode
        _fetchProductDetails(barcode.rawValue!);
      }
    }
  }

  Future<void> _fetchProductDetails(String query) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Determine if the query is a barcode (numeric) or text search
    final isBarcode = RegExp(r'^[0-9]+$').hasMatch(query);

    if (isBarcode) {
      // Barcode search - get single product from backend
      final response = await _productService.getProductDetails(query);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.success && response.data != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsPage(productDetails: response.data!),
          ),
        );
      } else {
        // Show ProductNotFoundPage instead of SnackBar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductNotFoundPage(searchQuery: query),
          ),
        );
      }
    } else {
      // Text search - get multiple products and show results page
      final products = await _productService.searchProducts(query);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (products != null && products.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(
              initialQuery: query,
              initialResults: products,
            ),
          ),
        );
      } else {
        // Show ProductNotFoundPage when no results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductNotFoundPage(searchQuery: query),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Embedded Camera Scanner
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C5F2D), width: 3),
                ),
                clipBehavior: Clip.hardEdge,
                child: _hasPermission
                    ? Stack(
                        children: [
                          MobileScanner(
                            controller: _cameraController,
                            onDetect: _onBarcodeDetect,
                          ),
                          // Scanning indicator overlay
                          if (_isScanning)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Scanning...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Corner accents
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                  left: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                  left: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white54,
                              size: 50,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Camera Permission Required',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _requestCameraPermission,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C5F2D),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Grant Permission',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              // Search Section Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Column(
                  children: [
                    // Scan or search text
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(
                            text: 'Scan ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: 'a barcode or\n',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          TextSpan(
                            text: 'search ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: 'for a product',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Search bar with camera icon
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          // Search field
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search for a product',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          // Search button
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      if (_searchQuery.isNotEmpty) {
                                        _fetchProductDetails(_searchQuery);
                                      }
                                    },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2C5F2D),
                                  shape: BoxShape.circle,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Support section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info_outline, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Our application needs you!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: 'Help us inform '),
                                TextSpan(
                                  text: 'millions of\nconsumers',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' on what they eat!'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle support action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Support',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
