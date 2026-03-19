import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Organization model
class Organization {
  final String id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, slug: $slug, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Organization && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy of this organization with updated fields
  Organization copyWith({
    String? id,
    String? name,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Request models
class CreateOrganizationRequest {
  final String name;
  final String slug;

  CreateOrganizationRequest({required this.name, required this.slug});

  Map<String, dynamic> toJson() {
    return {'name': name, 'slug': slug};
  }

  @override
  String toString() {
    return 'CreateOrganizationRequest(name: $name, slug: $slug)';
  }
}

// Custom Exceptions
class AdminOrgsServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminOrgsServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminOrgsServiceException: $message';
}

class ValidationException extends AdminOrgsServiceException {
  final ValidationError validationError;

  ValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class BadRequestException extends AdminOrgsServiceException {
  final ApiError apiError;

  BadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class UnauthorizedException extends AdminOrgsServiceException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AdminOrgsServiceException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class ConflictException extends AdminOrgsServiceException {
  ConflictException(super.message) : super(statusCode: 409);
}

// Admin Organizations Service
class ClaudeAdminOrgsService {
  final String domain;
  String? _authToken;

  ClaudeAdminOrgsService({required this.domain, String? authToken})
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
    } else if (response.statusCode == 409) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Conflict';
      throw ConflictException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw ValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminOrgsServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get list of all organizations (superadmin only)
  Future<List<Organization>> getOrganizations() async {
    final url = Uri.parse('$domain/admin/orgs');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (orgJson) =>
                    Organization.fromJson(orgJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminOrgsServiceException(
            'Expected list of organizations, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error getting organizations: $e');
    }
  }

  /// Create a new organization (superadmin only)
  Future<Organization> createOrganization({
    required String name,
    required String slug,
  }) async {
    final url = Uri.parse('$domain/admin/orgs');
    final request = CreateOrganizationRequest(name: name, slug: slug);

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Organization.fromJson(data);
        } else {
          throw AdminOrgsServiceException(
            'Expected organization object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error creating organization: $e');
    }
  }

  // Helper methods

  /// Get organizations count
  Future<int> getOrganizationsCount() async {
    try {
      final orgs = await getOrganizations();
      return orgs.length;
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error getting organizations count: $e');
    }
  }

  /// Find organization by slug
  Future<Organization?> findOrganizationBySlug(String slug) async {
    try {
      final orgs = await getOrganizations();
      try {
        return orgs.firstWhere((org) => org.slug == slug);
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error finding organization by slug: $e');
    }
  }

  /// Find organization by name
  Future<Organization?> findOrganizationByName(String name) async {
    try {
      final orgs = await getOrganizations();
      try {
        return orgs.firstWhere(
          (org) => org.name.toLowerCase() == name.toLowerCase(),
        );
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error finding organization by name: $e');
    }
  }

  /// Find organization by ID
  Future<Organization?> findOrganizationById(String id) async {
    try {
      final orgs = await getOrganizations();
      try {
        return orgs.firstWhere((org) => org.id == id);
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error finding organization by ID: $e');
    }
  }

  /// Search organizations by name or slug (client-side filtering)
  Future<List<Organization>> searchOrganizations(String query) async {
    try {
      final orgs = await getOrganizations();
      final lowercaseQuery = query.toLowerCase();

      return orgs
          .where(
            (org) =>
                org.name.toLowerCase().contains(lowercaseQuery) ||
                org.slug.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error searching organizations: $e');
    }
  }

  /// Get organizations sorted by name
  Future<List<Organization>> getOrganizationsSortedByName({
    bool ascending = true,
  }) async {
    try {
      final orgs = await getOrganizations();
      orgs.sort((a, b) {
        final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return ascending ? comparison : -comparison;
      });
      return orgs;
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error getting sorted organizations: $e');
    }
  }

  /// Get organizations sorted by creation date
  Future<List<Organization>> getOrganizationsSortedByDate({
    bool newest = true,
  }) async {
    try {
      final orgs = await getOrganizations();
      orgs.sort((a, b) {
        final comparison = a.createdAt.compareTo(b.createdAt);
        return newest ? -comparison : comparison;
      });
      return orgs;
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException(
        'Error getting organizations sorted by date: $e',
      );
    }
  }

  /// Check if organization slug is available
  Future<bool> isSlugAvailable(String slug) async {
    try {
      final existingOrg = await findOrganizationBySlug(slug);
      return existingOrg == null;
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error checking slug availability: $e');
    }
  }

  /// Check if organization name is available
  Future<bool> isNameAvailable(String name) async {
    try {
      final existingOrg = await findOrganizationByName(name);
      return existingOrg == null;
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException('Error checking name availability: $e');
    }
  }

  /// Generate a slug from organization name (helper method)
  String generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }

  /// Create organization with auto-generated slug if not provided
  Future<Organization> createOrganizationWithAutoSlug({
    required String name,
    String? slug,
  }) async {
    final finalSlug = slug ?? generateSlug(name);

    // Check if slug is available
    final isAvailable = await isSlugAvailable(finalSlug);
    if (!isAvailable) {
      throw ConflictException(
        'Organization slug "$finalSlug" is already taken',
      );
    }

    return await createOrganization(name: name, slug: finalSlug);
  }

  /// Get organizations with pagination (if supported by API in the future)
  Future<List<Organization>> getOrganizationsPaginated({
    int? limit,
    int? offset,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse(
      '$domain/admin/orgs',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (orgJson) =>
                    Organization.fromJson(orgJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminOrgsServiceException(
            'Expected list of organizations, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminOrgsServiceException) rethrow;
      throw AdminOrgsServiceException(
        'Error getting organizations with pagination: $e',
      );
    }
  }
}

// Factory method to create service from auth service
class ClaudeAdminOrgsServiceFactory {
  static ClaudeAdminOrgsService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminOrgsService(domain: domain, authToken: authToken);
  }
}

// Example usage:
/*
void main() async {
  // Create service with auth token
  final adminOrgsService = ClaudeAdminOrgsService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here',
  );

  try {
    // Get all organizations
    print('--- Getting All Organizations ---');
    final orgs = await adminOrgsService.getOrganizations();
    print('Found ${orgs.length} organizations:');
    for (final org in orgs) {
      print('- ${org.name} (${org.slug}) - Created: ${org.createdAt}');
    }

    // Create a new organization
    print('\n--- Creating Organization ---');
    final newOrg = await adminOrgsService.createOrganization(
      name: 'Acme Corporation',
      slug: 'acme-corp',
    );
    print('Created organization: ${newOrg.name}');
    print('Organization ID: ${newOrg.id}');
    print('Slug: ${newOrg.slug}');

    // Create organization with auto-generated slug
    print('\n--- Creating Organization with Auto Slug ---');
    final autoSlugOrg = await adminOrgsService.createOrganizationWithAutoSlug(
      name: 'Tech Innovations LLC',
    );
    print('Created organization: ${autoSlugOrg.name}');
    print('Auto-generated slug: ${autoSlugOrg.slug}');

    // Search organizations
    print('\n--- Searching Organizations ---');
    final searchResults = await adminOrgsService.searchOrganizations('corp');
    print('Found ${searchResults.length} organizations matching "corp":');
    for (final org in searchResults) {
      print('- ${org.name} (${org.slug})');
    }

    // Find organization by slug
    print('\n--- Finding Organization by Slug ---');
    final foundOrg = await adminOrgsService.findOrganizationBySlug('acme-corp');
    if (foundOrg != null) {
      print('Found organization: ${foundOrg.name}');
    } else {
      print('Organization not found');
    }

    // Check slug availability
    print('\n--- Checking Slug Availability ---');
    final isAvailable = await adminOrgsService.isSlugAvailable('new-company');
    print('Slug "new-company" is ${isAvailable ? 'available' : 'taken'}');

    // Get organizations sorted by name
    print('\n--- Getting Organizations Sorted by Name ---');
    final sortedOrgs = await adminOrgsService.getOrganizationsSortedByName();
    print('Organizations sorted by name:');
    for (final org in sortedOrgs) {
      print('- ${org.name}');
    }

    // Get organizations count
    print('\n--- Organizations Statistics ---');
    final totalOrgs = await adminOrgsService.getOrganizationsCount();
    print('Total organizations: $totalOrgs');

  } on UnauthorizedException catch (e) {
    print('Authentication failed: ${e.message}');
    print('Make sure you have a valid auth token and superadmin privileges');
  } on ValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on ConflictException catch (e) {
    print('Conflict error: ${e.message}');
    print('This usually means the organization name or slug already exists');
  } on BadRequestException catch (e) {
    print('Bad request: ${e.apiError.detail}');
  } on ForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
    print('Make sure you have superadmin privileges');
  } on AdminOrgsServiceException catch (e) {
    print('Admin orgs service error: ${e.message}');
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

    // Create admin orgs service with the auth token
    final adminOrgsService = ClaudeAdminOrgsServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    // Now use the admin orgs service
    final orgs = await adminOrgsService.getOrganizations();
    print('Total organizations: ${orgs.length}');

    // Create a new organization
    final newOrg = await adminOrgsService.createOrganization(
      name: 'My New Company',
      slug: 'my-new-company',
    );
    print('Created: ${newOrg.name}');

  } catch (e) {
    print('Error: $e');
  }
}
*/
*/
