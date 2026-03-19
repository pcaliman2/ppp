import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Models
class TokenRequest {
  final String grantType;
  final String username;
  final String password;
  final String? scope;
  final String? clientId;
  final String? clientSecret;

  TokenRequest({
    required this.grantType,
    required this.username,
    required this.password,
    this.scope,
    this.clientId,
    this.clientSecret,
  });

  Map<String, String> toFormData() {
    final Map<String, String> data = {
      'grant_type': grantType,
      'username': username,
      'password': password,
    };

    if (scope != null) data['scope'] = scope!;
    if (clientId != null) data['client_id'] = clientId!;
    if (clientSecret != null) data['client_secret'] = clientSecret!;

    return data;
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String email;
  final String fullName;
  final String password;

  RegisterRequest({
    required this.email,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'full_name': fullName, 'password': password};
  }
}

class TokenResponse {
  final String accessToken;
  final String tokenType;

  TokenResponse({required this.accessToken, required this.tokenType});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  // Handle case where API returns just a string token
  factory TokenResponse.fromString(String token) {
    return TokenResponse(accessToken: token, tokenType: 'Bearer');
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'access_token': accessToken,
    'token_type': tokenType,
  };

  String toPrettyJsonString() => toMap().toString();
}

class User {
  final String id;
  final String email;
  final String fullName;
  final bool isActive;
  final bool isPlatformSuperadmin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isActive,
    required this.isPlatformSuperadmin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      isActive: json['is_active'],
      isPlatformSuperadmin: json['is_platform_superadmin'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
      'is_platform_superadmin': isPlatformSuperadmin,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Custom Exceptions
class AuthServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AuthServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AuthServiceException: $message';
}

class ValidationException extends AuthServiceException {
  final ValidationError validationError;

  ValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class BadRequestException extends AuthServiceException {
  final ApiError apiError;

  BadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class UnauthorizedException extends AuthServiceException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AuthServiceException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class PasswordRecoveryRequest {
  final String email;

  PasswordRecoveryRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class PasswordRecoveryResponse {
  final String message;

  PasswordRecoveryResponse({required this.message});

  factory PasswordRecoveryResponse.fromJson(Map<String, dynamic> json) {
    return PasswordRecoveryResponse(message: json['msg']);
  }
}

class PasswordResetConfirmRequest {
  final String token;
  final String newPassword;

  PasswordResetConfirmRequest({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'token': token, 'new_password': newPassword};
  }
}

class PasswordResetConfirmResponse {
  final String message;

  PasswordResetConfirmResponse({required this.message});

  factory PasswordResetConfirmResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetConfirmResponse(message: json['msg']);
  }
}

// Auth Service
class ClaudeAuthService {
  final String domain;
  String? _authToken;

  ClaudeAuthService({required this.domain});

  Map<String, String> get _formHeaders => {
    'accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

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
      throw BadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Unauthorized';
      throw UnauthorizedException(detail);
    } else if (response.statusCode == 403) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Forbidden';
      throw ForbiddenException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw ValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AuthServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// OAuth2 password flow - GET ACCESS TOKEN (form-encoded)
  Future<TokenResponse> getToken({
    required String username,
    required String password,
    String grantType = 'password',
    String? scope,
    String? clientId,
    String? clientSecret,
  }) async {
    final url = Uri.parse('$domain/auth/token');
    final request = TokenRequest(
      grantType: grantType,
      username: username,
      password: password,
      scope: scope,
      clientId: clientId,
      clientSecret: clientSecret,
    );

    try {
      final response = await http.post(
        url,
        headers: _formHeaders,
        body: request.toFormData(),
      );

      return await _handleResponse(response, (data) {
        // Handle both string and object responses
        if (data is String) {
          return TokenResponse.fromString(data);
        } else if (data is Map<String, dynamic>) {
          return TokenResponse.fromJson(data);
        } else {
          throw AuthServiceException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException('Error getting token: $e');
    }
  }

  /// Admin login (JSON) - returns token string
  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$domain/auth/login');
    final request = LoginRequest(email: email, password: password);

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );

      final tokenResponse = await _handleResponse(response, (data) {
        // Handle both string and object responses
        if (data is String) {
          return TokenResponse.fromString(data);
        } else if (data is Map<String, dynamic>) {
          return TokenResponse.fromJson(data);
        } else {
          throw AuthServiceException('Unexpected response format');
        }
      });

      // Automatically set the auth token for subsequent requests
      setAuthToken(tokenResponse.accessToken);

      return tokenResponse;
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException('Error during login: $e');
    }
  }

  /// Get current user info (requires authentication)
  Future<User> getCurrentUser() async {
    final url = Uri.parse('$domain/auth/me');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return User.fromJson(data);
        } else {
          throw AuthServiceException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException('Error getting current user: $e');
    }
  }

  /// Dev-only: Register first superadmin
  Future<User> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final url = Uri.parse('$domain/auth/register');
    final request = RegisterRequest(
      email: email,
      fullName: fullName,
      password: password,
    );

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return User.fromJson(data);
        } else {
          throw AuthServiceException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException('Error during registration: $e');
    }
  }

