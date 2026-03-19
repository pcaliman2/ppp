import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Enums for delivery parameters
enum PageState {
  published,
  draft;

  @override
  String toString() => name;
}

// Response models (flexible since API returns "string" but likely JSON)
class PageSnapshot {
  final String content;
  final Map<String, dynamic>? parsedContent;
  final String projectSlug;
  final String pageSlug;
  final PageState? state;

  PageSnapshot({
    required this.content,
    this.parsedContent,
    required this.projectSlug,
    required this.pageSlug,
    this.state,
  });

  factory PageSnapshot.fromString(
    String content,
    String projectSlug,
    String pageSlug, {
    PageState? state,
  }) {
    Map<String, dynamic>? parsed;
    try {
      parsed = json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      // Content might not be JSON, that's okay
      parsed = null;
    }

    return PageSnapshot(
      content: content,
      parsedContent: parsed,
      projectSlug: projectSlug,
      pageSlug: pageSlug,
      state: state,
    );
  }

  bool get isJson => parsedContent != null;

  T? getField<T>(String key) {
    if (parsedContent == null) return null;
    return parsedContent![key] as T?;
  }

  @override
  String toString() {
    return 'PageSnapshot(projectSlug: $projectSlug, pageSlug: $pageSlug, state: $state, isJson: $isJson)';
  }
}

class PagesListResponse {
  final String content;
  final List<dynamic>? parsedContent;
  final String projectSlug;

  PagesListResponse({
    required this.content,
    this.parsedContent,
    required this.projectSlug,
  });

  factory PagesListResponse.fromString(String content, String projectSlug) {
    List<dynamic>? parsed;
    try {
      final decodedContent = json.decode(content);
      if (decodedContent is List) {
        parsed = decodedContent;
      } else if (decodedContent is Map && decodedContent.containsKey('pages')) {
        parsed = decodedContent['pages'] as List?;
      }
    } catch (e) {
      // Content might not be JSON, that's okay
      parsed = null;
    }

    return PagesListResponse(
      content: content,
      parsedContent: parsed,
      projectSlug: projectSlug,
    );
  }

  bool get isJson => parsedContent != null;
  int get pageCount => parsedContent?.length ?? 0;

  List<String> get pageSlugs {
    if (parsedContent == null) return [];
    return parsedContent!
        .map((page) {
          if (page is Map<String, dynamic>) {
            return page['slug'] as String? ??
                page['page_slug'] as String? ??
                '';
          }
          return page.toString();
        })
        .where((slug) => slug.isNotEmpty)
        .toList();
  }

  @override
  String toString() {
    return 'PagesListResponse(projectSlug: $projectSlug, pageCount: $pageCount, isJson: $isJson)';
  }
}

// Custom Exceptions
class DeliveryServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  DeliveryServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'DeliveryServiceException: $message';
}

class DeliveryValidationException extends DeliveryServiceException {
  final ValidationError validationError;

  DeliveryValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class DeliveryBadRequestException extends DeliveryServiceException {
  final ApiError apiError;

  DeliveryBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class DeliveryNotFoundException extends DeliveryServiceException {
  DeliveryNotFoundException(super.message) : super(statusCode: 404);
}

// Delivery Service (Public API - No Authentication Required)
class ClaudeDeliveryService {
  final String domain;

  ClaudeDeliveryService({required this.domain});

  Map<String, String> get _jsonHeaders => {'accept': 'application/json'};

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(String) fromContent,
  ) async {
    final responseBody = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromContent(responseBody);
    } else if (response.statusCode == 400) {
      try {
        final errorData = json.decode(responseBody);
        throw DeliveryBadRequestException(ApiError.fromJson(errorData));
      } catch (e) {
        throw DeliveryServiceException(
          'Bad request: $responseBody',
          statusCode: 400,
        );
      }
    } else if (response.statusCode == 404) {
      try {
        final errorData = json.decode(responseBody);
        final detail = errorData['detail'] ?? 'Not Found';
        throw DeliveryNotFoundException(detail);
      } catch (e) {
        throw DeliveryNotFoundException('Resource not found');
      }
    } else if (response.statusCode == 422) {
      try {
        final errorData = json.decode(responseBody);
        throw DeliveryValidationException(ValidationError.fromJson(errorData));
      } catch (e) {
        throw DeliveryServiceException(
          'Validation error: $responseBody',
          statusCode: 422,
        );
      }
    } else {
      throw DeliveryServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get a specific page snapshot from the delivery API
  Future<PageSnapshot> getPageSnapshot(
    String projectSlug,
    String pageSlug, {
    PageState? state,
    String? previewToken,
  }) async {
    final queryParams = <String, String>{};
    if (state != null) {
      queryParams['state'] = state.toString();
    }
    if (previewToken != null && previewToken.isNotEmpty) {
      queryParams['preview_token'] = previewToken;
    }

    final uri = Uri.parse(
      '$domain/delivery/v1/projects/$projectSlug/pages/$pageSlug',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _jsonHeaders);

      return await _handleResponse(response, (content) {
        return PageSnapshot.fromString(
          content,
          projectSlug,
          pageSlug,
          state: state,
        );
      });
    } catch (e) {
      if (e is DeliveryServiceException) rethrow;
      throw DeliveryServiceException('Error getting page snapshot: $e');
    }
  }

  /// Get list of pages for a project
  Future<PagesListResponse> listPages(String projectSlug) async {
    final url = Uri.parse('$domain/delivery/v1/projects/$projectSlug/pages');

    try {
      final response = await http.get(url, headers: _jsonHeaders);

      return await _handleResponse(response, (content) {
        return PagesListResponse.fromString(content, projectSlug);
      });
    } catch (e) {
      if (e is DeliveryServiceException) rethrow;
      throw DeliveryServiceException('Error listing pages: $e');
    }
  }

  /// Get published page (convenience method)
  Future<PageSnapshot> getPublishedPage(
    String projectSlug,
    String pageSlug,
  ) async {
    return getPageSnapshot(projectSlug, pageSlug, state: PageState.published);
  }

  /// Get draft page (convenience method)
  Future<PageSnapshot> getDraftPage(String projectSlug, String pageSlug) async {
    return getPageSnapshot(projectSlug, pageSlug, state: PageState.draft);
  }

  /// Get page with preview token (convenience method)
  Future<PageSnapshot> getPreviewPage(
    String projectSlug,
    String pageSlug,
    String previewToken,
  ) async {
    return getPageSnapshot(projectSlug, pageSlug, previewToken: previewToken);
  }

  /// Get multiple pages by their slugs
  Future<Map<String, PageSnapshot>> getMultiplePages(
    String projectSlug,
    List<String> pageSlugs, {
    PageState? state,
    String? previewToken,
  }) async {
    final results = <String, PageSnapshot>{};
    final errors = <String, Exception>{};

    for (final pageSlug in pageSlugs) {
      try {
        final page = await getPageSnapshot(
          projectSlug,
          pageSlug,
          state: state,
          previewToken: previewToken,
        );
        results[pageSlug] = page;
      } catch (e) {
        errors[pageSlug] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty && results.isEmpty) {
      throw DeliveryServiceException(
        'Failed to get any pages. Errors: $errors',
      );
    }

    return results;
  }

  /// Check if a project exists (by trying to list its pages)
  Future<bool> projectExists(String projectSlug) async {
    try {
      await listPages(projectSlug);
      return true;
    } on DeliveryNotFoundException {
      return false;
    } catch (e) {
      // Other errors might indicate the project exists but there are other issues
      return true;
    }
  }

  /// Check if a specific page exists
  Future<bool> pageExists(
    String projectSlug,
    String pageSlug, {
    PageState? state,
  }) async {
    try {
      await getPageSnapshot(projectSlug, pageSlug, state: state);
      return true;
    } on DeliveryNotFoundException {
      return false;
    } catch (e) {
      // Other errors might indicate the page exists but there are other issues
      return true;
    }
  }

  /// Get all published pages for a project
  Future<List<PageSnapshot>> getAllPublishedPages(String projectSlug) async {
    try {
      final pagesList = await listPages(projectSlug);

      if (!pagesList.isJson || pagesList.pageSlugs.isEmpty) {
        return [];
      }

      final pages = <PageSnapshot>[];
      for (final slug in pagesList.pageSlugs) {
        try {
          final page = await getPublishedPage(projectSlug, slug);
          pages.add(page);
        } catch (e) {
          // Skip pages that can't be retrieved (might not be published)
          continue;
        }
      }

      return pages;
    } catch (e) {
      if (e is DeliveryServiceException) rethrow;
      throw DeliveryServiceException('Error getting all published pages: $e');
    }
  }

  /// Validate slug format (basic validation)
  bool isValidSlug(String slug) {
    // Basic slug validation: letters, numbers, hyphens, underscores
    final slugRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return slug.isNotEmpty && slugRegex.hasMatch(slug);
  }

  /// Get page snapshot with validation
  Future<PageSnapshot> getPageSnapshotWithValidation(
    String projectSlug,
    String pageSlug, {
    PageState? state,
    String? previewToken,
  }) async {
    if (!isValidSlug(projectSlug)) {
      throw DeliveryServiceException(
        'Invalid project slug format: $projectSlug',
        statusCode: 400,
      );
    }

    if (!isValidSlug(pageSlug)) {
      throw DeliveryServiceException(
        'Invalid page slug format: $pageSlug',
        statusCode: 400,
      );
    }

    return getPageSnapshot(
      projectSlug,
      pageSlug,
      state: state,
      previewToken: previewToken,
    );
  }
}

// Factory methods
class ClaudeDeliveryServiceFactory {
  static ClaudeDeliveryService create(String domain) {
    return ClaudeDeliveryService(domain: domain);
  }

  static ClaudeDeliveryService createForLatente() {
    return ClaudeDeliveryService(
      domain: 'https://latente-cms-415c09785677.herokuapp.com',
    );
  }
}

// Content cache manager for delivery content
class DeliveryContentCache {
  final ClaudeDeliveryService _service;
  final Map<String, PageSnapshot> _pageCache = {};
  final Map<String, PagesListResponse> _listCache = {};
  final Duration _cacheExpiry;

  DeliveryContentCache(
    this._service, {
    Duration cacheExpiry = const Duration(minutes: 15),
  }) : _cacheExpiry = cacheExpiry;

  String _getCacheKey(
    String projectSlug,
    String pageSlug, {
    PageState? state,
    String? previewToken,
  }) {
    return '$projectSlug:$pageSlug:${state?.toString() ?? 'default'}:${previewToken ?? 'no-token'}';
  }

  /// Get page with caching
  Future<PageSnapshot> getPageSnapshot(
    String projectSlug,
    String pageSlug, {
    PageState? state,
    String? previewToken,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _getCacheKey(
      projectSlug,
      pageSlug,
      state: state,
      previewToken: previewToken,
    );

    if (!forceRefresh && _pageCache.containsKey(cacheKey)) {
      return _pageCache[cacheKey]!;
    }

    final page = await _service.getPageSnapshot(
      projectSlug,
      pageSlug,
      state: state,
      previewToken: previewToken,
    );

    _pageCache[cacheKey] = page;
    return page;
  }

  /// Get pages list with caching
  Future<PagesListResponse> listPages(
    String projectSlug, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _listCache.containsKey(projectSlug)) {
      return _listCache[projectSlug]!;
    }

    final list = await _service.listPages(projectSlug);
    _listCache[projectSlug] = list;
    return list;
  }

  /// Clear all cache
  void clearCache() {
    _pageCache.clear();
    _listCache.clear();
  }

  /// Clear cache for specific project
  void clearProjectCache(String projectSlug) {
    _pageCache.removeWhere((key, value) => key.startsWith('$projectSlug:'));
    _listCache.remove(projectSlug);
  }

  /// Get cache stats
  Map<String, int> get cacheStats => {
    'pages': _pageCache.length,
    'lists': _listCache.length,
  };
}

// Example usage:
/*
void main() async {
  // Create delivery service (no authentication required)
  final deliveryService = ClaudeDeliveryService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  const projectSlug = 'my-project';
  const pageSlug = 'home-page';

  try {
    print('--- Getting Page Snapshot ---');
    
    // Get a published page
    final publishedPage = await deliveryService.getPublishedPage(projectSlug, pageSlug);
    print('Published page: ${publishedPage.pageSlug}');
    print('Content length: ${publishedPage.content.length}');
    print('Is JSON: ${publishedPage.isJson}');
    
    if (publishedPage.isJson) {
      print('Title: ${publishedPage.getField<String>('title')}');
    }
    
    // Get page with preview token
    print('\n--- Getting Preview Page ---');
    const previewToken = 'preview_token_123';
    final previewPage = await deliveryService.getPreviewPage(
      projectSlug,
      pageSlug,
      previewToken,
    );
    print('Preview page: ${previewPage.pageSlug}');
    
    // List all pages
    print('\n--- Listing Pages ---');
    final pagesList = await deliveryService.listPages(projectSlug);
    print('Found ${pagesList.pageCount} pages');
    print('Page slugs: ${pagesList.pageSlugs}');
    
    // Get multiple pages
    print('\n--- Getting Multiple Pages ---');
    final pageSlugs = ['home-page', 'about-page', 'contact-page'];
    final multiplePages = await deliveryService.getMultiplePages(
      projectSlug,
      pageSlugs,
      state: PageState.published,
    );
    
    print('Retrieved ${multiplePages.length} pages');
    for (final entry in multiplePages.entries) {
      print('- ${entry.key}: ${entry.value.content.length} chars');
    }
    
    // Check if project/page exists
    print('\n--- Checking Existence ---');
    final projectExists = await deliveryService.projectExists(projectSlug);
    final pageExists = await deliveryService.pageExists(projectSlug, pageSlug);
    print('Project exists: $projectExists');
    print('Page exists: $pageExists');
    
  } on DeliveryNotFoundException catch (e) {
    print('Not found: ${e.message}');
  } on DeliveryValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on DeliveryServiceException catch (e) {
    print('Delivery service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Content management example with caching:
void contentManagementExample() async {
  final deliveryService = ClaudeDeliveryServiceFactory.createForLatente();
  final contentCache = DeliveryContentCache(deliveryService);

  const projectSlug = 'blog-project';

  try {
    print('=== Content Management with Caching ===\n');
    
    // Get pages list (cached)
    final pagesList = await contentCache.listPages(projectSlug);
    print('📄 Found ${pagesList.pageCount} pages');
    
    // Get all published pages
    final publishedPages = await deliveryService.getAllPublishedPages(projectSlug);
    print('📖 ${publishedPages.length} published pages');
    
    for (final page in publishedPages) {
      print('  - ${page.pageSlug} (${page.content.length} chars)');
      
      if (page.isJson) {
        final title = page.getField<String>('title');
        final author = page.getField<String>('author');
        print('    Title: $title');
        print('    Author: $author');
      }
    }
    
    // Cache statistics
    print('\n📊 Cache stats: ${contentCache.cacheStats}');
    
    // Test page access with different states
    const testPageSlug = 'test-page';
    
    print('\n🔍 Testing page states:');
    
    // Try published
    try {
      await contentCache.getPageSnapshot(projectSlug, testPageSlug, state: PageState.published);
      print('  ✅ Published version available');
    } catch (e) {
      print('  ❌ Published version not available');
    }
    
    // Try draft
    try {
      await contentCache.getPageSnapshot(projectSlug, testPageSlug, state: PageState.draft);
      print('  ✅ Draft version available');
    } catch (e) {
      print('  ❌ Draft version not available');
    }
    
  } catch (e) {
    print('Content management error: $e');
  }
}

// Public website integration example:
void publicWebsiteExample() async {
  final deliveryService = ClaudeDeliveryService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  const projectSlug = 'company-website';

  try {
    print('=== Public Website Content ===\n');
    
    // Get main navigation pages
    final navigationPages = ['home', 'about', 'services', 'contact'];
    
    for (final pageSlug in navigationPages) {
      try {
        final page = await deliveryService.getPublishedPage(projectSlug, pageSlug);
        
        print('📄 $pageSlug');
        if (page.isJson) {
          final title = page.getField<String>('title');
          final description = page.getField<String>('description');
          final lastModified = page.getField<String>('last_modified');
          
          print('  Title: $title');
          print('  Description: ${description?.substring(0, 100) ?? 'N/A'}...');
          print('  Last Modified: $lastModified');
        }
        print('');
        
      } on DeliveryNotFoundException {
        print('❌ $pageSlug not found or not published');
      }
    }
    
    // Get blog posts (if available)
    try {
      final blogList = await deliveryService.listPages('$projectSlug-blog');
      print('📝 Blog: ${blogList.pageCount} posts available');
      
      for (final slug in blogList.pageSlugs.take(5)) {
        final post = await deliveryService.getPublishedPage('$projectSlug-blog', slug);
        if (post.isJson) {
          final title = post.getField<String>('title');
          final publishDate = post.getField<String>('publish_date');
          print('  - $title ($publishDate)');
        }
      }
    } on DeliveryNotFoundException {
      print('📝 No blog project found');
    }
    
  } catch (e) {
    print('Public website error: $e');
  }
}
*/
