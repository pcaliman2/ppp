import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Section model (updated with more fields)
class Section {
  final String id;
  final String pageId;
  final String type;
  final Map<String, dynamic> data;
  final int position;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Section({
    required this.id,
    required this.pageId,
    required this.type,
    required this.data,
    required this.position,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
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
    return 'Section(id: $id, pageId: $pageId, type: $type, position: $position, isEnabled: $isEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Section && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy of this section with updated fields
  Section copyWith({
    String? id,
    String? pageId,
    String? type,
    Map<String, dynamic>? data,
    int? position,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Section(
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

// Request models
class CreateSectionRequest {
  final String type;
  final Map<String, dynamic> data;
  final int position;
  final int schemaVersion;

  CreateSectionRequest({
    required this.type,
    required this.data,
    required this.position,
    this.schemaVersion = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'position': position,
      'schema_version': schemaVersion,
    };
  }

  @override
  String toString() {
    return 'CreateSectionRequest(type: $type, position: $position, schemaVersion: $schemaVersion)';
  }
}

class UpdateSectionRequest {
  final String type;
  final Map<String, dynamic> data;
  final int schemaVersion;

  UpdateSectionRequest({
    required this.type,
    required this.data,
    this.schemaVersion = 0,
  });

  Map<String, dynamic> toJson() {
    return {'type': type, 'data': data, 'schema_version': schemaVersion};
  }

  @override
  String toString() {
    return 'UpdateSectionRequest(type: $type, schemaVersion: $schemaVersion)';
  }
}

class ToggleSectionRequest {
  final bool isEnabled;

  ToggleSectionRequest({required this.isEnabled});

  Map<String, dynamic> toJson() {
    return {'is_enabled': isEnabled};
  }

  @override
  String toString() {
    return 'ToggleSectionRequest(isEnabled: $isEnabled)';
  }
}

class ReorderSectionsRequest {
  final List<String> order;

  ReorderSectionsRequest({required this.order});

  Map<String, dynamic> toJson() {
    return {'order': order};
  }

  @override
  String toString() {
    return 'ReorderSectionsRequest(order: $order)';
  }
}

// Custom Exceptions
class AdminSectionsServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminSectionsServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AdminSectionsServiceException: $message';
}

class SectionsValidationException extends AdminSectionsServiceException {
  final ValidationError validationError;

  SectionsValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class SectionsBadRequestException extends AdminSectionsServiceException {
  final ApiError apiError;

  SectionsBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class SectionsUnauthorizedException extends AdminSectionsServiceException {
  SectionsUnauthorizedException(super.message) : super(statusCode: 401);
}

class SectionsForbiddenException extends AdminSectionsServiceException {
  SectionsForbiddenException(super.message) : super(statusCode: 403);
}

class SectionsConflictException extends AdminSectionsServiceException {
  SectionsConflictException(super.message) : super(statusCode: 409);
}

class SectionsNotFoundException extends AdminSectionsServiceException {
  SectionsNotFoundException(super.message) : super(statusCode: 404);
}

// Admin Sections Service
class ClaudeAdminSectionsService {
  final String domain;
  String? _authToken;

  ClaudeAdminSectionsService({required this.domain, String? authToken})
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
      throw SectionsBadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Unauthorized';
      throw SectionsUnauthorizedException(detail);
    } else if (response.statusCode == 403) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Forbidden';
      throw SectionsForbiddenException(detail);
    } else if (response.statusCode == 404) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Not found';
      throw SectionsNotFoundException(detail);
    } else if (response.statusCode == 409) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Conflict';
      throw SectionsConflictException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw SectionsValidationException(ValidationError.fromJson(errorData));
    } else {
      throw AdminSectionsServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Add section to page
  Future<Section> createSection({
    required String pageId,
    required String type,
    required Map<String, dynamic> data,
    required int position,
    int schemaVersion = 0,
  }) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/sections');
    final request = CreateSectionRequest(
      type: type,
      data: data,
      position: position,
      schemaVersion: schemaVersion,
    );

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Section.fromJson(data);
        } else {
          throw AdminSectionsServiceException(
            'Expected section object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error creating section: $e');
    }
  }

  /// List page sections (optionally include schema)
  Future<List<Section>> getSections({
    required String pageId,
    bool includeSchema = false,
  }) async {
    final queryParams = <String, String>{
      'includeSchema': includeSchema.toString(),
    };

    final uri = Uri.parse(
      '$domain/admin/pages/$pageId/sections',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (sectionJson) =>
                    Section.fromJson(sectionJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminSectionsServiceException(
            'Expected list of sections, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error getting sections: $e');
    }
  }

  /// Get a section (optionally include schema)
  Future<Section> getSection({
    required String sectionId,
    bool includeSchema = false,
  }) async {
    final queryParams = <String, String>{
      'includeSchema': includeSchema.toString(),
    };

    final uri = Uri.parse(
      '$domain/admin/sections/$sectionId',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Section.fromJson(data);
        } else {
          throw AdminSectionsServiceException(
            'Expected section object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error getting section: $e');
    }
  }

  /// Update section (replace fields)
  Future<Section> updateSection({
    required String sectionId,
    required String type,
    required Map<String, dynamic> data,
    int schemaVersion = 0,
  }) async {
    final url = Uri.parse('$domain/admin/sections/$sectionId');
    final request = UpdateSectionRequest(
      type: type,
      data: data,
      schemaVersion: schemaVersion,
    );

    try {
      final response = await http.put(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Section.fromJson(data);
        } else {
          throw AdminSectionsServiceException(
            'Expected section object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error updating section: $e');
    }
  }

  /// Delete section (resequence positions)
  Future<void> deleteSection(String sectionId) async {
    final url = Uri.parse('$domain/admin/sections/$sectionId');

    try {
      final response = await http.delete(url, headers: _getAuthHeaders());

      await _handleResponse(response, (data) {
        // 204 No Content response, no data to return
        return null;
      });
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error deleting section: $e');
    }
  }

  /// Enable/disable section
  Future<Section> toggleSection({
    required String sectionId,
    required bool isEnabled,
  }) async {
    final url = Uri.parse('$domain/admin/sections/$sectionId/toggle');
    final request = ToggleSectionRequest(isEnabled: isEnabled);

    try {
      final response = await http.patch(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Section.fromJson(data);
        } else {
          throw AdminSectionsServiceException(
            'Expected section object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error toggling section: $e');
    }
  }

  /// Reorder sections by IDs
  Future<String> reorderSections({
    required String pageId,
    required List<String> order,
  }) async {
    final url = Uri.parse('$domain/admin/pages/$pageId/sections/reorder');
    final request = ReorderSectionsRequest(order: order);

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is String) {
          return data;
        } else {
          throw AdminSectionsServiceException(
            'Expected string response, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error reordering sections: $e');
    }
  }

  // Helper methods

  /// Get sections sorted by position
  Future<List<Section>> getSectionsSortedByPosition({
    required String pageId,
    bool includeSchema = false,
    bool ascending = true,
  }) async {
    try {
      final sections = await getSections(
        pageId: pageId,
        includeSchema: includeSchema,
      );
      sections.sort((a, b) {
        final comparison = a.position.compareTo(b.position);
        return ascending ? comparison : -comparison;
      });
      return sections;
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException(
        'Error getting sections sorted by position: $e',
      );
    }
  }

  /// Get enabled sections only
  Future<List<Section>> getEnabledSections({
    required String pageId,
    bool includeSchema = false,
  }) async {
    try {
      final sections = await getSections(
        pageId: pageId,
        includeSchema: includeSchema,
      );
      return sections.where((section) => section.isEnabled).toList();
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error getting enabled sections: $e');
    }
  }

  /// Get disabled sections only
  Future<List<Section>> getDisabledSections({
    required String pageId,
    bool includeSchema = false,
  }) async {
    try {
      final sections = await getSections(
        pageId: pageId,
        includeSchema: includeSchema,
      );
      return sections.where((section) => !section.isEnabled).toList();
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException(
        'Error getting disabled sections: $e',
      );
    }
  }

  /// Get sections by type
  Future<List<Section>> getSectionsByType({
    required String pageId,
    required String type,
    bool includeSchema = false,
  }) async {
    try {
      final sections = await getSections(
        pageId: pageId,
        includeSchema: includeSchema,
      );
      return sections.where((section) => section.type == type).toList();
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error getting sections by type: $e');
    }
  }

  /// Get sections count
  Future<int> getSectionsCount({
    required String pageId,
    bool enabledOnly = false,
  }) async {
    try {
      final sections =
          enabledOnly
              ? await getEnabledSections(pageId: pageId)
              : await getSections(pageId: pageId);
      return sections.length;
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error getting sections count: $e');
    }
  }

  /// Enable section
  Future<Section> enableSection(String sectionId) async {
    return await toggleSection(sectionId: sectionId, isEnabled: true);
  }

  /// Disable section
  Future<Section> disableSection(String sectionId) async {
    return await toggleSection(sectionId: sectionId, isEnabled: false);
  }

  /// Add section at the end (auto-calculate position)
  Future<Section> addSectionAtEnd({
    required String pageId,
    required String type,
    required Map<String, dynamic> data,
    int schemaVersion = 0,
  }) async {
    try {
      final sections = await getSections(pageId: pageId);
      final nextPosition =
          sections.isEmpty
              ? 0
              : sections
                      .map((s) => s.position)
                      .reduce((a, b) => a > b ? a : b) +
                  1;

      return await createSection(
        pageId: pageId,
        type: type,
        data: data,
        position: nextPosition,
        schemaVersion: schemaVersion,
      );
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error adding section at end: $e');
    }
  }

  /// Add section at the beginning (position 0, reorder others)
  Future<Section> addSectionAtBeginning({
    required String pageId,
    required String type,
    required Map<String, dynamic> data,
    int schemaVersion = 0,
  }) async {
    try {
      final section = await createSection(
        pageId: pageId,
        type: type,
        data: data,
        position: 0,
        schemaVersion: schemaVersion,
      );

      // Get all sections and reorder them to ensure proper sequencing
      final allSections = await getSectionsSortedByPosition(pageId: pageId);
      final reorderedIds = allSections.map((s) => s.id).toList();
      await reorderSections(pageId: pageId, order: reorderedIds);

      return section;
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException(
        'Error adding section at beginning: $e',
      );
    }
  }

  /// Insert section at specific position
  Future<Section> insertSectionAtPosition({
    required String pageId,
    required String type,
    required Map<String, dynamic> data,
    required int position,
    int schemaVersion = 0,
  }) async {
    try {
      final section = await createSection(
        pageId: pageId,
        type: type,
        data: data,
        position: position,
        schemaVersion: schemaVersion,
      );

      // Get all sections and reorder them to ensure proper sequencing
      final allSections = await getSectionsSortedByPosition(pageId: pageId);
      final reorderedIds = allSections.map((s) => s.id).toList();
      await reorderSections(pageId: pageId, order: reorderedIds);

      return section;
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException(
        'Error inserting section at position: $e',
      );
    }
  }

  /// Move section up (decrease position)
  Future<String> moveSectionUp({
    required String pageId,
    required String sectionId,
  }) async {
    try {
      final sections = await getSectionsSortedByPosition(pageId: pageId);
      final currentIndex = sections.indexWhere((s) => s.id == sectionId);

      if (currentIndex <= 0) {
        throw AdminSectionsServiceException(
          'Section is already at the top or not found',
        );
      }

      // Swap with previous section
      final newOrder = List<String>.from(sections.map((s) => s.id));
      final temp = newOrder[currentIndex];
      newOrder[currentIndex] = newOrder[currentIndex - 1];
      newOrder[currentIndex - 1] = temp;

      return await reorderSections(pageId: pageId, order: newOrder);
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error moving section up: $e');
    }
  }

  /// Move section down (increase position)
  Future<String> moveSectionDown({
    required String pageId,
    required String sectionId,
  }) async {
    try {
      final sections = await getSectionsSortedByPosition(pageId: pageId);
      final currentIndex = sections.indexWhere((s) => s.id == sectionId);

      if (currentIndex < 0 || currentIndex >= sections.length - 1) {
        throw AdminSectionsServiceException(
          'Section is already at the bottom or not found',
        );
      }

      // Swap with next section
      final newOrder = List<String>.from(sections.map((s) => s.id));
      final temp = newOrder[currentIndex];
      newOrder[currentIndex] = newOrder[currentIndex + 1];
      newOrder[currentIndex + 1] = temp;

      return await reorderSections(pageId: pageId, order: newOrder);
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error moving section down: $e');
    }
  }

  /// Move section to specific position
  Future<String> moveSectionToPosition({
    required String pageId,
    required String sectionId,
    required int newPosition,
  }) async {
    try {
      final sections = await getSectionsSortedByPosition(pageId: pageId);
      final currentIndex = sections.indexWhere((s) => s.id == sectionId);

      if (currentIndex < 0) {
        throw AdminSectionsServiceException('Section not found');
      }

      if (newPosition < 0 || newPosition >= sections.length) {
        throw AdminSectionsServiceException('Invalid position');
      }

      final newOrder = List<String>.from(sections.map((s) => s.id));
      final sectionIdToMove = newOrder.removeAt(currentIndex);
      newOrder.insert(newPosition, sectionIdToMove);

      return await reorderSections(pageId: pageId, order: newOrder);
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException(
        'Error moving section to position: $e',
      );
    }
  }

  /// Duplicate a section within the same page
  Future<Section> duplicateSection({
    required String sectionId,
    String? newType,
    Map<String, dynamic>? newData,
    int? insertAtPosition,
  }) async {
    try {
      final originalSection = await getSection(sectionId: sectionId);

      final duplicateType = newType ?? originalSection.type;
      final duplicateData =
          newData ?? Map<String, dynamic>.from(originalSection.data);

      if (insertAtPosition != null) {
        return await insertSectionAtPosition(
          pageId: originalSection.pageId,
          type: duplicateType,
          data: duplicateData,
          position: insertAtPosition,
        );
      } else {
        // Add after the original section
        return await insertSectionAtPosition(
          pageId: originalSection.pageId,
          type: duplicateType,
          data: duplicateData,
          position: originalSection.position + 1,
        );
      }
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error duplicating section: $e');
    }
  }

  /// Bulk enable/disable sections
  Future<List<Section>> bulkToggleSections({
    required List<String> sectionIds,
    required bool isEnabled,
  }) async {
    final results = <Section>[];
    final errors = <String, Exception>{};

    for (final sectionId in sectionIds) {
      try {
        final result = await toggleSection(
          sectionId: sectionId,
          isEnabled: isEnabled,
        );
        results.add(result);
      } catch (e) {
        errors[sectionId] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty) {
      throw AdminSectionsServiceException(
        'Failed to toggle ${errors.length} sections: ${errors.keys.join(', ')}',
        details: errors,
      );
    }

    return results;
  }

  /// Bulk delete sections
  Future<void> bulkDeleteSections(List<String> sectionIds) async {
    final errors = <String, Exception>{};

    for (final sectionId in sectionIds) {
      try {
        await deleteSection(sectionId);
      } catch (e) {
        errors[sectionId] = e is Exception ? e : Exception(e.toString());
      }
    }

    if (errors.isNotEmpty) {
      throw AdminSectionsServiceException(
        'Failed to delete ${errors.length} sections: ${errors.keys.join(', ')}',
        details: errors,
      );
    }
  }

  /// Get section statistics for a page
  Future<Map<String, dynamic>> getSectionStatistics(String pageId) async {
    try {
      final sections = await getSections(pageId: pageId);
      final enabledSections = sections.where((s) => s.isEnabled).toList();
      final disabledSections = sections.where((s) => !s.isEnabled).toList();

      // Group by type
      final typeGroups = <String, List<Section>>{};
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
        'oldest_section':
            sections.isNotEmpty
                ? sections.reduce(
                  (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
                )
                : null,
        'newest_section':
            sections.isNotEmpty
                ? sections.reduce(
                  (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
                )
                : null,
      };
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException(
        'Error getting section statistics: $e',
      );
    }
  }

  /// Get unique section types for a page
  Future<List<String>> getSectionTypes(String pageId) async {
    try {
      final sections = await getSections(pageId: pageId);
      return sections.map((s) => s.type).toSet().toList()..sort();
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error getting section types: $e');
    }
  }

  /// Clear all sections from a page
  Future<void> clearAllSections(String pageId) async {
    try {
      final sections = await getSections(pageId: pageId);
      final sectionIds = sections.map((s) => s.id).toList();
      await bulkDeleteSections(sectionIds);
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error clearing all sections: $e');
    }
  }

  /// Validate section order (check if positions are sequential)
  Future<bool> validateSectionOrder(String pageId) async {
    try {
      final sections = await getSectionsSortedByPosition(pageId: pageId);

      for (int i = 0; i < sections.length; i++) {
        if (sections[i].position != i) {
          return false;
        }
      }
      return true;
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error validating section order: $e');
    }
  }

  /// Fix section order (resequence positions to be sequential)
  Future<String> fixSectionOrder(String pageId) async {
    try {
      final sections = await getSectionsSortedByPosition(pageId: pageId);
      final orderedIds = sections.map((s) => s.id).toList();
      return await reorderSections(pageId: pageId, order: orderedIds);
    } catch (e) {
      if (e is AdminSectionsServiceException) rethrow;
      throw AdminSectionsServiceException('Error fixing section order: $e');
    }
  }
}

// Factory method to create service from auth service
class ClaudeAdminSectionsServiceFactory {
  static ClaudeAdminSectionsService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminSectionsService(domain: domain, authToken: authToken);
  }
}

// Example usage:
/*
void main() async {
  // Create service with auth token
  final adminSectionsService = ClaudeAdminSectionsService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here',
  );

  try {
    const pageId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

    // Get all sections for a page
    print('--- Getting Sections for Page ---');
    final sections = await adminSectionsService.getSections(pageId: pageId);
    print('Found ${sections.length} sections in page:');
    for (final section in sections) {
      print('- ${section.type} at position ${section.position} (${section.isEnabled ? 'enabled' : 'disabled'})');
    }

    // Create a new section
    print('\n--- Creating Section ---');
    final newSection = await adminSectionsService.createSection(
      pageId: pageId,
      type: 'hero',
      data: {
        'title': 'Welcome to our site',
        'subtitle': 'This is a hero section',
        'backgroundImage': 'https://example.com/hero.jpg',
      },
      position: 0,
    );
    print('Created section: ${newSection.type}');
    print('Section ID: ${newSection.id}');
    print('Position: ${newSection.position}');

    // Add section at the end
    print('\n--- Adding Section at End ---');
    final endSection = await adminSectionsService.addSectionAtEnd(
      pageId: pageId,
      type: 'footer',
      data: {
        'copyright': '© 2025 Our Company',
        'links': ['Privacy', 'Terms', 'Contact'],
      },
    );
    print('Added section at end: ${endSection.type} at position ${endSection.position}');

    // Add section at the beginning
    print('\n--- Adding Section at Beginning ---');
    final beginSection = await adminSectionsService.addSectionAtBeginning(
      pageId: pageId,
      type: 'header',
      data: {
        'logo': 'https://example.com/logo.png',
        'navigation': ['Home', 'About', 'Contact'],
      },
    );
    print('Added section at beginning: ${beginSection.type} at position ${beginSection.position}');

    // Get section with details
    print('\n--- Getting Section Details ---');
    final sectionDetails = await adminSectionsService.getSection(
      sectionId: newSection.id,
      includeSchema: true,
    );
    print('Section: ${sectionDetails.type}');
    print('Data: ${sectionDetails.data}');
    print('Created: ${sectionDetails.createdAt}');
    print('Updated: ${sectionDetails.updatedAt}');

    // Update section
    print('\n--- Updating Section ---');
    final updatedSection = await adminSectionsService.updateSection(
      sectionId: newSection.id,
      type: 'hero',
      data: {
        'title': 'Welcome to our amazing site',
        'subtitle': 'This is an updated hero section',
        'backgroundImage': 'https://example.com/new-hero.jpg',
        'ctaButton': 'Get Started',
      },
    );
    print('Updated section: ${updatedSection.type}');
    print('New data keys: ${updatedSection.data.keys.join(', ')}');

    // Disable section
    print('\n--- Disabling Section ---');
    final disabledSection = await adminSectionsService.disableSection(newSection.id);
    print('Section ${disabledSection.type} is now ${disabledSection.isEnabled ? 'enabled' : 'disabled'}');

    // Enable section
    print('\n--- Enabling Section ---');
    final enabledSection = await adminSectionsService.enableSection(newSection.id);
    print('Section ${enabledSection.type} is now ${enabledSection.isEnabled ? 'enabled' : 'disabled'}');

    // Get enabled sections only
    print('\n--- Getting Enabled Sections ---');
    final enabledSections = await adminSectionsService.getEnabledSections(pageId: pageId);
    print('Found ${enabledSections.length} enabled sections:');
    for (final section in enabledSections) {
      print('- ${section.type} at position ${section.position}');
    }

    // Get sections by type
    print('\n--- Getting Sections by Type ---');
    final heroSections = await adminSectionsService.getSectionsByType(
      pageId: pageId,
      type: 'hero',
    );
    print('Found ${heroSections.length} hero sections');

    // Get sections sorted by position
    print('\n--- Getting Sections Sorted by Position ---');
    final sortedSections = await adminSectionsService.getSectionsSortedByPosition(pageId: pageId);
    print('Sections in order:');
    for (final section in sortedSections) {
      print('${section.position}: ${section.type}');
    }

    // Move section up
    print('\n--- Moving Section Up ---');
    if (sortedSections.length > 1) {
      final sectionToMove = sortedSections[1]; // Move second section up
      await adminSectionsService.moveSectionUp(
        pageId: pageId,
        sectionId: sectionToMove.id,
      );
      print('Moved section ${sectionToMove.type} up');
    }

    // Move section down
    print('\n--- Moving Section Down ---');
    final newSortedSections = await adminSectionsService.getSectionsSortedByPosition(pageId: pageId);
    if (newSortedSections.length > 1) {
      final sectionToMove = newSortedSections[0]; // Move first section down
      await adminSectionsService.moveSectionDown(
        pageId: pageId,
        sectionId: sectionToMove.id,
      );
      print('Moved section ${sectionToMove.type} down');
    }

    // Reorder sections manually
    print('\n--- Reordering Sections ---');
    final currentSections = await adminSectionsService.getSectionsSortedByPosition(pageId: pageId);
    if (currentSections.length > 2) {
      // Reverse the order
      final reversedOrder = currentSections.reversed.map((s) => s.id).toList();
      await adminSectionsService.reorderSections(pageId: pageId, order: reversedOrder);
      print('Reordered sections in reverse order');
    }

    // Duplicate section
    print('\n--- Duplicating Section ---');
    final duplicatedSection = await adminSectionsService.duplicateSection(
      sectionId: newSection.id,
      newData: {
        'title': 'Duplicated Hero Section',
        'subtitle': 'This is a copy',
        'backgroundImage': 'https://example.com/duplicate-hero.jpg',
      },
    );
    print('Duplicated section: ${duplicatedSection.type} at position ${duplicatedSection.position}');

    // Insert section at specific position
    print('\n--- Inserting Section at Position ---');
    final insertedSection = await adminSectionsService.insertSectionAtPosition(
      pageId: pageId,
      type: 'testimonials',
      data: {
        'testimonials': [
          {'name': 'John Doe', 'text': 'Great service!'},
          {'name': 'Jane Smith', 'text': 'Highly recommended!'},
        ],
      },
      position: 2,
    );
    print('Inserted section: ${insertedSection.type} at position ${insertedSection.position}');

    // Get section statistics
    print('\n--- Section Statistics ---');
    final stats = await adminSectionsService.getSectionStatistics(pageId);
    print('Total sections: ${stats['total_sections']}');
    print('Enabled sections: ${stats['enabled_sections']}');
    print('Disabled sections: ${stats['disabled_sections']}');
    print('Section types: ${stats['types_count']}');
    print('Sections by type: ${stats['sections_by_type']}');
    if (stats['oldest_section'] != null) {
      final oldestSection = stats['oldest_section'] as Section;
      print('Oldest section: ${oldestSection.type} (${oldestSection.createdAt})');
    }
    if (stats['newest_section'] != null) {
      final newestSection = stats['newest_section'] as Section;
      print('Newest section: ${newestSection.type} (${newestSection.createdAt})');
    }

    // Get unique section types
    print('\n--- Section Types ---');
    final types = await adminSectionsService.getSectionTypes(pageId);
    print('Available section types: ${types.join(', ')}');

    // Validate section order
    print('\n--- Validating Section Order ---');
    final isValidOrder = await adminSectionsService.validateSectionOrder(pageId);
    print('Section order is ${isValidOrder ? 'valid' : 'invalid'}');
    
    if (!isValidOrder) {
      print('Fixing section order...');
      await adminSectionsService.fixSectionOrder(pageId);
      print('Section order fixed');
    }

    // Bulk operations
    print('\n--- Bulk Operations ---');
    final allSections = await adminSectionsService.getSections(pageId: pageId);
    final sectionIds = allSections.take(2).map((s) => s.id).toList();
    
    if (sectionIds.isNotEmpty) {
      // Bulk disable
      await adminSectionsService.bulkToggleSections(
        sectionIds: sectionIds,
        isEnabled: false,
      );
      print('Bulk disabled ${sectionIds.length} sections');
      
      // Bulk enable
      await adminSectionsService.bulkToggleSections(
        sectionIds: sectionIds,
        isEnabled: true,
      );
      print('Bulk enabled ${sectionIds.length} sections');
    }

    // Delete section (uncomment to test)
    // print('\n--- Deleting Section ---');
    // await adminSectionsService.deleteSection(duplicatedSection.id);
    // print('Deleted duplicated section');

  } on SectionsUnauthorizedException catch (e) {
    print('Authentication failed: ${e.message}');
    print('Make sure you have a valid auth token and appropriate privileges');
  } on SectionsValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on SectionsConflictException catch (e) {
    print('Conflict error: ${e.message}');
  } on SectionsNotFoundException catch (e) {
    print('Not found: ${e.message}');
  } on SectionsBadRequestException catch (e) {
    print('Bad request: ${e.apiError.detail}');
  } on SectionsForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
  } on AdminSectionsServiceException catch (e) {
    print('Admin sections service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example with pages service:
/*
void integratedExample() async {
  final authService = ClaudeAuthService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  try {
    // First authenticate
    final authResult = await authService.authenticateAndGetUser(
      email: 'admin@example.com',
      password: 'admin_password',
    );

    // Create services with the auth token
    final adminPagesService = ClaudeAdminPagesServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    final adminSectionsService = ClaudeAdminSectionsServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      authResult.token.accessToken,
    );

    // Get a project and its pages
    const projectId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
    final pages = await adminPagesService.getPages(projectId: projectId);
    
    if (pages.isEmpty) {
      print('No pages found. Create a page first.');
      return;
    }

    final firstPage = pages.first;
    print('Working with page: ${firstPage.title} (${firstPage.id})');

    // Add sections to the page
    final headerSection = await adminSectionsService.addSectionAtEnd(
      pageId: firstPage.id,
      type: 'header',
      data: {
        'logo': 'https://example.com/logo.png',
        'navigation': ['Home', 'About', 'Services', 'Contact'],
        'theme': 'dark',
      },
    );

    final heroSection = await adminSectionsService.addSectionAtEnd(
      pageId: firstPage.id,
      type: 'hero',
      data: {
        'title': 'Welcome to ${firstPage.title}',
        'subtitle': 'This page was created with our CMS',
        'backgroundImage': 'https://example.com/hero-bg.jpg',
        'ctaButton': {
          'text': 'Learn More',
          'link': '/about',
        },
      },
    );

    final contentSection = await adminSectionsService.addSectionAtEnd(
      pageId: firstPage.id,
      type: 'content',
      data: {
        'blocks': [
          {
            'type': 'paragraph',
            'content': 'This is the main content of the page.',
          },
          {
            'type': 'image',
            'src': 'https://example.com/content-image.jpg',
            'alt': 'Content image',
          },
        ],
      },
    );

    final footerSection = await adminSectionsService.addSectionAtEnd(
      pageId: firstPage.id,
      type: 'footer',
      data: {
        'copyright': '© 2025 Our Company',
        'socialLinks': [
          {'platform': 'facebook', 'url': 'https://facebook.com/ourcompany'},
          {'platform': 'twitter', 'url': 'https://twitter.com/ourcompany'},
        ],
        'links': [
          {'text': 'Privacy Policy', 'url': '/privacy'},
          {'text': 'Terms of Service', 'url': '/terms'},
        ],
      },
    );

    print('Created page structure:');
    print('1. Header: ${headerSection.id}');
    print('2. Hero: ${heroSection.id}');
    print('3. Content: ${contentSection.id}');
    print('4. Footer: ${footerSection.id}');

    // Get the page with all sections
    final pageWithSections = await adminPagesService.getPageWithSections(firstPage.id);
    print('\nPage "${pageWithSections.title}" now has ${pageWithSections.sections?.length ?? 0} sections');

  } catch (e) {
    print('Error: $e');
  }
}
*/
*/