  /// Convenience method for simple username/password authentication using OAuth2
  Future<TokenResponse> authenticate({
    required String username,
    required String password,
  }) async {
    return await getToken(username: username, password: password);
  }

  /// Get token with client credentials (OAuth2 flow)
  Future<TokenResponse> getTokenWithClientCredentials({
    required String username,
    required String password,
    required String clientId,
    required String clientSecret,
    String? scope,
  }) async {
    return await getToken(
      username: username,
      password: password,
      clientId: clientId,
      clientSecret: clientSecret,
      scope: scope,
    );
  }

  /// Send password recovery email
  Future<PasswordRecoveryResponse> sendPasswordRecoveryEmail({
    required String email,
  }) async {
    final url = Uri.parse('$domain/v1/password-reset/request');
    final request = PasswordRecoveryRequest(email: email);

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PasswordRecoveryResponse.fromJson(data);
        } else {
          throw AuthServiceException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException('Error sending password recovery email: $e');
    }
  }

  /// Confirm password reset with token
  Future<PasswordResetConfirmResponse> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    final url = Uri.parse('$domain/v1/password-reset/confirm');
    final request = PasswordResetConfirmRequest(
      token: token,
      newPassword: newPassword,
    );

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PasswordResetConfirmResponse.fromJson(data);
        } else {
          throw AuthServiceException('Unexpected response format');
        }
      });
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException('Error confirming password reset: $e');
    }
  }

  /// Complete authentication flow: login + get user info
  Future<AuthResult> authenticateAndGetUser({
    required String email,
    required String password,
  }) async {
    try {
      final tokenResponse = await login(email: email, password: password);
      final user = await getCurrentUser();

      return AuthResult(token: tokenResponse, user: user);
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw AuthServiceException('Error during authentication flow: $e');
    }
  }
}

// Helper class to return both token and user info
class AuthResult {
  final TokenResponse token;
  final User user;

  AuthResult({required this.token, required this.user});
}

// Example usage:
/*
void main() async {
  final authService = ClaudeAuthService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  try {
    // Admin login (recommended for most use cases)
    print('--- Admin Login ---');
    final loginResult = await authService.authenticateAndGetUser(
      email: 'admin@example.com',
      password: 'admin_password',
    );
    print('Login successful!');
    print('User: ${loginResult.user.email} (${loginResult.user.fullName})');
    print('Token: ${loginResult.token.accessToken}');

    // OAuth2 authentication (alternative method)
    print('\n--- OAuth2 Authentication ---');
    final tokenResponse = await authService.authenticate(
      username: 'user@example.com',
      password: 'secure_password123',
    );
    print('OAuth2 Authentication successful!');
    print('Access Token: ${tokenResponse.accessToken}');

    // Register first superadmin (dev only)
    print('\n--- Register First Superadmin ---');
    try {
      final newUser = await authService.register(
        email: 'superadmin@example.com',
        fullName: 'Super Admin',
        password: 'secure_password123',
      );
      print('Registration successful!');
      print('User: ${newUser.email} (${newUser.fullName})');
    } on ForbiddenException catch (e) {
      print('Registration not allowed: ${e.message}');
    }

    // Get current user info (requires authentication)
    print('\n--- Get Current User ---');
    final currentUser = await authService.getCurrentUser();
    print('Current user: ${currentUser.email}');
    print('Is superadmin: ${currentUser.isPlatformSuperadmin}');

  } on UnauthorizedException catch (e) {
    print('Authentication failed: ${e.message}');
  } on ValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on BadRequestException catch (e) {
    print('Bad request: ${e.apiError.detail}');
  } on ForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
  } on AuthServiceException catch (e) {
    print('Auth service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
*/
