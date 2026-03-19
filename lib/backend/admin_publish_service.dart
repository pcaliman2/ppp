import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Response models
class PageVersionResponse {
  final String id;
  final String label;
  final String state;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String? publishedBy;

  PageVersionResponse({
    required this.id,
    required this.label,
    required this.state,
    required this.createdAt,
    this.publishedAt,
    this.publishedBy,
  });

  factory PageVersionResponse.fromJson(Map<String, dynamic> json) {
    return PageVersionResponse(
      id: json['id'],
      label: json['label'],
      state: json['state'],
      createdAt: DateTime.parse(json['created_at']),
      publishedAt:
          json['published_at'] != null
              ? DateTime.parse(json['published_at'])
              : null,
      publishedBy: json['published_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'state': state,
      'created_at': createdAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'published_by': publishedBy,
    };
  }

  @override
  String toString() {
    return 'PageVersionResponse(id: $id, label: $label, state: $state, '
        'createdAt: $createdAt, publishedAt: $publishedAt, publishedBy: $publishedBy)';
  }

  /// Check if this version is published
  bool get isPublished => state == 'published' && publishedAt != null;

  /// Check if this version is a draft
  bool get isDraft => state == 'draft';

  /// Get time since creation
  Duration get timeSinceCreation => DateTime.now().difference(createdAt);

  /// Get time since publication (if published)
  Duration? get timeSincePublication =>
      publishedAt != null ? DateTime.now().difference(publishedAt!) : null;
}

class PageVersionsListResponse {
  final List<PageVersionResponse> items;

  PageVersionsListResponse({required this.items});

  factory PageVersionsListResponse.fromJson(Map<String, dynamic> json) {
    return PageVersionsListResponse(
      items:
          (json['items'] as List<dynamic>)
              .map(
                (item) =>
                    PageVersionResponse.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((item) => item.toJson()).toList()};
  }

  @override
  String toString() {
    return 'PageVersionsListResponse(items: ${items.length} versions)';
  }

  /// Get the latest version
  PageVersionResponse? get latestVersion =>
      items.isNotEmpty ? items.first : null;

  /// Get published versions only
  List<PageVersionResponse> get publishedVersions =>
      items.where((version) => version.isPublished).toList();

  /// Get draft versions only
  List<PageVersionResponse> get draftVersions =>
      items.where((version) => version.isDraft).toList();

  /// Get currently published version
  PageVersionResponse? get currentlyPublished =>
      items.where((version) => version.isPublished).isNotEmpty
          ? items.where((version) => version.isPublished).first
          : null;
}

class PageVersionDetailResponse {
  final String pageId;
  final String state;
  final String snapshot;

  PageVersionDetailResponse({
    required this.pageId,
    required this.state,
    required this.snapshot,
  });

