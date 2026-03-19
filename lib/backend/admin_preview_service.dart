import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Response model
class PreviewTokenResponse {
  final String token;
  final int expiresIn;

  PreviewTokenResponse({required this.token, required this.expiresIn});

  factory PreviewTokenResponse.fromJson(Map<String, dynamic> json) {
    return PreviewTokenResponse(
      token: json['token'],
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'expires_in': expiresIn};
  }

  @override
  String toString() {
    return 'PreviewTokenResponse(token: $token, expiresIn: $expiresIn)';
  }

  /// Get expiration DateTime based on current time + expiresIn seconds
  DateTime get expirationDateTime {
    return DateTime.now().add(Duration(seconds: expiresIn));
  }

  /// Check if the token is expired (or will expire soon)
  bool get isExpired => DateTime.now().isAfter(expirationDateTime);

  /// Check if the token will expire within the given duration
  bool willExpireWithin(Duration duration) {
    return DateTime.now().add(duration).isAfter(expirationDateTime);
  }

  /// Get remaining time until expiration
  Duration get remainingTime {
    final expiration = expirationDateTime;
    final now = DateTime.now();
    if (now.isAfter(expiration)) {
      return Duration.zero;
    }
    return expiration.difference(now);
  }
}

// Custom Exceptions
class AdminPreviewServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminPreviewServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminPreviewServiceException: $message';
}

class PreviewValidationException extends AdminPreviewServiceException {
  final ValidationError validationError;

  PreviewValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class PreviewBadRequestException extends AdminPreviewServiceException {
  final ApiError apiError;

  PreviewBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class PreviewUnauthorizedException extends AdminPreviewServiceException {
  PreviewUnauthorizedException(super.message) : super(statusCode: 401);
}

class PreviewForbiddenException extends AdminPreviewServiceException {
  PreviewForbiddenException(super.message) : super(statusCode: 403);
}

class PreviewNotFoundException extends AdminPreviewServiceException {
  PreviewNotFoundException(super.message) : super(statusCode: 404);
}

// Admin Preview Service
class ClaudeAdminPreviewService {
  final String domain;
  String? _authToken;

  ClaudeAdminPreviewService({required this.domain, String? authToken})
    : _authToken = authToken;

  Map<String, String> get _jsonHeaders => {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Map<String, String> _getAuthHeaders() {
    final headers = Map<String, String>.from(_jsonHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  String? get authToken => _authToken;

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) async {
    final responseBody = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle both JSON objects and string responses
      dynamic jsonData;
      try {
        jsonData = json.decode(responseBody);
      } catch (e) {
        // If it's not valid JSON, treat as string
        jsonData = responseBody;
      }
      return fromJson(jsonData);
    } else if (response.statusCode == 400) {
      final errorData = json.decode(responseBody);
      throw PreviewBadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Not authenticated';
      throw PreviewUnauthorizedException(detail);
    } else if (response.statusCode == 403) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Forbidden';
      throw PreviewForbiddenException(detail);
    } else if (response.statusCode == 404) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Page not found';
      throw PreviewNotFoundException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw PreviewValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminPreviewServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Create a preview token for a specific page
  /// Returns a token that can be used to preview the page without authentication
  Future<PreviewTokenResponse> createPreviewToken(String pageId) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/preview-token');

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: '', // Empty body as per the API specification
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PreviewTokenResponse.fromJson(data);
        } else {
          throw AdminPreviewServiceException(
            'Expected preview token object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPreviewServiceException) rethrow;
      throw AdminPreviewServiceException('Error creating preview token: $e');
    }
  }

  /// Create multiple preview tokens for different pages
  Future<Map<String, PreviewTokenResponse>> createMultiplePreviewTokens(
    List<String> pageIds,
  ) async {
    final results = <String, PreviewTokenResponse>{};
    final errors = <String, Exception>{};

    for (final pageId in pageIds) {
      try {
        final token = await createPreviewToken(pageId);
        results[pageId] = token;
      } catch (e) {
        errors[pageId] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty && results.isEmpty) {
      throw AdminPreviewServiceException(
        'Failed to create any preview tokens. Errors: $errors',
      );
    }

    return results;
  }

  /// Generate a preview URL using a preview token
  String generatePreviewUrl(String pageId, String token, {String? baseUrl}) {
    final domain = baseUrl ?? this.domain;
    return '$domain/preview/$pageId?token=$token';
  }

  /// Generate a preview URL and create the token in one call
  Future<String> generatePreviewUrlWithToken(
    String pageId, {
    String? baseUrl,
  }) async {
    try {
      final tokenResponse = await createPreviewToken(pageId);
      return generatePreviewUrl(pageId, tokenResponse.token, baseUrl: baseUrl);
    } catch (e) {
      if (e is AdminPreviewServiceException) rethrow;
      throw AdminPreviewServiceException('Error generating preview URL: $e');
    }
  }

  /// Validate if a page ID format is correct (basic UUID validation)
  bool isValidPageId(String pageId) {
    // Basic UUID v4 regex pattern
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(pageId);
  }

  /// Create preview token with validation
  Future<PreviewTokenResponse> createPreviewTokenWithValidation(
    String pageId,
  ) async {
    if (!isValidPageId(pageId)) {
      throw AdminPreviewServiceException(
        'Invalid page ID format: $pageId',
        statusCode: 400,
      );
    }

    return createPreviewToken(pageId);
  }
}

// Factory method to create service from auth service
class ClaudeAdminPreviewServiceFactory {
  static ClaudeAdminPreviewService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminPreviewService(domain: domain, authToken: authToken);
  }

  static ClaudeAdminPreviewService create(String domain, {String? authToken}) {
    return ClaudeAdminPreviewService(domain: domain, authToken: authToken);
  }
}

// Preview token manager for caching and management
class PreviewTokenManager {
  final ClaudeAdminPreviewService _service;
  final Map<String, PreviewTokenResponse> _tokenCache = {};

  PreviewTokenManager(this._service);

  /// Get a preview token, using cache if available and not expired
  Future<PreviewTokenResponse> getPreviewToken(
    String pageId, {
    bool forceRefresh = false,
  }) async {
    final cachedToken = _tokenCache[pageId];

    if (!forceRefresh &&
        cachedToken != null &&
        !cachedToken.willExpireWithin(Duration(minutes: 5))) {
      return cachedToken;
    }

    final newToken = await _service.createPreviewToken(pageId);
    _tokenCache[pageId] = newToken;
    return newToken;
  }

  /// Get a preview URL with caching
  Future<String> getPreviewUrl(
    String pageId, {
    String? baseUrl,
    bool forceRefresh = false,
  }) async {
    final token = await getPreviewToken(pageId, forceRefresh: forceRefresh);
    return _service.generatePreviewUrl(pageId, token.token, baseUrl: baseUrl);
  }

  /// Clear expired tokens from cache
  void clearExpiredTokens() {
    _tokenCache.removeWhere((key, token) => token.isExpired);
  }

  /// Clear all cached tokens
  void clearAllTokens() {
    _tokenCache.clear();
  }

  /// Get cached token info
  Map<String, PreviewTokenResponse> get cachedTokens =>
      Map.unmodifiable(_tokenCache);
}

// Example usage:
/*
void main() async {
  // Create preview service with auth token
  final previewService = ClaudeAdminPreviewService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here',
  );

  const pageId = '5ad01ffb-fc4f-482d-ba99-384738f05ea4';

  try {
    print('--- Creating Preview Token ---');
    
    // Create a preview token for a specific page
    final tokenResponse = await previewService.createPreviewToken(pageId);
    
    print('Preview token created successfully!');
    print('Token: ${tokenResponse.token}');
    print('Expires in: ${tokenResponse.expiresIn} seconds');
    print('Expiration time: ${tokenResponse.expirationDateTime}');
    print('Time remaining: ${tokenResponse.remainingTime}');
    
    // Generate preview URL
    final previewUrl = previewService.generatePreviewUrl(pageId, tokenResponse.token);
    print('Preview URL: $previewUrl');
    
    // Or create token and URL in one call
    print('\n--- Creating Preview URL with Token ---');
    final directUrl = await previewService.generatePreviewUrlWithToken(pageId);
    print('Direct preview URL: $directUrl');
    
    // Create multiple tokens
    print('\n--- Creating Multiple Preview Tokens ---');
    final pageIds = [
      '5ad01ffb-fc4f-482d-ba99-384738f05ea4',
      '7bd02ffb-fc4f-482d-ba99-384738f05ea9',
    ];
    
    final multipleTokens = await previewService.createMultiplePreviewTokens(pageIds);
    print('Created ${multipleTokens.length} preview tokens');
    
    for (final entry in multipleTokens.entries) {
      print('Page ${entry.key}: ${entry.value.token}');
    }
    
  } on PreviewUnauthorizedException catch (e) {
    print('Preview unauthorized: ${e.message}');
    print('Make sure you have a valid auth token and proper permissions');
  } on PreviewNotFoundException catch (e) {
    print('Page not found: ${e.message}');
    print('Check if the page ID exists and is accessible');
  } on PreviewValidationException catch (e) {
    print('Preview validation error: ${e.validationError.detail}');
  } on PreviewForbiddenException catch (e) {
    print('Preview forbidden: ${e.message}');
  } on AdminPreviewServiceException catch (e) {
    print('Preview service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example with auth service and token manager:
void integratedPreviewExample() async {
  final authService = ClaudeAuthService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  try {
    // First authenticate
    final authResult = await authService.authenticateAndGetUser(
      email: 'admin@example.com',
      password: 'admin_password',
    );

    // Create preview service with the auth token
    final previewService = ClaudeAdminPreviewServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    // Create token manager for caching
    final tokenManager = PreviewTokenManager(previewService);

    const pageId = '5ad01ffb-fc4f-482d-ba99-384738f05ea4';

    // Get preview URL with caching
    final previewUrl = await tokenManager.getPreviewUrl(pageId);
    print('Cached preview URL: $previewUrl');

    // Get the same URL again (should use cache)
    final cachedUrl = await tokenManager.getPreviewUrl(pageId);
    print('Same URL from cache: $cachedUrl');

    // Force refresh
    final refreshedUrl = await tokenManager.getPreviewUrl(pageId, forceRefresh: true);
    print('Refreshed URL: $refreshedUrl');

    // Clean up expired tokens
    tokenManager.clearExpiredTokens();

  } catch (e) {
    print('Error: $e');
  }
}

// Preview management dashboard example:
void previewDashboardExample() async {
  final previewService = ClaudeAdminPreviewService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'admin_token',
  );

  final tokenManager = PreviewTokenManager(previewService);

  // Simulate managing multiple pages
  final pageIds = [
    '5ad01ffb-fc4f-482d-ba99-384738f05ea4',
    '7bd02ffb-fc4f-482d-ba99-384738f05ea9',
    '9cd03ffb-fc4f-482d-ba99-384738f05eb1',
  ];

  try {
    print('=== Preview Management Dashboard ===\n');

    for (final pageId in pageIds) {
      try {
        print('Processing page: $pageId');
        
        // Validate page ID format
        if (!previewService.isValidPageId(pageId)) {
          print('  ❌ Invalid page ID format');
          continue;
        }
        
        // Get preview token with caching
        final token = await tokenManager.getPreviewToken(pageId);
        print('  ✅ Token: ${token.token.substring(0, 20)}...');
        print('  ⏰ Expires: ${token.expirationDateTime}');
        print('  📍 URL: ${await tokenManager.getPreviewUrl(pageId)}');
        
        // Check if token will expire soon
        if (token.willExpireWithin(Duration(minutes: 10))) {
          print('  ⚠️  Token expires within 10 minutes!');
        }
        
      } catch (e) {
        print('  ❌ Error: $e');
      }
      
      print('');
    }

    // Show cached tokens summary
    final cached = tokenManager.cachedTokens;
    print('📊 Summary: ${cached.length} tokens cached');
    
    // Clean up expired tokens
    tokenManager.clearExpiredTokens();
    
  } catch (e) {
    print('Dashboard error: $e');
  }
}
*/
