import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Section model
class PageSection {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final int position;
  final bool isEnabled;

  PageSection({
    required this.id,
    required this.type,
    required this.data,
    required this.position,
    required this.isEnabled,
  });

  factory PageSection.fromJson(Map<String, dynamic> json) {
    return PageSection(
      id: json['id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      position: json['position'],
      isEnabled: json['is_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'position': position,
      'is_enabled': isEnabled,
    };
  }

  @override
  String toString() {
    return 'PageSection(id: $id, type: $type, position: $position, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageSection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy of this section with updated fields
  PageSection copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? data,
    int? position,
    bool? isEnabled,
  }) {
    return PageSection(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      position: position ?? this.position,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

// Page model
class Page {
  final String id;
  final String orgId;
  final String projectId;
  final String title;
  final String slug;
  final bool isHome;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PageSection>? sections;

  Page({
    required this.id,
    required this.orgId,
    required this.projectId,
    required this.title,
    required this.slug,
    required this.isHome,
    required this.createdAt,
    required this.updatedAt,
    this.sections,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'],
      orgId: json['org_id'],
      projectId: json['project_id'],
      title: json['title'],
      slug: json['slug'],
      isHome: json['is_home'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sections:
          json['sections'] != null
              ? (json['sections'] as List)
                  .map(
                    (sectionJson) => PageSection.fromJson(
                      sectionJson as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'project_id': projectId,
      'title': title,
      'slug': slug,
      'is_home': isHome,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (sections != null)
        'sections': sections!.map((section) => section.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Page(id: $id, orgId: $orgId, projectId: $projectId, title: $title, slug: $slug, isHome: $isHome, createdAt: $createdAt, updatedAt: $updatedAt, sections: ${sections?.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Page && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy of this page with updated fields
  Page copyWith({
    String? id,
    String? orgId,
    String? projectId,
    String? title,
    String? slug,
    bool? isHome,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PageSection>? sections,
  }) {
    return Page(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isHome: isHome ?? this.isHome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sections: sections ?? this.sections,
    );
  }
}

// Request models
class CreatePageRequest {
  final String projectId;
  final String title;
  final String slug;
  final bool isHome;

  CreatePageRequest({
    required this.projectId,
    required this.title,
    required this.slug,
    this.isHome = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'title': title,
      'slug': slug,
      'is_home': isHome,
    };
  }

  @override
  String toString() {
    return 'CreatePageRequest(projectId: $projectId, title: $title, slug: $slug, isHome: $isHome)';
  }
}

class UpdatePageRequest {
  final String? title;
  final String? slug;
  final bool? isHome;

  UpdatePageRequest({this.title, this.slug, this.isHome});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (slug != null) map['slug'] = slug;
    if (isHome != null) map['is_home'] = isHome;
    return map;
  }

  @override
  String toString() {
    return 'UpdatePageRequest(title: $title, slug: $slug, isHome: $isHome)';
  }
}

// Custom Exceptions
class AdminPagesServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminPagesServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminPagesServiceException: $message';
}

class PagesValidationException extends AdminPagesServiceException {
  final ValidationError validationError;

  PagesValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class PagesBadRequestException extends AdminPagesServiceException {
  final ApiError apiError;

  PagesBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class PagesUnauthorizedException extends AdminPagesServiceException {
  PagesUnauthorizedException(super.message) : super(statusCode: 401);
}

class PagesForbiddenException extends AdminPagesServiceException {
  PagesForbiddenException(super.message) : super(statusCode: 403);
}

class PagesConflictException extends AdminPagesServiceException {
  PagesConflictException(super.message) : super(statusCode: 409);
}

class PagesNotFoundException extends AdminPagesServiceException {
  PagesNotFoundException(super.message) : super(statusCode: 404);
}

// Admin Pages Service
class ClaudeAdminPagesService {
  final String domain;
  String? _authToken;

  ClaudeAdminPagesService({required this.domain, String? authToken})
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
      throw PagesBadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Unauthorized';
      throw PagesUnauthorizedException(detail);
    } else if (response.statusCode == 403) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Forbidden';
      throw PagesForbiddenException(detail);
    } else if (response.statusCode == 404) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Not found';
      throw PagesNotFoundException(detail);
    } else if (response.statusCode == 409) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Conflict';
      throw PagesConflictException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw PagesValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminPagesServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Create a new page (superadmin)
  Future<Page> createPage({
    required String projectId,
    required String title,
    required String slug,
    bool isHome = false,
  }) async {
    final url = Uri.parse('$domain/admin/pages');
    final request = CreatePageRequest(
      projectId: projectId,
      title: title,
      slug: slug,
      isHome: isHome,
    );

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Page.fromJson(data);
        } else {
          throw AdminPagesServiceException(
            'Expected page object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error creating page: $e');
    }
  }

  /// Get list of pages (by project)
  Future<List<Page>> getPages({required String projectId}) async {
    final queryParams = <String, String>{'project_id': projectId};

    final uri = Uri.parse(
      '$domain/admin/pages',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (pageJson) => Page.fromJson(pageJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminPagesServiceException(
            'Expected list of pages, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting pages: $e');
    }
  }

  /// Get page with sections (draft)
  Future<Page> getPageWithSections(String pageId) async {
    final url = Uri.parse('$domain/admin/pages/$pageId');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Page.fromJson(data);
        } else {
          throw AdminPagesServiceException(
            'Expected page object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting page with sections: $e');
    }
  }

  /// Update page metadata
  Future<Page> updatePage(
    String pageId, {
    String? title,
    String? slug,
    bool? isHome,
  }) async {
    final url = Uri.parse('$domain/admin/pages/$pageId');
    final request = UpdatePageRequest(title: title, slug: slug, isHome: isHome);

    try {
      final response = await http.patch(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Page.fromJson(data);
        } else {
          throw AdminPagesServiceException(
            'Expected page object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error updating page: $e');
    }
  }

  /// Delete page and its sections
  Future<void> deletePage(String pageId) async {
    final url = Uri.parse('$domain/admin/pages/$pageId');

    try {
      final response = await http.delete(url, headers: _getAuthHeaders());

      await _handleResponse(response, (data) {
        // 204 No Content response, no data to return
        return null;
      });
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error deleting page: $e');
    }
  }

  // Helper methods

  /// Get home page for a project
  Future<Page?> getHomePage(String projectId) async {
    try {
      final pages = await getPages(projectId: projectId);
      try {
        return pages.firstWhere((page) => page.isHome);
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting home page: $e');
    }
  }

  /// Get page by slug within a project
  Future<Page?> getPageBySlug(String projectId, String slug) async {
    try {
      final pages = await getPages(projectId: projectId);
      try {
        return pages.firstWhere((page) => page.slug == slug);
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting page by slug: $e');
    }
  }

  /// Get page by title within a project
  Future<Page?> getPageByTitle(String projectId, String title) async {
    try {
      final pages = await getPages(projectId: projectId);
      try {
        return pages.firstWhere(
          (page) => page.title.toLowerCase() == title.toLowerCase(),
        );
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting page by title: $e');
    }
  }

  /// Search pages by title or slug within a project
  Future<List<Page>> searchPages(String projectId, String query) async {
    try {
      final pages = await getPages(projectId: projectId);
      final lowercaseQuery = query.toLowerCase();

      return pages
          .where(
            (page) =>
                page.title.toLowerCase().contains(lowercaseQuery) ||
                page.slug.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error searching pages: $e');
    }
  }

  /// Get pages sorted by title
  Future<List<Page>> getPagesSortedByTitle(
    String projectId, {
    bool ascending = true,
  }) async {
    try {
      final pages = await getPages(projectId: projectId);
      pages.sort((a, b) {
        final comparison = a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        );
        return ascending ? comparison : -comparison;
      });
      return pages;
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException(
        'Error getting pages sorted by title: $e',
      );
    }
  }

  /// Get pages sorted by creation date
  Future<List<Page>> getPagesSortedByDate(
    String projectId, {
    bool newest = true,
  }) async {
    try {
      final pages = await getPages(projectId: projectId);
      pages.sort((a, b) {
        final comparison = a.createdAt.compareTo(b.createdAt);
        return newest ? -comparison : comparison;
      });
      return pages;
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException(
        'Error getting pages sorted by date: $e',
      );
    }
  }

  /// Check if page slug is available within a project
  Future<bool> isSlugAvailable(String projectId, String slug) async {
    try {
      final existingPage = await getPageBySlug(projectId, slug);
      return existingPage == null;
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error checking slug availability: $e');
    }
  }

  /// Check if page title is available within a project
  Future<bool> isTitleAvailable(String projectId, String title) async {
    try {
      final existingPage = await getPageByTitle(projectId, title);
      return existingPage == null;
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error checking title availability: $e');
    }
  }

  /// Generate a slug from page title (helper method)
  String generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }

  /// Create page with auto-generated slug if not provided
  Future<Page> createPageWithAutoSlug({
    required String projectId,
    required String title,
    String? slug,
    bool isHome = false,
  }) async {
    final finalSlug = slug ?? generateSlug(title);

    // Check if slug is available within the project
    final isAvailable = await isSlugAvailable(projectId, finalSlug);
    if (!isAvailable) {
      throw PagesConflictException(
        'Page slug "$finalSlug" is already taken in this project',
      );
    }

    return await createPage(
      projectId: projectId,
      title: title,
      slug: finalSlug,
      isHome: isHome,
    );
  }

  /// Get pages count for a project
  Future<int> getPagesCount(String projectId) async {
    try {
      final pages = await getPages(projectId: projectId);
      return pages.length;
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting pages count: $e');
    }
  }

  /// Set page as home page (and unset other home pages in the project)
  Future<Page> setAsHomePage(String pageId) async {
    try {
      // First get the page to know its project
      final page = await getPageWithSections(pageId);

      // Get all pages in the project
      final pages = await getPages(projectId: page.projectId);

      // If there's already a home page, unset it first
      final currentHomePage =
          pages.where((p) => p.isHome && p.id != pageId).firstOrNull;
      if (currentHomePage != null) {
        await updatePage(currentHomePage.id, isHome: false);
      }

      // Set this page as home
      return await updatePage(pageId, isHome: true);
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error setting page as home: $e');
    }
  }

  /// Get recent pages (sorted by creation date, newest first)
  Future<List<Page>> getRecentPages(String projectId, {int limit = 10}) async {
    try {
      final pages = await getPagesSortedByDate(projectId, newest: true);
      return pages.take(limit).toList();
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting recent pages: $e');
    }
  }

  /// Duplicate a page within the same project
  Future<Page> duplicatePage(
    String pageId, {
    String? newTitle,
    String? newSlug,
  }) async {
    try {
      final originalPage = await getPageWithSections(pageId);

      final duplicateTitle = newTitle ?? '${originalPage.title} (Copy)';
      final duplicateSlug = newSlug ?? generateSlug(duplicateTitle);

      // Create the new page
      return await createPageWithAutoSlug(
        projectId: originalPage.projectId,
        title: duplicateTitle,
        slug: duplicateSlug,
        isHome: false, // Duplicate should never be home page
      );
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error duplicating page: $e');
    }
  }

  /// Bulk delete pages
  Future<void> deletePages(List<String> pageIds) async {
    final errors = <String, Exception>{};

    for (final pageId in pageIds) {
      try {
        await deletePage(pageId);
      } catch (e) {
        errors[pageId] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty) {
      throw AdminPagesServiceException(
        'Failed to delete ${errors.length} pages: ${errors.keys.join(', ')}',
        details: errors,
      );
    }
  }

  /// Get page statistics for a project
  Future<Map<String, dynamic>> getPageStatistics(String projectId) async {
    try {
      final pages = await getPages(projectId: projectId);

      return {
        'total_pages': pages.length,
        'home_pages': pages.where((p) => p.isHome).length,
        'regular_pages': pages.where((p) => !p.isHome).length,
        'oldest_page':
            pages.isNotEmpty
                ? pages.reduce(
                  (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
                )
                : null,
        'newest_page':
            pages.isNotEmpty
                ? pages.reduce(
                  (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
                )
                : null,
      };
    } catch (e) {
      if (e is AdminPagesServiceException) rethrow;
      throw AdminPagesServiceException('Error getting page statistics: $e');
    }
  }
}

// Factory method to create service from auth service
class ClaudeAdminPagesServiceFactory {
  static ClaudeAdminPagesService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminPagesService(domain: domain, authToken: authToken);
  }
}
