import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Project model
class Project {
  final String id;
  final String orgId;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.orgId,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      orgId: json['org_id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'name': name,
      'slug': slug,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Project(id: $id, orgId: $orgId, name: $name, slug: $slug, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy of this project with updated fields
  Project copyWith({
    String? id,
    String? orgId,
    String? name,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Request models
class CreateProjectRequest {
  final String orgId;
  final String name;
  final String slug;

  CreateProjectRequest({
    required this.orgId,
    required this.name,
    required this.slug,
  });

  Map<String, dynamic> toJson() {
    return {'org_id': orgId, 'name': name, 'slug': slug};
  }

  @override
  String toString() {
    return 'CreateProjectRequest(orgId: $orgId, name: $name, slug: $slug)';
  }
}

// Custom Exceptions
class AdminProjectsServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminProjectsServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminProjectsServiceException: $message';
}

class ValidationException extends AdminProjectsServiceException {
  final ValidationError validationError;

  ValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class BadRequestException extends AdminProjectsServiceException {
  final ApiError apiError;

  BadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class UnauthorizedException extends AdminProjectsServiceException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AdminProjectsServiceException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class ConflictException extends AdminProjectsServiceException {
  ConflictException(super.message) : super(statusCode: 409);
}

class NotFoundException extends AdminProjectsServiceException {
  NotFoundException(super.message) : super(statusCode: 404);
}

// Admin Projects Service
class ClaudeAdminProjectsService {
  final String domain;
  String? _authToken;

  ClaudeAdminProjectsService({required this.domain, String? authToken})
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
    } else if (response.statusCode == 404) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Not found';
      throw NotFoundException(detail);
    } else if (response.statusCode == 409) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Conflict';
      throw ConflictException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw ValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminProjectsServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get list of projects (superadmin only)
  /// If orgId is provided, filters projects by organization
  Future<List<Project>> getProjects({String? orgId}) async {
    final queryParams = <String, String>{};
    if (orgId != null) {
      queryParams['org_id'] = orgId;
    }

    final uri = Uri.parse(
      '$domain/admin/projects',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (projectJson) =>
                    Project.fromJson(projectJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminProjectsServiceException(
            'Expected list of projects, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error getting projects: $e');
    }
  }

  /// Create a new project (superadmin only)
  Future<Project> createProject({
    required String orgId,
    required String name,
    required String slug,
  }) async {
    final url = Uri.parse('$domain/admin/projects');
    final request = CreateProjectRequest(orgId: orgId, name: name, slug: slug);

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Project.fromJson(data);
        } else {
          throw AdminProjectsServiceException(
            'Expected project object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error creating project: $e');
    }
  }

  // Helper methods

  /// Get all projects across all organizations
  Future<List<Project>> getAllProjects() async {
    return await getProjects();
  }

  /// Get projects for a specific organization
  Future<List<Project>> getProjectsByOrganization(String orgId) async {
    return await getProjects(orgId: orgId);
  }

  /// Get projects count
  Future<int> getProjectsCount({String? orgId}) async {
    try {
      final projects = await getProjects(orgId: orgId);
      return projects.length;
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error getting projects count: $e');
    }
  }

  /// Get projects count for specific organization
  Future<int> getProjectsCountByOrganization(String orgId) async {
    return await getProjectsCount(orgId: orgId);
  }

  /// Find project by slug within an organization
  Future<Project?> findProjectBySlug(String slug, {String? orgId}) async {
    try {
      final projects = await getProjects(orgId: orgId);
      try {
        return projects.firstWhere((project) => project.slug == slug);
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error finding project by slug: $e');
    }
  }

  /// Find project by name within an organization
  Future<Project?> findProjectByName(String name, {String? orgId}) async {
    try {
      final projects = await getProjects(orgId: orgId);
      try {
        return projects.firstWhere(
          (project) => project.name.toLowerCase() == name.toLowerCase(),
        );
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error finding project by name: $e');
    }
  }

  /// Find project by ID
  Future<Project?> findProjectById(String id) async {
    try {
      final projects = await getAllProjects();
      try {
        return projects.firstWhere((project) => project.id == id);
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error finding project by ID: $e');
    }
  }

  /// Search projects by name or slug
  Future<List<Project>> searchProjects(String query, {String? orgId}) async {
    try {
      final projects = await getProjects(orgId: orgId);
      final lowercaseQuery = query.toLowerCase();

      return projects
          .where(
            (project) =>
                project.name.toLowerCase().contains(lowercaseQuery) ||
                project.slug.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error searching projects: $e');
    }
  }

  /// Get projects sorted by name
  Future<List<Project>> getProjectsSortedByName({
    String? orgId,
    bool ascending = true,
  }) async {
    try {
      final projects = await getProjects(orgId: orgId);
      projects.sort((a, b) {
        final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return ascending ? comparison : -comparison;
      });
      return projects;
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error getting sorted projects: $e');
    }
  }

  /// Get projects sorted by creation date
  Future<List<Project>> getProjectsSortedByDate({
    String? orgId,
    bool newest = true,
  }) async {
    try {
      final projects = await getProjects(orgId: orgId);
      projects.sort((a, b) {
        final comparison = a.createdAt.compareTo(b.createdAt);
        return newest ? -comparison : comparison;
      });
      return projects;
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException(
        'Error getting projects sorted by date: $e',
      );
    }
  }

  /// Check if project slug is available within an organization
  Future<bool> isSlugAvailable(String slug, String orgId) async {
    try {
      final existingProject = await findProjectBySlug(slug, orgId: orgId);
      return existingProject == null;
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException(
        'Error checking slug availability: $e',
      );
    }
  }

  /// Check if project name is available within an organization
  Future<bool> isNameAvailable(String name, String orgId) async {
    try {
      final existingProject = await findProjectByName(name, orgId: orgId);
      return existingProject == null;
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException(
        'Error checking name availability: $e',
      );
    }
  }

  /// Generate a slug from project name (helper method)
  String generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }

  /// Create project with auto-generated slug if not provided
  Future<Project> createProjectWithAutoSlug({
    required String orgId,
    required String name,
    String? slug,
  }) async {
    final finalSlug = slug ?? generateSlug(name);

    // Check if slug is available within the organization
    final isAvailable = await isSlugAvailable(finalSlug, orgId);
    if (!isAvailable) {
      throw ConflictException(
        'Project slug "$finalSlug" is already taken in this organization',
      );
    }

    return await createProject(orgId: orgId, name: name, slug: finalSlug);
  }

  /// Get projects grouped by organization
  Future<Map<String, List<Project>>> getProjectsGroupedByOrganization() async {
    try {
      final projects = await getAllProjects();
      final Map<String, List<Project>> grouped = {};

      for (final project in projects) {
        if (!grouped.containsKey(project.orgId)) {
          grouped[project.orgId] = [];
        }
        grouped[project.orgId]!.add(project);
      }

      return grouped;
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException(
        'Error grouping projects by organization: $e',
      );
    }
  }

  /// Get projects with pagination (if supported by API in the future)
  Future<List<Project>> getProjectsPaginated({
    String? orgId,
    int? limit,
    int? offset,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (orgId != null) queryParams['org_id'] = orgId;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse(
      '$domain/admin/projects',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (projectJson) =>
                    Project.fromJson(projectJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminProjectsServiceException(
            'Expected list of projects, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException(
        'Error getting projects with pagination: $e',
      );
    }
  }

  /// Get recent projects (sorted by creation date, newest first)
  Future<List<Project>> getRecentProjects({
    String? orgId,
    int limit = 10,
  }) async {
    try {
      final projects = await getProjectsSortedByDate(
        orgId: orgId,
        newest: true,
      );
      return projects.take(limit).toList();
    } catch (e) {
      if (e is AdminProjectsServiceException) rethrow;
      throw AdminProjectsServiceException('Error getting recent projects: $e');
    }
  }
}

// Factory method to create service from auth service
class ClaudeAdminProjectsServiceFactory {
  static ClaudeAdminProjectsService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminProjectsService(domain: domain, authToken: authToken);
  }
}

// Example usage:
/*
void main() async {
  // Create service with auth token
  final adminProjectsService = ClaudeAdminProjectsService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here',
  );

  try {
    // Get all projects
    print('--- Getting All Projects ---');
    final allProjects = await adminProjectsService.getAllProjects();
    print('Found ${allProjects.length} projects across all organizations:');
    for (final project in allProjects) {
      print('- ${project.name} (${project.slug}) - Org: ${project.orgId}');
    }

    // Get projects for specific organization
    print('\n--- Getting Projects for Organization ---');
    const orgId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
    final orgProjects = await adminProjectsService.getProjectsByOrganization(orgId);
    print('Found ${orgProjects.length} projects for organization $orgId:');
    for (final project in orgProjects) {
      print('- ${project.name} (${project.slug})');
    }

    // Create a new project
    print('\n--- Creating Project ---');
    final newProject = await adminProjectsService.createProject(
      orgId: orgId,
      name: 'Mobile App',
      slug: 'mobile-app',
    );
    print('Created project: ${newProject.name}');
    print('Project ID: ${newProject.id}');
    print('Slug: ${newProject.slug}');
    print('Organization: ${newProject.orgId}');

    // Create project with auto-generated slug
    print('\n--- Creating Project with Auto Slug ---');
    final autoSlugProject = await adminProjectsService.createProjectWithAutoSlug(
      orgId: orgId,
      name: 'Web Dashboard v2',
    );
    print('Created project: ${autoSlugProject.name}');
    print('Auto-generated slug: ${autoSlugProject.slug}');

    // Search projects within organization
    print('\n--- Searching Projects ---');
    final searchResults = await adminProjectsService.searchProjects('app', orgId: orgId);
    print('Found ${searchResults.length} projects matching "app" in organization:');
    for (final project in searchResults) {
      print('- ${project.name} (${project.slug})');
    }

    // Find project by slug
    print('\n--- Finding Project by Slug ---');
    final foundProject = await adminProjectsService.findProjectBySlug('mobile-app', orgId: orgId);
    if (foundProject != null) {
      print('Found project: ${foundProject.name}');
    } else {
      print('Project not found');
    }

    // Check slug availability
    print('\n--- Checking Slug Availability ---');
    final isAvailable = await adminProjectsService.isSlugAvailable('new-feature', orgId);
    print('Slug "new-feature" is ${isAvailable ? 'available' : 'taken'} in organization');

    // Get projects sorted by name
    print('\n--- Getting Projects Sorted by Name ---');
    final sortedProjects = await adminProjectsService.getProjectsSortedByName(orgId: orgId);
    print('Projects sorted by name for organization:');
    for (final project in sortedProjects) {
      print('- ${project.name}');
    }

    // Get recent projects
    print('\n--- Getting Recent Projects ---');
    final recentProjects = await adminProjectsService.getRecentProjects(orgId: orgId, limit: 5);
    print('Recent projects (limit 5) for organization:');
    for (final project in recentProjects) {
      print('- ${project.name} (created: ${project.createdAt})');
    }

    // Get projects grouped by organization
    print('\n--- Getting Projects Grouped by Organization ---');
    final groupedProjects = await adminProjectsService.getProjectsGroupedByOrganization();
    print('Projects grouped by organization:');
    groupedProjects.forEach((orgId, projects) {
      print('Organization $orgId: ${projects.length} projects');
      for (final project in projects) {
        print('  - ${project.name}');
      }
    });

    // Get project statistics
    print('\n--- Project Statistics ---');
    final totalProjects = await adminProjectsService.getProjectsCount();
    final orgProjectsCount = await adminProjectsService.getProjectsCountByOrganization(orgId);
    print('Total projects across all organizations: $totalProjects');
    print('Projects in organization $orgId: $orgProjectsCount');

  } on UnauthorizedException catch (e) {
    print('Authentication failed: ${e.message}');
    print('Make sure you have a valid auth token and superadmin privileges');
  } on ValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on ConflictException catch (e) {
    print('Conflict error: ${e.message}');
    print('This usually means the project name or slug already exists in the organization');
  } on NotFoundException catch (e) {
    print('Not found: ${e.message}');
  } on BadRequestException catch (e) {
    print('Bad request: ${e.apiError.detail}');
  } on ForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
    print('Make sure you have superadmin privileges');
  } on AdminProjectsServiceException catch (e) {
    print('Admin projects service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example with auth service and organizations:
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

    // Create admin projects service with the auth token
    final adminProjectsService = ClaudeAdminProjectsServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    // Also create organizations service to get organization info
    final adminOrgsService = ClaudeAdminOrgsServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    // Get organizations first
    final orgs = await adminOrgsService.getOrganizations();
    if (orgs.isEmpty) {
      print('No organizations found. Create an organization first.');
      return;
    }

    final firstOrg = orgs.first;
    print('Using organization: ${firstOrg.name} (${firstOrg.id})');

    // Now use the admin projects service
    final projects = await adminProjectsService.getProjectsByOrganization(firstOrg.id);
    print('Total projects in ${firstOrg.name}: ${projects.length}');

    // Create a new project
    final newProject = await adminProjectsService.createProject(
      orgId: firstOrg.id,
      name: 'My New Project',
      slug: 'my-new-project',
    );
    print('Created: ${newProject.name} in ${firstOrg.name}');

  } catch (e) {
    print('Error: $e');
  }
}
*/
*/
