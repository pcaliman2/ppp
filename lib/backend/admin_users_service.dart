import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Reuse User model from auth service
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

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, isActive: $isActive, isPlatformSuperadmin: $isPlatformSuperadmin)';
  }
}

// Request models
class CreateUserRequest {
  final String email;
  final String fullName;
  final String password;

  CreateUserRequest({
    required this.email,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'full_name': fullName, 'password': password};
  }
}

class CreateSuperAdminRequest {
  final String email;
  final String fullName;
  final String password;

  CreateSuperAdminRequest({
    required this.email,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'full_name': fullName, 'password': password};
  }
}

// Response models
class CreateSuperAdminResponse {
  final String message;

  CreateSuperAdminResponse({required this.message});

  factory CreateSuperAdminResponse.fromString(String message) {
    return CreateSuperAdminResponse(message: message);
  }

  factory CreateSuperAdminResponse.fromJson(Map<String, dynamic> json) {
    return CreateSuperAdminResponse(
      message: json['message'] ?? json.toString(),
    );
  }
}

// Custom Exceptions (reuse from auth service)
class AdminUsersServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminUsersServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminUsersServiceException: $message';
}

class ValidationException extends AdminUsersServiceException {
  final ValidationError validationError;

  ValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class BadRequestException extends AdminUsersServiceException {
  final ApiError apiError;

  BadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class UnauthorizedException extends AdminUsersServiceException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AdminUsersServiceException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

// Admin Users Service
class ClaudeAdminUsersService {
  final String domain;
  String? _authToken;

  ClaudeAdminUsersService({required this.domain, String? authToken})
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
      throw AdminUsersServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get list of all users (superadmin only)
  Future<List<User>> getUsers() async {
    final url = Uri.parse('$domain/admin/users');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (userJson) => User.fromJson(userJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminUsersServiceException(
            'Expected list of users, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error getting users: $e');
    }
  }

  /// Create a new user (superadmin only)
  Future<User> createUser({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final url = Uri.parse('$domain/admin/users');
    final request = CreateUserRequest(
      email: email,
      fullName: fullName,
      password: password,
    );

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return User.fromJson(data);
        } else {
          throw AdminUsersServiceException(
            'Expected user object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error creating user: $e');
    }
  }

  /// Create a new platform super-admin (superadmin only)
  Future<CreateSuperAdminResponse> createSuperAdmin({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final url = Uri.parse('$domain/admin/users/superadmins');
    final request = CreateSuperAdminRequest(
      email: email,
      fullName: fullName,
      password: password,
    );

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is String) {
          return CreateSuperAdminResponse.fromString(data);
        } else if (data is Map<String, dynamic>) {
          return CreateSuperAdminResponse.fromJson(data);
        } else {
          throw AdminUsersServiceException(
            'Unexpected response format: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error creating super admin: $e');
    }
  }

  /// Get users with pagination (if supported by API in the future)
  Future<List<User>> getUsersPaginated({
    int? limit,
    int? offset,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse(
      '$domain/admin/users',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (userJson) => User.fromJson(userJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminUsersServiceException(
            'Expected list of users, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException(
        'Error getting users with pagination: $e',
      );
    }
  }

  /// Get users count (helper method)
  Future<int> getUsersCount() async {
    try {
      final users = await getUsers();
      return users.length;
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error getting users count: $e');
    }
  }

  /// Get only superadmin users (filter from all users)
  Future<List<User>> getSuperAdmins() async {
    try {
      final users = await getUsers();
      return users.where((user) => user.isPlatformSuperadmin).toList();
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error getting super admins: $e');
    }
  }

  /// Get only regular users (non-superadmin)
  Future<List<User>> getRegularUsers() async {
    try {
      final users = await getUsers();
      return users.where((user) => !user.isPlatformSuperadmin).toList();
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error getting regular users: $e');
    }
  }

  /// Get active users only
  Future<List<User>> getActiveUsers() async {
    try {
      final users = await getUsers();
      return users.where((user) => user.isActive).toList();
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error getting active users: $e');
    }
  }

  /// Search users by email or name (client-side filtering)
  Future<List<User>> searchUsers(String query) async {
    try {
      final users = await getUsers();
      final lowercaseQuery = query.toLowerCase();

      return users
          .where(
            (user) =>
                user.email.toLowerCase().contains(lowercaseQuery) ||
                user.fullName.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      if (e is AdminUsersServiceException) rethrow;
      throw AdminUsersServiceException('Error searching users: $e');
    }
  }
}

// Factory method to create service from auth service
class ClaudeAdminUsersServiceFactory {
  static ClaudeAdminUsersService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminUsersService(domain: domain, authToken: authToken);
  }
}

// Example usage:
/*
void main() async {
  // Create service with auth token
  final adminUsersService = ClaudeAdminUsersService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here',
  );

  try {
    // Get all users
    print('--- Getting All Users ---');
    final users = await adminUsersService.getUsers();
    print('Found ${users.length} users:');
    for (final user in users) {
      print('- ${user.email} (${user.fullName}) - Superadmin: ${user.isPlatformSuperadmin}');
    }

    // Create a new regular user
    print('\n--- Creating Regular User ---');
    final newUser = await adminUsersService.createUser(
      email: 'newuser@example.com',
      fullName: 'New User',
      password: 'securepassword123',
    );
    print('Created user: ${newUser.email} (${newUser.fullName})');
    print('User ID: ${newUser.id}');
    print('Is Superadmin: ${newUser.isPlatformSuperadmin}');

    // Create a new super admin
    print('\n--- Creating Super Admin ---');
    final superAdminResult = await adminUsersService.createSuperAdmin(
      email: 'newsuperadmin@example.com',
      fullName: 'New Super Admin',
      password: 'supersecurepassword123',
    );
    print('Super admin creation result: ${superAdminResult.message}');

    // Get only superadmins
    print('\n--- Getting Super Admins ---');
    final superAdmins = await adminUsersService.getSuperAdmins();
    print('Found ${superAdmins.length} super admins:');
    for (final admin in superAdmins) {
      print('- ${admin.email} (${admin.fullName})');
    }

    // Get only regular users
    print('\n--- Getting Regular Users ---');
    final regularUsers = await adminUsersService.getRegularUsers();
    print('Found ${regularUsers.length} regular users:');
    for (final user in regularUsers) {
      print('- ${user.email} (${user.fullName})');
    }

    // Search users
    print('\n--- Searching Users ---');
    final searchResults = await adminUsersService.searchUsers('admin');
    print('Found ${searchResults.length} users matching "admin":');
    for (final user in searchResults) {
      print('- ${user.email} (${user.fullName})');
    }

    // Get users count
    print('\n--- Users Statistics ---');
    final totalUsers = await adminUsersService.getUsersCount();
    final activeUsers = await adminUsersService.getActiveUsers();
    print('Total users: $totalUsers');
    print('Active users: ${activeUsers.length}');

  } on UnauthorizedException catch (e) {
    print('Authentication failed: ${e.message}');
    print('Make sure you have a valid auth token and superadmin privileges');
  } on ValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on BadRequestException catch (e) {
    print('Bad request: ${e.apiError.detail}');
  } on ForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
    print('Make sure you have superadmin privileges');
  } on AdminUsersServiceException catch (e) {
    print('Admin users service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example with auth service:
/*
void integratedExample() async {
  final authService = ClaudeAuthService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  try {
    // First authenticate as superadmin
    final authResult = await authService.authenticateAndGetUser(
      email: 'superadmin@example.com',
      password: 'superadmin_password',
    );

    // Check if user is superadmin
    if (!authResult.user.isPlatformSuperadmin) {
      print('Error: User is not a superadmin');
      return;
    }

    // Create admin users service with the auth token
    final adminUsersService = ClaudeAdminUsersServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    // Now use the admin users service
    final users = await adminUsersService.getUsers();
    print('Total users: ${users.length}');

  } catch (e) {
    print('Error: $e');
  }
}
*/
*/