  factory PageVersionDetailResponse.fromJson(Map<String, dynamic> json) {
    return PageVersionDetailResponse(
      pageId: json['page_id'],
      state: json['state'],
      snapshot: json['snapshot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'page_id': pageId, 'state': state, 'snapshot': snapshot};
  }

  @override
  String toString() {
    return 'PageVersionDetailResponse(pageId: $pageId, state: $state, '
        'snapshot: ${snapshot.length} chars)';
  }

  /// Parse snapshot as JSON
  Map<String, dynamic>? get snapshotAsJson {
    try {
      return json.decode(snapshot) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Check if snapshot is valid JSON
  bool get hasValidJsonSnapshot => snapshotAsJson != null;
}

class PagePreviewResponse {
  final String pageId;
  final String state;
  final String snapshot;

  PagePreviewResponse({
    required this.pageId,
    required this.state,
    required this.snapshot,
  });

  factory PagePreviewResponse.fromJson(Map<String, dynamic> json) {
    return PagePreviewResponse(
      pageId: json['page_id'],
      state: json['state'],
      snapshot: json['snapshot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'page_id': pageId, 'state': state, 'snapshot': snapshot};
  }

  @override
  String toString() {
    return 'PagePreviewResponse(pageId: $pageId, state: $state, '
        'snapshot: ${snapshot.length} chars)';
  }

  /// Parse snapshot as JSON
  Map<String, dynamic>? get snapshotAsJson {
    try {
      return json.decode(snapshot) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Check if snapshot is valid JSON
  bool get hasValidJsonSnapshot => snapshotAsJson != null;
}

// Custom Exceptions
class AdminPublishServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminPublishServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminPublishServiceException: $message';
}

class PublishValidationException extends AdminPublishServiceException {
  final ValidationError validationError;

  PublishValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class PublishBadRequestException extends AdminPublishServiceException {
  final ApiError apiError;

  PublishBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class PublishUnauthorizedException extends AdminPublishServiceException {
  PublishUnauthorizedException(super.message) : super(statusCode: 401);
}

class PublishForbiddenException extends AdminPublishServiceException {
  PublishForbiddenException(super.message) : super(statusCode: 403);
}

class PublishNotFoundException extends AdminPublishServiceException {
  PublishNotFoundException(super.message) : super(statusCode: 404);
}

// Admin Publish Service
class ClaudeAdminPublishService {
  final String domain;
  String? _authToken;

  ClaudeAdminPublishService({required this.domain, String? authToken})
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
      throw PublishBadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Not authenticated';
      throw PublishUnauthorizedException(detail);
    } else if (response.statusCode == 403) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Forbidden';
      throw PublishForbiddenException(detail);
    } else if (response.statusCode == 404) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Page not found';
      throw PublishNotFoundException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw PublishValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminPublishServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Publish a page
  Future<PageVersionResponse> publishPage(String pageId) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/publish');

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode({}), // Empty JSON object as per API spec
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PageVersionResponse.fromJson(data);
        } else {
          throw AdminPublishServiceException(
            'Expected page version object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPublishServiceException) rethrow;
      throw AdminPublishServiceException('Error publishing page: $e');
    }
  }

  /// Get all versions of a page
  Future<PageVersionsListResponse> getPageVersions(String pageId) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/versions');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PageVersionsListResponse.fromJson(data);
        } else {
          throw AdminPublishServiceException(
            'Expected page versions list object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPublishServiceException) rethrow;
      throw AdminPublishServiceException('Error getting page versions: $e');
    }
  }

  /// Get a specific version of a page
  Future<PageVersionDetailResponse> getPageVersion(
    String pageId,
    String versionId,
  ) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/versions/$versionId');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PageVersionDetailResponse.fromJson(data);
        } else {
          throw AdminPublishServiceException(
            'Expected page version detail object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPublishServiceException) rethrow;
      throw AdminPublishServiceException('Error getting page version: $e');
    }
  }

  /// Rollback to a specific version
  Future<PageVersionResponse> rollbackToVersion(
    String pageId,
    String versionId,
  ) async {
    final url = Uri.parse(
      '$domain/admin/pages/$pageId/versions/$versionId/rollback',
    );

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode({}), // Empty JSON object as per API spec
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PageVersionResponse.fromJson(data);
        } else {
          throw AdminPublishServiceException(
            'Expected page version object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPublishServiceException) rethrow;
      throw AdminPublishServiceException('Error rolling back to version: $e');
    }
  }

  /// Get page preview
  Future<PagePreviewResponse> getPagePreview(String pageId) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/preview');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PagePreviewResponse.fromJson(data);
        } else {
          throw AdminPublishServiceException(
            'Expected page preview object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPublishServiceException) rethrow;
      throw AdminPublishServiceException('Error getting page preview: $e');
    }
  }

  /// Create a snapshot of a page
  Future<PageVersionResponse> createPageSnapshot(String pageId) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/snapshot');

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode({}), // Empty JSON object as per API spec
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return PageVersionResponse.fromJson(data);
        } else {
          throw AdminPublishServiceException(
            'Expected page version object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminPublishServiceException) rethrow;
      throw AdminPublishServiceException('Error creating page snapshot: $e');
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

  /// Validate if a version ID format is correct (basic UUID validation)
  bool isValidVersionId(String versionId) {
    return isValidPageId(versionId); // Same format as page ID
  }

  /// Publish page with validation
  Future<PageVersionResponse> publishPageWithValidation(String pageId) async {
    if (!isValidPageId(pageId)) {
      throw AdminPublishServiceException(
        'Invalid page ID format: $pageId',
        statusCode: 400,
      );
    }

    return publishPage(pageId);
  }

  /// Get page version with validation
  Future<PageVersionDetailResponse> getPageVersionWithValidation(
    String pageId,
    String versionId,
  ) async {
    if (!isValidPageId(pageId)) {
      throw AdminPublishServiceException(
        'Invalid page ID format: $pageId',
        statusCode: 400,
      );
    }

    if (!isValidVersionId(versionId)) {
      throw AdminPublishServiceException(
        'Invalid version ID format: $versionId',
        statusCode: 400,
      );
    }

    return getPageVersion(pageId, versionId);
  }

  /// Rollback with validation
  Future<PageVersionResponse> rollbackToVersionWithValidation(
    String pageId,
    String versionId,
  ) async {
    if (!isValidPageId(pageId)) {
      throw AdminPublishServiceException(
        'Invalid page ID format: $pageId',
        statusCode: 400,
      );
    }

    if (!isValidVersionId(versionId)) {
      throw AdminPublishServiceException(
        'Invalid version ID format: $versionId',
        statusCode: 400,
      );
    }

    return rollbackToVersion(pageId, versionId);
  }

  /// Bulk operations - publish multiple pages
  Future<Map<String, PageVersionResponse>> publishMultiplePages(
    List<String> pageIds,
  ) async {
    final results = <String, PageVersionResponse>{};
    final errors = <String, Exception>{};

    for (final pageId in pageIds) {
      try {
        final result = await publishPage(pageId);
        results[pageId] = result;
      } catch (e) {
        errors[pageId] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty && results.isEmpty) {
      throw AdminPublishServiceException(
        'Failed to publish any pages. Errors: $errors',
      );
    }

    return results;
  }

  /// Bulk operations - create snapshots for multiple pages
  Future<Map<String, PageVersionResponse>> createMultipleSnapshots(
    List<String> pageIds,
  ) async {
    final results = <String, PageVersionResponse>{};
    final errors = <String, Exception>{};

    for (final pageId in pageIds) {
      try {
        final result = await createPageSnapshot(pageId);
        results[pageId] = result;
      } catch (e) {
        errors[pageId] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty && results.isEmpty) {
      throw AdminPublishServiceException(
        'Failed to create any snapshots. Errors: $errors',
      );
    }

    return results;
  }
}

// Factory method to create service from auth service
class ClaudeAdminPublishServiceFactory {
  static ClaudeAdminPublishService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminPublishService(domain: domain, authToken: authToken);
  }

  static ClaudeAdminPublishService create(String domain, {String? authToken}) {
    return ClaudeAdminPublishService(domain: domain, authToken: authToken);
  }
}

// Page version manager for caching and management
class PageVersionManager {
  final ClaudeAdminPublishService _service;
  final Map<String, PageVersionsListResponse> _versionsCache = {};
  final Map<String, PageVersionDetailResponse> _versionDetailCache = {};

  PageVersionManager(this._service);

  /// Get page versions with caching
  Future<PageVersionsListResponse> getPageVersions(
    String pageId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _versionsCache.containsKey(pageId)) {
      return _versionsCache[pageId]!;
    }

    final versions = await _service.getPageVersions(pageId);
    _versionsCache[pageId] = versions;
    return versions;
  }

  /// Get specific version with caching
  Future<PageVersionDetailResponse> getPageVersion(
    String pageId,
    String versionId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$pageId:$versionId';

    if (!forceRefresh && _versionDetailCache.containsKey(cacheKey)) {
      return _versionDetailCache[cacheKey]!;
    }

    final versionDetail = await _service.getPageVersion(pageId, versionId);
    _versionDetailCache[cacheKey] = versionDetail;
    return versionDetail;
  }

  /// Publish page and invalidate cache
  Future<PageVersionResponse> publishPage(String pageId) async {
    final result = await _service.publishPage(pageId);
    _invalidatePageCache(pageId);
    return result;
  }

  /// Create snapshot and invalidate cache
  Future<PageVersionResponse> createSnapshot(String pageId) async {
    final result = await _service.createPageSnapshot(pageId);
    _invalidatePageCache(pageId);
    return result;
  }

  /// Rollback and invalidate cache
  Future<PageVersionResponse> rollbackToVersion(
    String pageId,
    String versionId,
  ) async {
    final result = await _service.rollbackToVersion(pageId, versionId);
    _invalidatePageCache(pageId);
    return result;
  }

  /// Get currently published version for a page
  Future<PageVersionResponse?> getCurrentlyPublishedVersion(
    String pageId,
  ) async {
    final versions = await getPageVersions(pageId);
    return versions.currentlyPublished;
  }

  /// Check if a page has any published versions
  Future<bool> hasPublishedVersions(String pageId) async {
    final versions = await getPageVersions(pageId);
    return versions.publishedVersions.isNotEmpty;
  }

  /// Get draft versions for a page
  Future<List<PageVersionResponse>> getDraftVersions(String pageId) async {
    final versions = await getPageVersions(pageId);
    return versions.draftVersions;
  }

  void _invalidatePageCache(String pageId) {
    _versionsCache.remove(pageId);
    _versionDetailCache.removeWhere((key, value) => key.startsWith('$pageId:'));
  }

  /// Clear all cached data
  void clearCache() {
    _versionsCache.clear();
    _versionDetailCache.clear();
  }

  /// Get cache info
  Map<String, dynamic> get cacheInfo => {
    'versions_cached': _versionsCache.length,
    'version_details_cached': _versionDetailCache.length,
  };
}

// Example usage:
/*
void main() async {
  // Create publish service with auth token
  final publishService = ClaudeAdminPublishService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here',
  );

  const pageId = '5ad01ffb-fc4f-482d-ba99-384738f05ea4';

  try {
    print('--- Publishing a Page ---');
    
    // Publish a page
    final publishResult = await publishService.publishPage(pageId);
    print('Page published successfully!');
    print('Version ID: ${publishResult.id}');
    print('State: ${publishResult.state}');
    print('Published at: ${publishResult.publishedAt}');
    print('Published by: ${publishResult.publishedBy}');
    
    print('\n--- Getting Page Versions ---');
    
    // Get all versions of a page
    final versions = await publishService.getPageVersions(pageId);
    print('Found ${versions.items.length} versions');
    
    for (final version in versions.items) {
      print('  Version ${version.id}: ${version.label} (${version.state})');
      print('    Created: ${version.createdAt}');
      if (version.publishedAt != null) {
        print('    Published: ${version.publishedAt}');
      }
    }
    
    // Get currently published version
    final currentPublished = versions.currentlyPublished;
    if (currentPublished != null) {
      print('Currently published version: ${currentPublished.id}');
    }
    
    print('\n--- Getting Version Details ---');
    
    if (versions.items.isNotEmpty) {
      final firstVersion = versions.items.first;
      final versionDetail = await publishService.getPageVersion(
        pageId, 
        firstVersion.id
      );
      
      print('Version detail for ${firstVersion.id}:');
      print('  Page ID: ${versionDetail.pageId}');
      print('  State: ${versionDetail.state}');
      print('  Snapshot size: ${versionDetail.snapshot.length} characters');
      print('  Valid JSON snapshot: ${versionDetail.hasValidJsonSnapshot}');
    }
    
    print('\n--- Creating Snapshot ---');
    
    // Create a snapshot
    final snapshotResult = await publishService.createPageSnapshot(pageId);
    print('Snapshot created!');
    print('Snapshot ID: ${snapshotResult.id}');
    print('Created at: ${snapshotResult.createdAt}');
    
    print('\n--- Getting Page Preview ---');
    
    // Get page preview
    final preview = await publishService.getPagePreview(pageId);
    print('Preview retrieved!');
    print('Page ID: ${preview.pageId}');
    print('State: ${preview.state}');
    print('Snapshot size: ${preview.snapshot.length} characters');
    
    print('\n--- Bulk Operations ---');
    
    // Bulk publish multiple pages
    final pageIds = [
      '5ad01ffb-fc4f-482d-ba99-384738f05ea4',
      '7bd02ffb-fc4f-482d-ba99-384738f05ea9',
    ];
    
    final bulkResults = await publishService.publishMultiplePages(pageIds);
    print('Bulk published ${bulkResults.length} pages');
    
    for (final entry in bulkResults.entries) {
      print('Page ${entry.key}: ${entry.value.state}');
    }
    
  } on PublishUnauthorizedException catch (e) {
    print('Publish unauthorized: ${e.message}');
    print('Make sure you have a valid auth token and proper permissions');
  } on PublishNotFoundException catch (e) {
    print('Page not found: ${e.message}');
    print('Check if the page ID exists and is accessible');
  } on PublishValidationException catch (e) {
    print('Publish validation error: ${e.validationError.detail}');
  } on PublishForbiddenException catch (e) {
    print('Publish forbidden: ${e.message}');
  } on AdminPublishServiceException catch (e) {
    print('Publish service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example with auth service and version manager:
void integratedPublishExample() async {
  final authService = ClaudeAuthService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  try {
    // First authenticate
    final authResult = await authService.authenticateAndGetUser(
      email: 'admin@example.com',
      password: 'admin_password',
    );

    // Create publish service with the auth token
    final publishService = ClaudeAdminPublishServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    // Create version manager for caching
    final versionManager = PageVersionManager(publishService);

    const pageId = '5ad01ffb-fc4f-482d-ba99-384738f05ea4';

    // Get page versions with caching
    final versions = await versionManager.getPageVersions(pageId);
    print('Cached versions: ${versions.items.length}');

    // Check if page has published versions
    final hasPublished = await versionManager.hasPublishedVersions(pageId);
    print('Has published versions: $hasPublished');

    // Get currently published version
    final currentPublished = await versionManager.getCurrentlyPublishedVersion(pageId);
    if (currentPublished != null) {
      print('Current published: ${currentPublished.id}');
    }

    // Publish page (will invalidate cache)
    final publishResult = await versionManager.publishPage(pageId);
    print('Published: ${publishResult.id}');

    // Create snapshot (will invalidate cache)
    final snapshotResult = await versionManager.createSnapshot(pageId);
    print('Snapshot created: ${snapshotResult.id}');

    // Show cache info
    print('Cache info: ${versionManager.cacheInfo}');

  } catch (e) {
    print('Error: $e');
  }
}

// Publishing workflow dashboard example:
void publishingDashboardExample() async {
  final publishService = ClaudeAdminPublishService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'admin_token',
  );

  final versionManager = PageVersionManager(publishService);

  // Simulate managing multiple pages
  final pageIds = [
    '5ad01ffb-fc4f-482d-ba99-384738f05ea4',
    '7bd02ffb-fc4f-482d-ba99-384738f05ea9',
    '9cd03ffb-fc4f-482d-ba99-384738f05eb1',
  ];

  try {
    print('=== Publishing Dashboard ===\n');

    for (final pageId in pageIds) {
      try {
        print('Processing page: $pageId');
        
        // Validate page ID format
        if (!publishService.isValidPageId(pageId)) {
          print('  ❌ Invalid page ID format');
          continue;
        }
        
        // Get versions
        final versions = await versionManager.getPageVersions(pageId);
        print('  📄 Total versions: ${versions.items.length}');
        print('  ✅ Published versions: ${versions.publishedVersions.length}');
        print('  📝 Draft versions: ${versions.draftVersions.length}');
        
        // Show currently published version
        final currentPublished = versions.currentlyPublished;
        if (currentPublished != null) {
          print('  🚀 Currently published: ${currentPublished.label}');
          print('     Published at: ${currentPublished.publishedAt}');
          print('     Published by: ${currentPublished.publishedBy}');
        } else {
          print('  ⏸️  No published version');
        }
        
        // Show latest version
        final latest = versions.latestVersion;
        if (latest != null) {
          print('  📋 Latest version: ${latest.label} (${latest.state})');
          print('     Created: ${latest.createdAt}');
          
          // Check if latest version is not published
          if (latest.isDraft) {
            print('     ⚠️  Latest version is unpublished draft');
          }
        }
        
        // Get preview
        try {
          final preview = await publishService.getPagePreview(pageId);
          print('  👁️  Preview available (${preview.snapshot.length} chars)');
        } catch (e) {
          print('  ❌ Preview unavailable: $e');
        }
        
      } catch (e) {
        print('  ❌ Error: $e');
      }
      
      print('');
    }

    // Show cache summary
    final cacheInfo = versionManager.cacheInfo;
    print('📊 Cache Summary:');
    print('   Versions cached: ${cacheInfo['versions_cached']}');
    print('   Version details cached: ${cacheInfo['version_details_cached']}');
    
  } catch (e) {
    print('Dashboard error: $e');
  }
}

// Advanced publishing workflow example:
void advancedPublishingWorkflowExample() async {
  final publishService = ClaudeAdminPublishService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'admin_token',
  );

  final versionManager = PageVersionManager(publishService);
  const pageId = '5ad01ffb-fc4f-482d-ba99-384738f05ea4';

  try {
    print('=== Advanced Publishing Workflow ===\n');

    // Step 1: Check current state
    print('1. Checking current page state...');
    final versions = await versionManager.getPageVersions(pageId);
    final currentPublished = versions.currentlyPublished;
    
    if (currentPublished != null) {
      print('   ✅ Page is currently published (version: ${currentPublished.id})');
      print('   📅 Published: ${currentPublished.publishedAt}');
      print('   👤 Published by: ${currentPublished.publishedBy}');
    } else {
      print('   ⏸️  Page is not currently published');
    }

    // Step 2: Create a backup snapshot before any changes
    print('\n2. Creating backup snapshot...');
    final backupSnapshot = await versionManager.createSnapshot(pageId);
    print('   💾 Backup created: ${backupSnapshot.id}');
    print('   📅 Created at: ${backupSnapshot.createdAt}');

    // Step 3: Show available draft versions
    print('\n3. Checking for draft versions...');
    final updatedVersions = await versionManager.getPageVersions(pageId, forceRefresh: true);
    final draftVersions = updatedVersions.draftVersions;
    
    if (draftVersions.isNotEmpty) {
      print('   📝 Found ${draftVersions.length} draft version(s):');
      for (final draft in draftVersions) {
        print('      - ${draft.id}: ${draft.label}');
        print('        Created: ${draft.createdAt}');
        print('        Age: ${draft.timeSinceCreation.inDays} days');
      }
    } else {
      print('   ℹ️  No draft versions found');
    }

    // Step 4: Simulate publishing the latest draft (if any)
    if (draftVersions.isNotEmpty) {
      final latestDraft = draftVersions.first;
      print('\n4. Publishing latest draft version...');
      print('   🚀 Publishing version: ${latestDraft.id}');
      
      try {
        final publishResult = await versionManager.publishPage(pageId);
        print('   ✅ Successfully published!');
        print('   🆔 New published version: ${publishResult.id}');
        print('   📅 Published at: ${publishResult.publishedAt}');
        print('   👤 Published by: ${publishResult.publishedBy}');
      } catch (e) {
        print('   ❌ Publishing failed: $e');
        
        // Step 5: Rollback to previous version if publishing fails
        if (currentPublished != null) {
          print('\n5. Rolling back to previous published version...');
          try {
            final rollbackResult = await versionManager.rollbackToVersion(
              pageId, 
              currentPublished.id
            );
            print('   ⏪ Rollback successful!');
            print('   🆔 Restored version: ${rollbackResult.id}');
          } catch (rollbackError) {
            print('   ❌ Rollback failed: $rollbackError');
          }
        }
      }
    } else {
      print('\n4. No draft versions to publish');
    }

    // Step 6: Final verification
    print('\n6. Final verification...');
    final finalVersions = await versionManager.getPageVersions(pageId, forceRefresh: true);
    final finalPublished = finalVersions.currentlyPublished;
    
    if (finalPublished != null) {
      print('   ✅ Page is published');
      print('   🆔 Current version: ${finalPublished.id}');
      print('   📅 Published: ${finalPublished.publishedAt}');
      
      // Check if this is a recent publication
      final timeSincePublication = finalPublished.timeSincePublication;
      if (timeSincePublication != null && timeSincePublication.inMinutes < 5) {
        print('   🆕 Recently published (${timeSincePublication.inMinutes} minutes ago)');
      }
    } else {
      print('   ⚠️  Page is not published');
    }

    print('\n✅ Workflow completed successfully!');

  } catch (e) {
    print('❌ Workflow error: $e');
  }
}

// Content management helper functions
class PagePublishingHelper {
  final ClaudeAdminPublishService _service;
  final PageVersionManager _versionManager;

  PagePublishingHelper(this._service) : _versionManager = PageVersionManager(_service);

  /// Check if a page is ready to publish
  Future<bool> isPageReadyToPublish(String pageId) async {
    try {
      final versions = await _versionManager.getPageVersions(pageId);
      final draftVersions = versions.draftVersions;
      
      // Page is ready if it has draft versions
      return draftVersions.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get publishing status summary for a page
  Future<Map<String, dynamic>> getPagePublishingStatus(String pageId) async {
    try {
      final versions = await _versionManager.getPageVersions(pageId);
      final currentPublished = versions.currentlyPublished;
      final draftVersions = versions.draftVersions;
      final latest = versions.latestVersion;

      return {
        'page_id': pageId,
        'is_published': currentPublished != null,
        'current_published_version': currentPublished?.id,
        'published_at': currentPublished?.publishedAt?.toIso8601String(),
        'published_by': currentPublished?.publishedBy,
        'has_drafts': draftVersions.isNotEmpty,
        'draft_count': draftVersions.length,
        'total_versions': versions.items.length,
        'latest_version_id': latest?.id,
        'latest_version_state': latest?.state,
        'ready_to_publish': draftVersions.isNotEmpty,
        'time_since_last_publish': currentPublished?.timeSincePublication?.inHours,
      };
    } catch (e) {
      return {
        'page_id': pageId,
        'error': e.toString(),
        'is_published': false,
        'ready_to_publish': false,
      };
    }
  }

  /// Safely publish a page with validation and backup
  Future<Map<String, dynamic>> safePublishPage(String pageId) async {
    try {
      // 1. Validate page ID
      if (!_service.isValidPageId(pageId)) {
        return {
          'success': false,
          'error': 'Invalid page ID format',
          'page_id': pageId,
        };
      }

      // 2. Check if page has drafts to publish
      final isReady = await isPageReadyToPublish(pageId);
      if (!isReady) {
        return {
          'success': false,
          'error': 'No draft versions available to publish',
          'page_id': pageId,
        };
      }

      // 3. Create backup snapshot
      final backup = await _versionManager.createSnapshot(pageId);

      // 4. Attempt to publish
      final publishResult = await _versionManager.publishPage(pageId);

      return {
        'success': true,
        'page_id': pageId,
        'published_version_id': publishResult.id,
        'published_at': publishResult.publishedAt?.toIso8601String(),
        'published_by': publishResult.publishedBy,
        'backup_snapshot_id': backup.id,
        'message': 'Page published successfully',
      };

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'page_id': pageId,
      };
    }
  }

  /// Bulk publish multiple pages with detailed results
  Future<Map<String, dynamic>> bulkPublishPages(List<String> pageIds) async {
    final results = <String, dynamic>{};
    final summary = {
      'total_pages': pageIds.length,
      'successful': 0,
      'failed': 0,
      'skipped': 0,
      'details': <String, dynamic>{},
    };

    for (final pageId in pageIds) {
      final result = await safePublishPage(pageId);
      results[pageId] = result;

      if (result['success'] == true) {
        summary['successful'] = (summary['successful'] as int) + 1;
      } else if (result['error']?.toString().contains('No draft versions') == true) {
        summary['skipped'] = (summary['skipped'] as int) + 1;
      } else {
        summary['failed'] = (summary['failed'] as int) + 1;
      }
    }

    summary['details'] = results;
    return summary;
  }

  /// Get comprehensive dashboard data for multiple pages
  Future<Map<String, dynamic>> getDashboardData(List<String> pageIds) async {
    final pageStatuses = <String, dynamic>{};
    int totalPublished = 0;
    int totalDrafts = 0;
    int totalReadyToPublish = 0;

    for (final pageId in pageIds) {
      final status = await getPagePublishingStatus(pageId);
      pageStatuses[pageId] = status;

      if (status['is_published'] == true) totalPublished++;
      if (status['has_drafts'] == true) totalDrafts++;
      if (status['ready_to_publish'] == true) totalReadyToPublish++;
    }

    return {
      'summary': {
        'total_pages': pageIds.length,
        'published_pages': totalPublished,
        'pages_with_drafts': totalDrafts,
        'ready_to_publish': totalReadyToPublish,
        'unpublished_pages': pageIds.length - totalPublished,
      },
      'pages': pageStatuses,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }
}
*/
