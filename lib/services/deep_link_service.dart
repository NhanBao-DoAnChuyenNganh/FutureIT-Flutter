import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<String>? _linkSubscription;
  
  // Callback khi nhận được deep link thanh toán
  Function(bool success, String message, int? maKhoaHoc)? onPaymentCallback;

  /// Khởi tạo lắng nghe deep link
  Future<void> init() async {
    // Xử lý deep link khi app đang chạy - dùng stringLinkStream để tránh lỗi parse URI
    _linkSubscription = _appLinks.stringLinkStream.listen((String link) {
      _handleDeepLinkString(link);
    });

    // Xử lý deep link khi app được mở từ terminated state
    try {
      final initialLink = await _appLinks.getInitialLinkString();
      if (initialLink != null) {
        _handleDeepLinkString(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }
  }

  void _handleDeepLinkString(String link) {
    debugPrint('Deep link received: $link');
    
    try {
      // Xử lý callback thanh toán: itfuture://payment/success hoặc itfuture://payment/fail
      if (link.startsWith('itfuture://')) {
        // Parse thủ công để tránh lỗi với ký tự đặc biệt
        final params = _parseQueryParams(link);
        
        if (link.contains('payment')) {
          final success = params['success']?.toLowerCase() == 'true';
          var message = params['message'] ?? '';
          
          // Decode message an toàn
          try {
            message = Uri.decodeComponent(message);
          } catch (e) {
            debugPrint('Error decoding message: $e');
          }
          
          final maKhoaHoc = int.tryParse(params['maKhoaHoc'] ?? '');
          
          debugPrint('Payment callback - Success: $success, Message: $message, MaKhoaHoc: $maKhoaHoc');
          
          onPaymentCallback?.call(success, message, maKhoaHoc);
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  /// Parse query params thủ công để tránh lỗi với ký tự đặc biệt
  Map<String, String> _parseQueryParams(String url) {
    final params = <String, String>{};
    final queryIndex = url.indexOf('?');
    if (queryIndex == -1) return params;
    
    final query = url.substring(queryIndex + 1);
    final pairs = query.split('&');
    
    for (final pair in pairs) {
      final eqIndex = pair.indexOf('=');
      if (eqIndex > 0) {
        final key = pair.substring(0, eqIndex);
        final value = pair.substring(eqIndex + 1);
        params[key] = value;
      }
    }
    
    return params;
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
