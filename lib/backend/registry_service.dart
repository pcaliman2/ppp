import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Component model
class Component {
  final String type;
  final List<int> versions;
  final int latest;

  Component({required this.type, required this.versions, required this.latest});

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      type: json['type'],
      versions: List<int>.from(json['versions'] ?? []),
      latest: json['latest'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'versions': versions, 'latest': latest};
  }

  @override
  String toString() {
    return 'Component(type: $type, versions: $versions, latest: $latest)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Component && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;

  /// Create a copy of this component with updated fields
  Component copyWith({String? type, List<int>? versions, int? latest}) {
    return Component(
      type: type ?? this.type,
      versions: versions ?? this.versions,
      latest: latest ?? this.latest,
    );
  }

  /// Check if a specific version exists
  bool hasVersion(int version) {
    return versions.contains(version);
  }

  /// Get all versions sorted in ascending order
  List<int> get sortedVersions {
    final sorted = List<int>.from(versions);
    sorted.sort();
    return sorted;
  }

  /// Get all versions sorted in descending order (newest first)
  List<int> get sortedVersionsDesc {
    final sorted = List<int>.from(versions);
    sorted.sort((a, b) => b.compareTo(a));
    return sorted;
  }

  /// Get the oldest version
  int? get oldestVersion {
    return versions.isEmpty ? null : versions.reduce((a, b) => a < b ? a : b);
  }

  /// Get the newest version
  int? get newestVersion {
    return versions.isEmpty ? null : versions.reduce((a, b) => a > b ? a : b);
  }
}

// Component schema model
class ComponentSchema {
  final String type;
  final int version;
  final Map<String, dynamic> jsonSchema;
  final Map<String, dynamic> uiMeta;

  ComponentSchema({
    required this.type,
    required this.version,
    required this.jsonSchema,
    required this.uiMeta,
  });

  factory ComponentSchema.fromJson(Map<String, dynamic> json) {
    return ComponentSchema(
      type: json['type'],
      version: json['version'],
      jsonSchema: Map<String, dynamic>.from(json['json_schema'] ?? {}),
      uiMeta: Map<String, dynamic>.from(json['ui_meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'version': version,
      'json_schema': jsonSchema,
      'ui_meta': uiMeta,
    };
  }

  @override
  String toString() {
    return 'ComponentSchema(type: $type, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComponentSchema &&
        other.type == type &&
        other.version == version;
  }

  @override
  int get hashCode => Object.hash(type, version);

  /// Create a copy of this schema with updated fields
  ComponentSchema copyWith({
    String? type,
    int? version,
    Map<String, dynamic>? jsonSchema,
    Map<String, dynamic>? uiMeta,
  }) {
    return ComponentSchema(
      type: type ?? this.type,
      version: version ?? this.version,
      jsonSchema: jsonSchema ?? this.jsonSchema,
      uiMeta: uiMeta ?? this.uiMeta,
    );
  }

  /// Get schema properties
  Map<String, dynamic>? get properties {
    return jsonSchema['properties'] as Map<String, dynamic>?;
  }

  /// Get required fields
  List<String>? get required {
    final req = jsonSchema['required'];
    return req is List ? List<String>.from(req) : null;
  }

  /// Get schema title
  String? get title {
    return jsonSchema['title'] as String?;
  }

  /// Get schema description
  String? get description {
    return jsonSchema['description'] as String?;
  }

  /// Check if a field is required
  bool isFieldRequired(String fieldName) {
    final requiredFields = required;
    return requiredFields?.contains(fieldName) ?? false;
  }

  /// Get UI metadata for a specific field
  Map<String, dynamic>? getFieldUiMeta(String fieldName) {
    final fieldMeta = uiMeta[fieldName];
    return fieldMeta is Map<String, dynamic> ? fieldMeta : null;
  }

  /// Get all field names from schema properties
  List<String> get fieldNames {
    return properties?.keys.toList() ?? [];
  }
}

// Custom Exceptions
class RegistryServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  RegistryServiceException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'RegistryServiceException: $message';
}

class RegistryValidationException extends RegistryServiceException {
  final ValidationError validationError;

  RegistryValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class RegistryBadRequestException extends RegistryServiceException {
  final ApiError apiError;

  RegistryBadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class RegistryUnauthorizedException extends RegistryServiceException {
  RegistryUnauthorizedException(super.message) : super(statusCode: 401);
}

class RegistryForbiddenException extends RegistryServiceException {
  RegistryForbiddenException(super.message) : super(statusCode: 403);
}

class RegistryConflictException extends RegistryServiceException {
  RegistryConflictException(super.message) : super(statusCode: 409);
}

class RegistryNotFoundException extends RegistryServiceException {
  RegistryNotFoundException(super.message) : super(statusCode: 404);
}

// Registry Service
class RegistryService {
  final String domain;
  String? _authToken;

  RegistryService({required this.domain, String? authToken})
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
      throw RegistryBadRequestException(ApiError.fromJson(errorData));
    } else if (response.statusCode == 401) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Unauthorized';
      throw RegistryUnauthorizedException(detail);
    } else if (response.statusCode == 403) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Forbidden';
      throw RegistryForbiddenException(detail);
    } else if (response.statusCode == 404) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Not found';
      throw RegistryNotFoundException(detail);
    } else if (response.statusCode == 409) {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? 'Conflict';
      throw RegistryConflictException(detail);
    } else if (response.statusCode == 422) {
      final errorData = json.decode(responseBody);
      throw RegistryValidationException(ValidationError.fromJson(errorData));
    } else {
      throw RegistryServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// List components & versions
  Future<List<Component>> getComponents() async {
    final url = Uri.parse('$domain/registry/v1/components');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (componentJson) =>
                    Component.fromJson(componentJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw RegistryServiceException(
            'Expected list of components, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting components: $e');
    }
  }

  /// Get latest schema for a type
  Future<ComponentSchema> getLatestSchema(String type) async {
    final url = Uri.parse('$domain/registry/v1/components/$type');

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return ComponentSchema.fromJson(data);
        } else {
          throw RegistryServiceException(
            'Expected component schema object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting latest schema for type "$type": $e',
      );
    }
  }

  /// Get specific version schema
  Future<ComponentSchema> getSchemaVersion(String type, int version) async {
    final url = Uri.parse(
      '$domain/registry/v1/components/$type/versions/$version',
    );

    try {
      final response = await http.get(url, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return ComponentSchema.fromJson(data);
        } else {
          throw RegistryServiceException(
            'Expected component schema object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting schema for type "$type" version $version: $e',
      );
    }
  }

  // Helper methods

  /// Get all component types
  Future<List<String>> getComponentTypes() async {
    try {
      final components = await getComponents();
      return components.map((c) => c.type).toList()..sort();
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting component types: $e');
    }
  }

  /// Get component by type
  Future<Component?> getComponent(String type) async {
    try {
      final components = await getComponents();
      try {
        return components.firstWhere((component) => component.type == type);
      } on StateError {
        return null; // Not found
      }
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting component "$type": $e');
    }
  }

  /// Check if component type exists
  Future<bool> componentExists(String type) async {
    try {
      final component = await getComponent(type);
      return component != null;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error checking if component "$type" exists: $e',
      );
    }
  }

  /// Check if specific version exists for a component
  Future<bool> versionExists(String type, int version) async {
    try {
      final component = await getComponent(type);
      return component?.hasVersion(version) ?? false;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error checking if version $version exists for "$type": $e',
      );
    }
  }

  /// Get all versions for a component type
  Future<List<int>> getVersions(String type) async {
    try {
      final component = await getComponent(type);
      return component?.versions ?? [];
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting versions for "$type": $e');
    }
  }

  /// Get latest version number for a component type
  Future<int?> getLatestVersion(String type) async {
    try {
      final component = await getComponent(type);
      return component?.latest;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting latest version for "$type": $e',
      );
    }
  }

  /// Get oldest version number for a component type
  Future<int?> getOldestVersion(String type) async {
    try {
      final component = await getComponent(type);
      return component?.oldestVersion;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting oldest version for "$type": $e',
      );
    }
  }

  /// Get sorted versions for a component type
  Future<List<int>> getSortedVersions(
    String type, {
    bool ascending = true,
  }) async {
    try {
      final component = await getComponent(type);
      if (component == null) return [];

      return ascending
          ? component.sortedVersions
          : component.sortedVersionsDesc;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting sorted versions for "$type": $e',
      );
    }
  }

  /// Get all schemas for a component type (all versions)
  Future<List<ComponentSchema>> getAllSchemas(String type) async {
    try {
      final versions = await getVersions(type);
      final schemas = <ComponentSchema>[];

      for (final version in versions) {
        try {
          final schema = await getSchemaVersion(type, version);
          schemas.add(schema);
        } catch (e) {
          // Skip versions that can't be retrieved
          continue;
        }
      }

      // Sort by version
      schemas.sort((a, b) => a.version.compareTo(b.version));
      return schemas;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting all schemas for "$type": $e',
      );
    }
  }

  /// Search components by type pattern
  Future<List<Component>> searchComponents(String pattern) async {
    try {
      final components = await getComponents();
      final lowercasePattern = pattern.toLowerCase();

      return components
          .where(
            (component) =>
                component.type.toLowerCase().contains(lowercasePattern),
          )
          .toList();
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error searching components: $e');
    }
  }

  /// Get components count
  Future<int> getComponentsCount() async {
    try {
      final components = await getComponents();
      return components.length;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting components count: $e');
    }
  }

  /// Get components with multiple versions
  Future<List<Component>> getComponentsWithMultipleVersions() async {
    try {
      final components = await getComponents();
      return components
          .where((component) => component.versions.length > 1)
          .toList();
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting components with multiple versions: $e',
      );
    }
  }

  /// Get components with single version
  Future<List<Component>> getComponentsWithSingleVersion() async {
    try {
      final components = await getComponents();
      return components
          .where((component) => component.versions.length == 1)
          .toList();
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting components with single version: $e',
      );
    }
  }

  /// Get total versions count across all components
  Future<int> getTotalVersionsCount() async {
    try {
      final components = await getComponents();
      return components.fold<int>(
        0,
        (total, component) => total + component.versions.length,
      );
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting total versions count: $e');
    }
  }

  /// Get component statistics
  Future<Map<String, dynamic>> getComponentStatistics() async {
    try {
      final components = await getComponents();

      if (components.isEmpty) {
        return {
          'total_components': 0,
          'total_versions': 0,
          'components_with_multiple_versions': 0,
          'components_with_single_version': 0,
          'average_versions_per_component': 0.0,
          'most_versioned_component': null,
          'least_versioned_component': null,
        };
      }

      final totalVersions = components.fold(
        0,
        (total, c) => total + c.versions.length,
      );
      final multipleVersions =
          components.where((c) => c.versions.length > 1).length;
      final singleVersion =
          components.where((c) => c.versions.length == 1).length;

      final mostVersioned = components.reduce(
        (a, b) => a.versions.length > b.versions.length ? a : b,
      );
      final leastVersioned = components.reduce(
        (a, b) => a.versions.length < b.versions.length ? a : b,
      );

      return {
        'total_components': components.length,
        'total_versions': totalVersions,
        'components_with_multiple_versions': multipleVersions,
        'components_with_single_version': singleVersion,
        'average_versions_per_component': totalVersions / components.length,
        'most_versioned_component': {
          'type': mostVersioned.type,
          'versions_count': mostVersioned.versions.length,
        },
        'least_versioned_component': {
          'type': leastVersioned.type,
          'versions_count': leastVersioned.versions.length,
        },
      };
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting component statistics: $e');
    }
  }

  /// Get components grouped by version count
  Future<Map<int, List<Component>>> getComponentsGroupedByVersionCount() async {
    try {
      final components = await getComponents();
      final Map<int, List<Component>> grouped = {};

      for (final component in components) {
        final versionCount = component.versions.length;
        if (!grouped.containsKey(versionCount)) {
          grouped[versionCount] = [];
        }
        grouped[versionCount]!.add(component);
      }

      return grouped;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error grouping components by version count: $e',
      );
    }
  }

  /// Get components sorted by type name
  Future<List<Component>> getComponentsSorted({bool ascending = true}) async {
    try {
      final components = await getComponents();
      components.sort((a, b) {
        final comparison = a.type.toLowerCase().compareTo(b.type.toLowerCase());
        return ascending ? comparison : -comparison;
      });
      return components;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting sorted components: $e');
    }
  }

  /// Get components sorted by version count
  Future<List<Component>> getComponentsSortedByVersionCount({
    bool ascending = true,
  }) async {
    try {
      final components = await getComponents();
      components.sort((a, b) {
        final comparison = a.versions.length.compareTo(b.versions.length);
        return ascending ? comparison : -comparison;
      });
      return components;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting components sorted by version count: $e',
      );
    }
  }

  /// Get components sorted by latest version
  Future<List<Component>> getComponentsSortedByLatestVersion({
    bool ascending = true,
  }) async {
    try {
      final components = await getComponents();
      components.sort((a, b) {
        final comparison = a.latest.compareTo(b.latest);
        return ascending ? comparison : -comparison;
      });
      return components;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error getting components sorted by latest version: $e',
      );
    }
  }

  /// Validate schema data against a specific component schema
  Future<bool> validateDataAgainstSchema({
    required String type,
    required Map<String, dynamic> data,
    int? version,
  }) async {
    try {
      final schema =
          version != null
              ? await getSchemaVersion(type, version)
              : await getLatestSchema(type);

      // Basic validation - check required fields
      final requiredFields = schema.required ?? [];
      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          return false;
        }
      }

      // Additional validation could be implemented here using the JSON schema
      // For now, just check required fields
      return true;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException(
        'Error validating data against schema: $e',
      );
    }
  }

  /// Get field information from schema
  Future<Map<String, dynamic>?> getFieldInfo({
    required String type,
    required String fieldName,
    int? version,
  }) async {
    try {
      final schema =
          version != null
              ? await getSchemaVersion(type, version)
              : await getLatestSchema(type);

      final properties = schema.properties;
      final fieldSchema = properties?[fieldName];

      if (fieldSchema == null) return null;

      return {
        'schema': fieldSchema,
        'ui_meta': schema.getFieldUiMeta(fieldName),
        'required': schema.isFieldRequired(fieldName),
      };
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting field info: $e');
    }
  }

  /// Compare schemas between versions
  Future<Map<String, dynamic>> compareSchemaVersions({
    required String type,
    required int fromVersion,
    required int toVersion,
  }) async {
    try {
      final fromSchema = await getSchemaVersion(type, fromVersion);
      final toSchema = await getSchemaVersion(type, toVersion);

      final fromFields = fromSchema.fieldNames.toSet();
      final toFields = toSchema.fieldNames.toSet();

      final addedFields = toFields.difference(fromFields).toList()..sort();
      final removedFields = fromFields.difference(toFields).toList()..sort();
      final commonFields = fromFields.intersection(toFields).toList()..sort();

      return {
        'from_version': fromVersion,
        'to_version': toVersion,
        'added_fields': addedFields,
        'removed_fields': removedFields,
        'common_fields': commonFields,
        'fields_changed': addedFields.isNotEmpty || removedFields.isNotEmpty,
      };
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error comparing schema versions: $e');
    }
  }

  /// Get version history for a component
  Future<List<Map<String, dynamic>>> getVersionHistory(String type) async {
    try {
      final versions = await getSortedVersions(type, ascending: false);
      final history = <Map<String, dynamic>>[];

      for (final version in versions) {
        try {
          final schema = await getSchemaVersion(type, version);
          history.add({
            'version': version,
            'title': schema.title,
            'description': schema.description,
            'field_count': schema.fieldNames.length,
            'required_field_count': schema.required?.length ?? 0,
          });
        } catch (e) {
          // Skip versions that can't be retrieved
          continue;
        }
      }

      return history;
    } catch (e) {
      if (e is RegistryServiceException) rethrow;
      throw RegistryServiceException('Error getting version history: $e');
    }
  }
}

