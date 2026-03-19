import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Request model
class CreateBootstrapSuperAdminRequest {
  final String email;
  final String fullName;
  final String password;

  CreateBootstrapSuperAdminRequest({
    required this.email,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'full_name': fullName, 'password': password};
  }
}

// Response model
class CreateBootstrapSuperAdminResponse {
  final String message;

  CreateBootstrapSuperAdminResponse({required this.message});

  factory CreateBootstrapSuperAdminResponse.fromString(String message) {
    return CreateBootstrapSuperAdminResponse(message: message);
  }

  factory CreateBootstrapSuperAdminResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateBootstrapSuperAdminResponse(
      message: json['message'] ?? json.toString(),
    );
  }
}

// Custom Exceptions
class AdminBootstrapServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminBootstrapServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminBootstrapServiceException: $message';
}

class BootstrapValidationException extends AdminBootstrapServiceException {
  final ValidationError validationError;

  BootstrapValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class BootstrapBadRequestException extends AdminBootstrapServiceException {
  final ApiError apiError;

  BootstrapBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class BootstrapUnauthorizedException extends AdminBootstrapServiceException {
  BootstrapUnauthorizedException(super.message) : super(statusCode: 401);
}

// Admin Bootstrap Service
class ClaudeAdminBootstrapService {
  final String domain;
  String? _bootstrapToken;

  ClaudeAdminBootstrapService({required this.domain, String? bootstrapToken})
    : _bootstrapToken = bootstrapToken;

  Map<String, String> get _jsonHeaders => {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Map<String, String> _getBootstrapHeaders() {
    final headers = Map<String, String>.from(_jsonHeaders);
    if (_bootstrapToken != null) {
      headers['x_bootstrap_token'] = _bootstrapToken!;
    }
    return headers;
  }

  void setBootstrapToken(String token) {
    _bootstrapToken = token;
  }

  void clearBootstrapToken() {
    _bootstrapToken = null;
  }

  String? get bootstrapToken => _bootstrapToken;

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
      throw BootstrapBadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Invalid bootstrap token';
      throw BootstrapUnauthorizedException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw BootstrapValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminBootstrapServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Create the first superadmin (one-time bootstrap operation)
  /// This endpoint is used to initialize the system with the first superadmin user
  Future<CreateBootstrapSuperAdminResponse> createBootstrapSuperAdmin({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final url = Uri.parse('$domain/bootstrap/superadmin');
    final request = CreateBootstrapSuperAdminRequest(
      email: email,
      fullName: fullName,
      password: password,
    );

    try {
      final response = await http.post(
        url,
        headers: _getBootstrapHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is String) {
          return CreateBootstrapSuperAdminResponse.fromString(data);
        } else if (data is Map<String, dynamic>) {
          return CreateBootstrapSuperAdminResponse.fromJson(data);
        } else {
          throw AdminBootstrapServiceException(
            'Unexpected response format: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminBootstrapServiceException) rethrow;
      throw AdminBootstrapServiceException(
        'Error creating bootstrap super admin: $e',
      );
    }
  }

  /// Check if bootstrap is available/needed
  /// This is a helper method to determine if the bootstrap endpoint should be used
  Future<bool> isBootstrapNeeded() async {
    try {
      // Try to create a bootstrap superadmin with dummy data to test availability
      // This will fail if bootstrap is no longer available, indicating it's been used
      await createBootstrapSuperAdmin(
        email: 'test@example.com',
        fullName: 'Test User',
        password: 'test123',
      );
      return true;
    } on BootstrapUnauthorizedException {
      // If unauthorized, bootstrap might be disabled or token is invalid
      return false;
    } on BootstrapValidationException {
      // If validation error, bootstrap is available but data is invalid
      return true;
    } catch (e) {
      // Any other error, assume bootstrap is not available
      return false;
    }
  }
}

// Factory method to create service
class ClaudeAdminBootstrapServiceFactory {
  static ClaudeAdminBootstrapService create(
    String domain, {
    String? bootstrapToken,
  }) {
    return ClaudeAdminBootstrapService(
      domain: domain,
      bootstrapToken: bootstrapToken,
    );
  }
}

// Example usage:
/*
void main() async {
  // Create bootstrap service
  final bootstrapService = ClaudeAdminBootstrapService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    bootstrapToken: 'your_bootstrap_token_here', // Optional
  );

  try {
    print('--- Creating Bootstrap SuperAdmin ---');
    
    // Create the first superadmin (one-time operation)
    final result = await bootstrapService.createBootstrapSuperAdmin(
      email: 'admin@latente.com',
      fullName: 'System Administrator',
      password: 'secure_admin_password_123',
    );
    
    print('Bootstrap superadmin created successfully!');
    print('Result: ${result.message}');
    
    // Note: This endpoint can typically only be used once
    // Subsequent calls will likely fail with authorization errors
    
  } on BootstrapUnauthorizedException catch (e) {
    print('Bootstrap unauthorized: ${e.message}');
    print('This usually means:');
    print('1. Bootstrap token is invalid or missing');
    print('2. Bootstrap has already been completed');
    print('3. Bootstrap is disabled on this environment');
  } on BootstrapValidationException catch (e) {
    print('Bootstrap validation error: ${e.validationError.detail}');
    print('Check the email format, password strength, or required fields');
  } on BootstrapBadRequestException catch (e) {
    print('Bootstrap bad request: ${e.apiError.detail}');
  } on AdminBootstrapServiceException catch (e) {
    print('Bootstrap service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example for system initialization:
void systemInitializationExample() async {
  final bootstrapService = ClaudeAdminBootstrapServiceFactory.create(
    'https://latente-cms-415c09785677.herokuapp.com',
    bootstrapToken: 'bootstrap_token_from_env',
  );

  try {
    // Step 1: Check if bootstrap is needed
    print('Checking if bootstrap is needed...');
    final isNeeded = await bootstrapService.isBootstrapNeeded();
    
    if (!isNeeded) {
      print('Bootstrap is not needed - system already initialized');
      return;
    }
    
    print('Bootstrap is needed - creating first superadmin...');
    
    // Step 2: Create the bootstrap superadmin
    final result = await bootstrapService.createBootstrapSuperAdmin(
      email: 'admin@latente.com',
      fullName: 'Latente System Admin',
      password: 'SecureAdminPassword2024!',
    );
    
    print('✅ System initialized successfully!');
    print('Message: ${result.message}');
    print('');
    print('Next steps:');
    print('1. Login with the created superadmin credentials');
    print('2. Create additional users through the admin interface');
    print('3. Configure the system settings');
    
  } catch (e) {
    print('❌ System initialization failed: $e');
    print('');
    print('Troubleshooting:');
    print('1. Verify the bootstrap token is correct');
    print('2. Check if the system has already been initialized');
    print('3. Ensure the API endpoint is accessible');
  }
}

// Environment-specific bootstrap example:
void environmentBootstrap() async {
  // Different bootstrap tokens for different environments
  const environmentConfigs = {
    'development': {
      'domain': 'http://localhost:8000',
      'token': 'dev_bootstrap_token',
    },
    'staging': {
      'domain': 'https://latente-cms-staging.herokuapp.com',
      'token': 'staging_bootstrap_token',
    },
    'production': {
      'domain': 'https://latente-cms-415c09785677.herokuapp.com',
      'token': 'prod_bootstrap_token',
    },
  };
  
  const environment = 'development'; // Get from environment variables
  final config = environmentConfigs[environment]!;
  
  final bootstrapService = ClaudeAdminBootstrapService(
    domain: config['domain']!,
    bootstrapToken: config['token'],
  );
  
  try {
    final result = await bootstrapService.createBootstrapSuperAdmin(
      email: 'admin@latente.com',
      fullName: 'Latente Admin',
      password: 'AdminPassword123!',
    );
    
    print('$environment environment bootstrapped: ${result.message}');
    
  } catch (e) {
    print('Failed to bootstrap $environment environment: $e');
  }
}
*/
