import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Section model (reusing from sections service)
class ImportedSection {
  final String id;
  final String pageId;
  final String type;
  final Map<String, dynamic> data;
  final int position;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ImportedSection({
    required this.id,
    required this.pageId,
    required this.type,
    required this.data,
    required this.position,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ImportedSection.fromJson(Map<String, dynamic> json) {
    return ImportedSection(
      id: json['id'],
      pageId: json['page_id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      position: json['position'],
      isEnabled: json['is_enabled'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_id': pageId,
      'type': type,
      'data': data,
      'position': position,
      'is_enabled': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ImportedSection(id: $id, pageId: $pageId, type: $type, position: $position, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImportedSection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy of this section with updated fields
  ImportedSection copyWith({
    String? id,
    String? pageId,
    String? type,
    Map<String, dynamic>? data,
    int? position,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ImportedSection(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      type: type ?? this.type,
      data: data ?? this.data,
      position: position ?? this.position,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Import section definition (for the request)
class ImportSectionData {
  final String type;
  final Map<String, dynamic> data;
  final int? position;
  final bool? isEnabled;
  final int? schemaVersion;

  ImportSectionData({
    required this.type,
    required this.data,
    this.position,
    this.isEnabled,
    this.schemaVersion,
  });

  factory ImportSectionData.fromJson(Map<String, dynamic> json) {
    return ImportSectionData(
      type: json['type'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      position: json['position'],
      isEnabled: json['is_enabled'],
      schemaVersion: json['schema_version'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type, 'data': data};
    if (position != null) map['position'] = position;
    if (isEnabled != null) map['is_enabled'] = isEnabled;
    if (schemaVersion != null) map['schema_version'] = schemaVersion;
    return map;
  }

  @override
  String toString() {
    return 'ImportSectionData(type: $type, position: $position, isEnabled: $isEnabled)';
  }
}

// Request models
class BulkImportSectionsRequest {
  final bool replace;
  final List<Map<String, dynamic>> sections;

  BulkImportSectionsRequest({required this.replace, required this.sections});

  Map<String, dynamic> toJson() {
    return {'replace': replace, 'sections': sections};
  }

  @override
  String toString() {
    return 'BulkImportSectionsRequest(replace: $replace, sections: ${sections.length} items)';
  }
}

// Import result model
class ImportResult {
  final List<ImportedSection> sections;
  final Map<String, dynamic> metadata;

  ImportResult({required this.sections, this.metadata = const {}});

  factory ImportResult.fromSectionsList(List<ImportedSection> sections) {
    return ImportResult(
      sections: sections,
      metadata: {
        'imported_count': sections.length,
        'import_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  String toString() {
    return 'ImportResult(sections: ${sections.length}, metadata: $metadata)';
  }

  /// Get sections by type
  List<ImportedSection> getSectionsByType(String type) {
    return sections.where((section) => section.type == type).toList();
  }

  /// Get enabled sections
  List<ImportedSection> get enabledSections {
    return sections.where((section) => section.isEnabled).toList();
  }

  /// Get disabled sections
  List<ImportedSection> get disabledSections {
    return sections.where((section) => !section.isEnabled).toList();
  }

  /// Get sections sorted by position
  List<ImportedSection> get sectionsSortedByPosition {
    final sorted = List<ImportedSection>.from(sections);
    sorted.sort((a, b) => a.position.compareTo(b.position));
    return sorted;
  }

  /// Get import statistics
  Map<String, dynamic> get statistics {
    final typeGroups = <String, List<ImportedSection>>{};
    for (final section in sections) {
      if (!typeGroups.containsKey(section.type)) {
        typeGroups[section.type] = [];
      }
      typeGroups[section.type]!.add(section);
    }

    return {
      'total_sections': sections.length,
      'enabled_sections': enabledSections.length,
      'disabled_sections': disabledSections.length,
      'types_count': typeGroups.length,
      'sections_by_type': typeGroups.map(
        (type, typeSections) => MapEntry(type, typeSections.length),
      ),
      'import_metadata': metadata,
    };
  }
}

// Custom Exceptions
class AdminImportServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminImportServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminImportServiceException: $message';
}

class ImportValidationException extends AdminImportServiceException {
  final ValidationError validationError;

  ImportValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class ImportBadRequestException extends AdminImportServiceException {
  final ApiError apiError;

  ImportBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class ImportUnauthorizedException extends AdminImportServiceException {
  ImportUnauthorizedException(super.message) : super(statusCode: 401);
}

class ImportForbiddenException extends AdminImportServiceException {
  ImportForbiddenException(super.message) : super(statusCode: 403);
}

class ImportConflictException extends AdminImportServiceException {
  ImportConflictException(super.message) : super(statusCode: 409);
}

class ImportNotFoundException extends AdminImportServiceException {
  ImportNotFoundException(super.message) : super(statusCode: 404);
}

// Admin Import Service
class ClaudeAdminImportService {
  final String domain;
  String? _authToken;

  ClaudeAdminImportService({required this.domain, String? authToken})
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
      throw ImportBadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Unauthorized';
      throw ImportUnauthorizedException(detail);
    } else if (response.statusCode == 403) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Forbidden';
      throw ImportForbiddenException(detail);
    } else if (response.statusCode == 404) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Not found';
      throw ImportNotFoundException(detail);
    } else if (response.statusCode == 409) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Conflict';
      throw ImportConflictException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw ImportValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminImportServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Bulk import sections into a page
  Future<ImportResult> bulkImportSections({
    required String pageId,
    required List<Map<String, dynamic>> sections,
    bool replace = false,
  }) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/import');
    final request = BulkImportSectionsRequest(
      replace: replace,
      sections: sections,
    );

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is List) {
          final importedSections =
              data
                  .map(
                    (sectionJson) => ImportedSection.fromJson(
                      sectionJson as Map<String, dynamic>,
                    ),
                  )
                  .toList();
          return ImportResult.fromSectionsList(importedSections);
        } else {
          throw AdminImportServiceException(
            'Expected list of sections, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminImportServiceException) rethrow;
      throw AdminImportServiceException('Error importing sections: $e');
    }
  }

  // Helper methods

  /// Import sections from ImportSectionData objects
  Future<ImportResult> importSectionsFromData({
    required String pageId,
    required List<ImportSectionData> sectionsData,
    bool replace = false,
  }) async {
    final sections =
        sectionsData.map((sectionData) => sectionData.toJson()).toList();
    return await bulkImportSections(
      pageId: pageId,
      sections: sections,
      replace: replace,
    );
  }

  /// Import sections and append to existing sections
  Future<ImportResult> appendSections({
    required String pageId,
    required List<Map<String, dynamic>> sections,
  }) async {
    return await bulkImportSections(
      pageId: pageId,
      sections: sections,
      replace: false,
    );
  }

  /// Import sections and replace all existing sections
  Future<ImportResult> replaceSections({
    required String pageId,
    required List<Map<String, dynamic>> sections,
  }) async {
    return await bulkImportSections(
      pageId: pageId,
      sections: sections,
      replace: true,
    );
  }

  /// Import sections from JSON string
  Future<ImportResult> importSectionsFromJson({
    required String pageId,
    required String jsonString,
    bool replace = false,
  }) async {
    try {
      final data = json.decode(jsonString);
      List<Map<String, dynamic>> sections;

      if (data is List) {
        sections = data.cast<Map<String, dynamic>>();
      } else if (data is Map<String, dynamic> && data.containsKey('sections')) {
        sections = (data['sections'] as List).cast<Map<String, dynamic>>();
      } else {
        throw AdminImportServiceException(
          'Invalid JSON format. Expected array of sections or object with "sections" property',
        );
      }

      return await bulkImportSections(
        pageId: pageId,
        sections: sections,
        replace: replace,
      );
    } catch (e) {
      if (e is AdminImportServiceException) rethrow;
      throw AdminImportServiceException(
        'Error importing sections from JSON: $e',
      );
    }
  }

  /// Create section data for import
  ImportSectionData createSectionData({
    required String type,
    required Map<String, dynamic> data,
    int? position,
    bool? isEnabled,
    int? schemaVersion,
  }) {
    return ImportSectionData(
      type: type,
      data: data,
      position: position,
      isEnabled: isEnabled,
      schemaVersion: schemaVersion,
    );
  }

  /// Validate sections data before import
  List<String> validateSectionsData(List<Map<String, dynamic>> sections) {
    final errors = <String>[];

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      final index = i + 1;

      // Check required fields
      if (!section.containsKey('type') || section['type'] == null) {
        errors.add('Section $index: "type" field is required');
      }

      if (!section.containsKey('data') || section['data'] == null) {
        errors.add('Section $index: "data" field is required');
      } else if (section['data'] is! Map<String, dynamic>) {
        errors.add('Section $index: "data" field must be an object');
      }

      // Validate optional fields
      if (section.containsKey('position') && section['position'] is! int) {
        errors.add('Section $index: "position" field must be an integer');
      }

      if (section.containsKey('is_enabled') && section['is_enabled'] is! bool) {
        errors.add('Section $index: "is_enabled" field must be a boolean');
      }

      if (section.containsKey('schema_version') &&
          section['schema_version'] is! int) {
        errors.add('Section $index: "schema_version" field must be an integer');
      }

      // Validate type is a string
      if (section.containsKey('type') && section['type'] is! String) {
        errors.add('Section $index: "type" field must be a string');
      }
    }

    return errors;
  }

  /// Create sections data from template
  List<ImportSectionData> createSectionsFromTemplate({
    required String templateType,
    Map<String, dynamic>? templateData,
  }) {
    final sections = <ImportSectionData>[];

    switch (templateType.toLowerCase()) {
      case 'basic_page':
        sections.addAll([
          createSectionData(
            type: 'header',
            data: {
              'logo': templateData?['logo'] ?? 'https://example.com/logo.png',
              'navigation':
                  templateData?['navigation'] ?? ['Home', 'About', 'Contact'],
              'theme': templateData?['theme'] ?? 'light',
            },
            position: 0,
            isEnabled: true,
          ),
          createSectionData(
            type: 'hero',
            data: {
              'title': templateData?['title'] ?? 'Welcome to Our Site',
              'subtitle': templateData?['subtitle'] ?? 'This is a hero section',
              'backgroundImage':
                  templateData?['heroImage'] ?? 'https://example.com/hero.jpg',
              'ctaButton': {
                'text': templateData?['ctaText'] ?? 'Get Started',
                'link': templateData?['ctaLink'] ?? '/signup',
              },
            },
            position: 1,
            isEnabled: true,
          ),
          createSectionData(
            type: 'content',
            data: {
              'blocks': [
                {
                  'type': 'paragraph',
                  'content':
                      templateData?['content'] ??
                      'This is the main content of the page.',
                },
              ],
            },
            position: 2,
            isEnabled: true,
          ),
          createSectionData(
            type: 'footer',
            data: {
              'copyright': templateData?['copyright'] ?? '© 2025 Our Company',
              'links':
                  templateData?['footerLinks'] ??
                  ['Privacy', 'Terms', 'Contact'],
            },
            position: 3,
            isEnabled: true,
          ),
        ]);
        break;

      case 'landing_page':
        sections.addAll([
          createSectionData(
            type: 'hero',
            data: {
              'title': templateData?['title'] ?? 'Amazing Product',
              'subtitle':
                  templateData?['subtitle'] ??
                  'The best solution for your needs',
              'backgroundImage':
                  templateData?['heroImage'] ?? 'https://example.com/hero.jpg',
              'ctaButton': {'text': 'Try Now', 'link': '/signup'},
            },
            position: 0,
            isEnabled: true,
          ),
          createSectionData(
            type: 'features',
            data: {
              'title': 'Features',
              'features':
                  templateData?['features'] ??
                  [
                    {'title': 'Feature 1', 'description': 'Amazing feature'},
                    {
                      'title': 'Feature 2',
                      'description': 'Another great feature',
                    },
                    {'title': 'Feature 3', 'description': 'Even more features'},
                  ],
            },
            position: 1,
            isEnabled: true,
          ),
          createSectionData(
            type: 'testimonials',
            data: {
              'title': 'What our customers say',
              'testimonials':
                  templateData?['testimonials'] ??
                  [
                    {'name': 'John Doe', 'text': 'Great product!'},
                    {'name': 'Jane Smith', 'text': 'Highly recommended!'},
                  ],
            },
            position: 2,
            isEnabled: true,
          ),
          createSectionData(
            type: 'cta',
            data: {
              'title': 'Ready to get started?',
              'subtitle': 'Join thousands of satisfied customers',
              'button': {'text': 'Sign Up Now', 'link': '/signup'},
            },
            position: 3,
            isEnabled: true,
          ),
        ]);
        break;

      case 'blog_post':
        sections.addAll([
          createSectionData(
            type: 'article_header',
            data: {
              'title': templateData?['title'] ?? 'Blog Post Title',
              'author': templateData?['author'] ?? 'Author Name',
              'publishDate':
                  templateData?['publishDate'] ??
                  DateTime.now().toIso8601String(),
              'featuredImage':
                  templateData?['featuredImage'] ??
                  'https://example.com/featured.jpg',
            },
            position: 0,
            isEnabled: true,
          ),
          createSectionData(
            type: 'article_content',
            data: {
              'content':
                  templateData?['content'] ?? 'This is the blog post content.',
            },
            position: 1,
            isEnabled: true,
          ),
          createSectionData(
            type: 'related_posts',
            data: {
              'title': 'Related Posts',
              'posts': templateData?['relatedPosts'] ?? [],
            },
            position: 2,
            isEnabled: true,
          ),
        ]);
        break;

      default:
        throw AdminImportServiceException(
          'Unknown template type: $templateType',
        );
    }

    return sections;
  }

  /// Import sections from a predefined template
  Future<ImportResult> importFromTemplate({
    required String pageId,
    required String templateType,
    Map<String, dynamic>? templateData,
    bool replace = false,
  }) async {
    try {
      final sectionsData = createSectionsFromTemplate(
        templateType: templateType,
        templateData: templateData,
      );

      return await importSectionsFromData(
        pageId: pageId,
        sectionsData: sectionsData,
        replace: replace,
      );
    } catch (e) {
      if (e is AdminImportServiceException) rethrow;
      throw AdminImportServiceException('Error importing from template: $e');
    }
  }

  /// Duplicate sections from another page
  Future<ImportResult> duplicateSectionsFromPage({
    required String sourcePageId,
    required String targetPageId,
    bool replace = false,
    bool includeDisabled = false,
  }) async {
    try {
      // This would require integration with the sections service to get source sections
      // For now, we'll throw an exception indicating this needs to be implemented
      throw AdminImportServiceException(
        'duplicateSectionsFromPage requires integration with ClaudeAdminSectionsService. '
        'Use the sections service to get source sections, then call bulkImportSections.',
      );
    } catch (e) {
      if (e is AdminImportServiceException) rethrow;
      throw AdminImportServiceException(
        'Error duplicating sections from page: $e',
      );
    }
  }

  /// Import sections with automatic positioning
  Future<ImportResult> importSectionsWithAutoPositioning({
    required String pageId,
    required List<Map<String, dynamic>> sections,
    bool replace = false,
    int startPosition = 0,
  }) async {
    try {
      final sectionsWithPositions = <Map<String, dynamic>>[];

      for (int i = 0; i < sections.length; i++) {
        final section = Map<String, dynamic>.from(sections[i]);
        section['position'] = startPosition + i;
        sectionsWithPositions.add(section);
      }

      return await bulkImportSections(
        pageId: pageId,
        sections: sectionsWithPositions,
        replace: replace,
      );
    } catch (e) {
      if (e is AdminImportServiceException) rethrow;
      throw AdminImportServiceException(
        'Error importing sections with auto positioning: $e',
      );
    }
  }

  /// Batch import sections to multiple pages
  Future<Map<String, ImportResult>> batchImportSections({
    required Map<String, List<Map<String, dynamic>>> pagesSections,
    bool replace = false,
  }) async {
    final results = <String, ImportResult>{};
    final errors = <String, Exception>{};

    for (final entry in pagesSections.entries) {
      final pageId = entry.key;
      final sections = entry.value;

      try {
        final result = await bulkImportSections(
          pageId: pageId,
          sections: sections,
          replace: replace,
        );
        results[pageId] = result;
      } catch (e) {
        errors[pageId] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty) {
      throw AdminImportServiceException(
        'Failed to import sections for ${errors.length} pages: ${errors.keys.join(', ')}',
        details: errors,
      );
    }

    return results;
  }

  /// Get available templates
  List<String> getAvailableTemplates() {
    return ['basic_page', 'landing_page', 'blog_post'];
  }

  /// Get template description
  Map<String, dynamic> getTemplateInfo(String templateType) {
    switch (templateType.toLowerCase()) {
      case 'basic_page':
        return {
          'name': 'Basic Page',
          'description':
              'A standard page with header, hero, content, and footer sections',
          'sections': ['header', 'hero', 'content', 'footer'],
          'parameters': [
            'logo',
            'navigation',
            'theme',
            'title',
            'subtitle',
            'heroImage',
            'content',
            'copyright',
            'footerLinks',
          ],
        };

      case 'landing_page':
        return {
          'name': 'Landing Page',
          'description':
              'A conversion-focused page with hero, features, testimonials, and CTA sections',
          'sections': ['hero', 'features', 'testimonials', 'cta'],
          'parameters': [
            'title',
            'subtitle',
            'heroImage',
            'features',
            'testimonials',
          ],
        };

      case 'blog_post':
        return {
          'name': 'Blog Post',
          'description':
              'An article page with header, content, and related posts sections',
          'sections': ['article_header', 'article_content', 'related_posts'],
          'parameters': [
            'title',
            'author',
            'publishDate',
            'featuredImage',
            'content',
            'relatedPosts',
          ],
        };

      default:
        throw AdminImportServiceException(
          'Unknown template type: $templateType',
        );
    }
  }

  /// Validate import request
  Map<String, dynamic> validateImportRequest({
    required String pageId,
    required List<Map<String, dynamic>> sections,
    bool replace = false,
  }) {
    final validation = <String, dynamic>{
      'valid': true,
      'errors': <String>[],
      'warnings': <String>[],
      'summary': <String, dynamic>{},
    };

    // Validate page ID
    if (pageId.isEmpty) {
      validation['errors'].add('Page ID cannot be empty');
      validation['valid'] = false;
    }

    // Validate sections
    if (sections.isEmpty) {
      validation['warnings'].add('No sections to import');
    }

    final sectionErrors = validateSectionsData(sections);
    if (sectionErrors.isNotEmpty) {
      validation['errors'].addAll(sectionErrors);
      validation['valid'] = false;
    }

    // Generate summary
    final typeGroups = <String, int>{};
    int enabledCount = 0;
    int disabledCount = 0;

    for (final section in sections) {
      final type = section['type'] as String?;
      if (type != null) {
        typeGroups[type] = (typeGroups[type] ?? 0) + 1;
      }

      final isEnabled = section['is_enabled'] as bool? ?? true;
      if (isEnabled) {
        enabledCount++;
      } else {
        disabledCount++;
      }
    }

    validation['summary'] = {
      'total_sections': sections.length,
      'enabled_sections': enabledCount,
      'disabled_sections': disabledCount,
      'types_count': typeGroups.length,
      'sections_by_type': typeGroups,
      'replace_mode': replace,
    };

    return validation;
  }
}

// Factory method to create service from auth service
class ClaudeAdminImportServiceFactory {
  static ClaudeAdminImportService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminImportService(domain: domain, authToken: authToken);
  }
}