// Factory method to create service from auth service
class RegistryServiceFactory {
  static RegistryService fromAuthService(String domain, String? authToken) {
    return RegistryService(domain: domain, authToken: authToken);
  }
}

// Example usage:
/*
void main() async {
  // Create service (auth token is optional for registry endpoints)
  final registryService = RegistryService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here', // Optional
  );

  try {
    // Get all components
    print('--- Getting All Components ---');
    final components = await registryService.getComponents();
    print('Found ${components.length} component types:');
    for (final component in components) {
      print('- ${component.type}: ${component.versions.length} versions (latest: ${component.latest})');
    }

    // Get component types
    print('\n--- Component Types ---');
    final types = await registryService.getComponentTypes();
    print('Available types: ${types.join(', ')}');

    if (types.isNotEmpty) {
      final firstType = types.first;
      
      // Get latest schema for a component type
      print('\n--- Getting Latest Schema ---');
      final latestSchema = await registryService.getLatestSchema(firstType);
      print('Latest schema for "$firstType":');
      print('Version: ${latestSchema.version}');
      print('Title: ${latestSchema.title ?? 'No title'}');
      print('Description: ${latestSchema.description ?? 'No description'}');
      print('Fields: ${latestSchema.fieldNames.join(', ')}');
      print('Required fields: ${latestSchema.required?.join(', ') ?? 'None'}');

      // Get all versions for this type
      print('\n--- Getting All Versions ---');
      final versions = await registryService.getVersions(firstType);
      print('Versions for "$firstType": ${versions.join(', ')}');

      // Get specific version schema if multiple versions exist
      if (versions.length > 1) {
        print('\n--- Getting Specific Version Schema ---');
        final oldestVersion = await registryService.getOldestVersion(firstType);
        if (oldestVersion != null) {
          final oldSchema = await registryService.getSchemaVersion(firstType, oldestVersion);
          print('Schema for "$firstType" version $oldestVersion:');
          print('Fields: ${oldSchema.fieldNames.join(', ')}');
          print('Required fields: ${oldSchema.required?.join(', ') ?? 'None'}');
        }
      }

      // Get all schemas for this type
      print('\n--- Getting All Schemas ---');
      final allSchemas = await registryService.getAllSchemas(firstType);
      print('All schemas for "$firstType":');
      for (final schema in allSchemas) {
        print('Version ${schema.version}: ${schema.fieldNames.length} fields');
      }

      // Get version history
      print('\n--- Version History ---');
      final history = await registryService.getVersionHistory(firstType);
      print('Version history for "$firstType":');
      for (final version in history) {
        print('v${version['version']}: ${version['field_count']} fields, ${version['required_field_count']} required');
      }

      // Compare versions if multiple exist
      if (versions.length > 1) {
        print('\n--- Comparing Versions ---');
        final sortedVersions = await registryService.getSortedVersions(firstType);
        if (sortedVersions.length >= 2) {
          final comparison = await registryService.compareSchemaVersions(
            type: firstType,
            fromVersion: sortedVersions[0],
            toVersion: sortedVersions[1],
          );
          print('Changes from v${comparison['from_version']} to v${comparison['to_version']}:');
          print('Added fields: ${(comparison['added_fields'] as List).join(', ')}');
          print('Removed fields: ${(comparison['removed_fields'] as List).join(', ')}');
          print('Fields changed: ${comparison['fields_changed']}');
        }
      }

      // Get field information
      print('\n--- Field Information ---');
      final fieldNames = latestSchema.fieldNames;
      if (fieldNames.isNotEmpty) {
        final fieldInfo = await registryService.getFieldInfo(
          type: firstType,
          fieldName: fieldNames.first,
        );
        if (fieldInfo != null) {
          print('Field "${fieldNames.first}":');
          print('Required: ${fieldInfo['required']}');
          print('Schema: ${fieldInfo['schema']}');
          print('UI Meta: ${fieldInfo['ui_meta']}');
        }
      }

      // Validate data against schema
      print('\n--- Validating Data ---');
      final testData = <String, dynamic>{};
      
      // Add required fields with dummy data
      final requiredFields = latestSchema.required ?? [];
      for (final field in requiredFields) {
        testData[field] = 'test_value';
      }
      
      final isValid = await registryService.validateDataAgainstSchema(
        type: firstType,
        data: testData,
      );
      print('Test data validation: ${isValid ? 'PASSED' : 'FAILED'}');
      
      // Test with missing required field
      if (requiredFields.isNotEmpty) {
        final incompleteData = Map<String, dynamic>.from(testData);
        incompleteData.remove(requiredFields.first);
        
        final isIncompleteValid = await registryService.validateDataAgainstSchema(
          type: firstType,
          data: incompleteData,
        );
        print('Incomplete data validation: ${isIncompleteValid ? 'PASSED' : 'FAILED'}');
      }
    }

    // Search components
    print('\n--- Searching Components ---');
    final searchResults = await registryService.searchComponents('text');
    print('Components matching "text": ${searchResults.map((c) => c.type).join(', ')}');

    // Get component statistics
    print('\n--- Component Statistics ---');
    final stats = await registryService.getComponentStatistics();
    print('Total components: ${stats['total_components']}');
    print('Total versions: ${stats['total_versions']}');
    print('Components with multiple versions: ${stats['components_with_multiple_versions']}');
    print('Components with single version: ${stats['components_with_single_version']}');
    print('Average versions per component: ${stats['average_versions_per_component'].toStringAsFixed(2)}');
    
    if (stats['most_versioned_component'] != null) {
      final mostVersioned = stats['most_versioned_component'];
      print('Most versioned: ${mostVersioned['type']} (${mostVersioned['versions_count']} versions)');
    }
    
    if (stats['least_versioned_component'] != null) {
      final leastVersioned = stats['least_versioned_component'];
      print('Least versioned: ${leastVersioned['type']} (${leastVersioned['versions_count']} versions)');
    }

    // Get components with multiple versions
    print('\n--- Components with Multiple Versions ---');
    final multiVersionComponents = await registryService.getComponentsWithMultipleVersions();
    print('Components with multiple versions:');
    for (final component in multiVersionComponents) {
      print('- ${component.type}: versions ${component.versions.join(', ')}');
    }

    // Get components grouped by version count
    print('\n--- Components Grouped by Version Count ---');
    final grouped = await registryService.getComponentsGroupedByVersionCount();
    grouped.forEach((versionCount, componentList) {
      print('$versionCount version(s): ${componentList.map((c) => c.type).join(', ')}');
    });

    // Get components sorted by different criteria
    print('\n--- Components Sorted by Type ---');
    final sortedByType = await registryService.getComponentsSorted();
    print('Sorted by type: ${sortedByType.map((c) => c.type).join(', ')}');

    print('\n--- Components Sorted by Version Count ---');
    final sortedByVersionCount = await registryService.getComponentsSortedByVersionCount(ascending: false);
    print('Sorted by version count (desc):');
    for (final component in sortedByVersionCount) {
      print('- ${component.type}: ${component.versions.length} versions');
    }

    print('\n--- Components Sorted by Latest Version ---');
    final sortedByLatestVersion = await registryService.getComponentsSortedByLatestVersion(ascending: false);
    print('Sorted by latest version (desc):');
    for (final component in sortedByLatestVersion) {
      print('- ${component.type}: latest v${component.latest}');
    }

    // Check component and version existence
    print('\n--- Existence Checks ---');
    final componentExists = await registryService.componentExists('hero');
    print('Component "hero" exists: $componentExists');
    
    if (componentExists) {
      final versionExists = await registryService.versionExists('hero', 1);
      print('Version 1 exists for "hero": $versionExists');
    }

    // Get total counts
    print('\n--- Counts ---');
    final componentCount = await registryService.getComponentsCount();
    final totalVersionsCount = await registryService.getTotalVersionsCount();
    print('Total components: $componentCount');
    print('Total versions across all components: $totalVersionsCount');

  } on RegistryUnauthorizedException catch (e) {
    print('Authentication failed: ${e.message}');
    print('Note: Registry endpoints may not require authentication');
  } on RegistryValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on RegistryNotFoundException catch (e) {
    print('Not found: ${e.message}');
  } on RegistryBadRequestException catch (e) {
    print('Bad request: ${e.apiError.detail}');
  } on RegistryForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
  } on RegistryServiceException catch (e) {
    print('Registry service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example with sections service:
/*
void integratedExample() async {
  final registryService = RegistryService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
  );

  final sectionsService = ClaudeAdminSectionsService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_auth_token_here',
  );

  try {
    // Get available component types from registry
    final componentTypes = await registryService.getComponentTypes();
    print('Available component types: ${componentTypes.join(', ')}');

    if (componentTypes.isNotEmpty) {
      final heroType = componentTypes.firstWhere(
        (type) => type.toLowerCase().contains('hero'),
        orElse: () => componentTypes.first,
      );

      // Get the schema for this component type
      final schema = await registryService.getLatestSchema(heroType);
      print('Using component type: $heroType (v${schema.version})');
      print('Required fields: ${schema.required?.join(', ') ?? 'None'}');
      print('Available fields: ${schema.fieldNames.join(', ')}');

      // Create sample data based on the schema
      final sampleData = <String, dynamic>{};
      
      // Add required fields
      final requiredFields = schema.required ?? [];
      for (final field in requiredFields) {
        final fieldInfo = await registryService.getFieldInfo(
          type: heroType,
          fieldName: field,
        );
        
        // Generate sample data based on field type or use defaults
        switch (field.toLowerCase()) {
          case 'title':
            sampleData[field] = 'Welcome to Our Site';
            break;
          case 'subtitle':
            sampleData[field] = 'This is a hero section created dynamically';
            break;
          case 'image':
          case 'backgroundimage':
            sampleData[field] = 'https://example.com/hero-bg.jpg';
            break;
          case 'button':
          case 'cta':
            sampleData[field] = {
              'text': 'Get Started',
              'url': '/signup',
            };
            break;
          default:
            sampleData[field] = 'Sample value for $field';
        }
      }

      // Validate the data against the schema
      final isValid = await registryService.validateDataAgainstSchema(
        type: heroType,
        data: sampleData,
      );
      
      if (isValid) {
        print('Sample data is valid for schema');
        
        // Create a section using the validated data
        const pageId = '3fa85f64-5717-4562-b3fc-2c963f66afa6'; // Replace with actual page ID
        
        final newSection = await sectionsService.createSection(
          pageId: pageId,
          type: heroType,
          data: sampleData,
          position: 0,
          schemaVersion: schema.version,
        );
        
        print('Created section:');
        print('ID: ${newSection.id}');
        print('Type: ${newSection.type}');
        print('Position: ${newSection.position}');
        print('Data: ${newSection.data}');
      } else {
        print('Sample data failed validation');
      }
    }

    // Get schema evolution for a component
    if (componentTypes.isNotEmpty) {
      final firstType = componentTypes.first;
      final versions = await registryService.getSortedVersions(firstType);
      
      if (versions.length > 1) {
        print('\nSchema evolution for "$firstType":');
        
        for (int i = 1; i < versions.length; i++) {
          final comparison = await registryService.compareSchemaVersions(
            type: firstType,
            fromVersion: versions[i - 1],
            toVersion: versions[i],
          );
          
          print('v${versions[i - 1]} → v${versions[i]}:');
          final added = comparison['added_fields'] as List;
          final removed = comparison['removed_fields'] as List;
          
          if (added.isNotEmpty) {
            print('  + Added: ${added.join(', ')}');
          }
          if (removed.isNotEmpty) {
            print('  - Removed: ${removed.join(', ')}');
          }
          if (added.isEmpty && removed.isEmpty) {
            print('  No field changes');
          }
        }
      }
    }

  } catch (e) {
    print('Integration error: $e');
  }
}

// Helper function to generate form fields from schema
Map<String, dynamic> generateFormFieldsFromSchema(ComponentSchema schema) {
  final formFields = <String, dynamic>{};
  
  for (final fieldName in schema.fieldNames) {
    final fieldSchema = schema.properties?[fieldName] as Map<String, dynamic>?;
    final uiMeta = schema.getFieldUiMeta(fieldName);
    final isRequired = schema.isFieldRequired(fieldName);
    
    formFields[fieldName] = {
      'type': fieldSchema?['type'] ?? 'string',
      'title': fieldSchema?['title'] ?? fieldName,
      'description': fieldSchema?['description'],
      'required': isRequired,
      'ui_meta': uiMeta,
      'enum': fieldSchema?['enum'],
      'default': fieldSchema?['default'],
      'minimum': fieldSchema?['minimum'],
      'maximum': fieldSchema?['maximum'],
      'minLength': fieldSchema?['minLength'],
      'maxLength': fieldSchema?['maxLength'],
      'pattern': fieldSchema?['pattern'],
    };
  }
  
  return formFields;
}

// Helper function to validate form data
List<String> validateFormData(
  ComponentSchema schema,
  Map<String, dynamic> formData,
) {
  final errors = <String>[];
  
  // Check required fields
  final requiredFields = schema.required ?? [];
  for (final field in requiredFields) {
    if (!formData.containsKey(field) || 
        formData[field] == null || 
        (formData[field] is String && (formData[field] as String).isEmpty)) {
      errors.add('Field "$field" is required');
    }
  }
  
  // Additional validation based on schema constraints could be added here
  
  return errors;
}
*/
*/
