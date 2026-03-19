import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/backend/models/api_error.dart';
import 'package:owa_flutter/backend/models/validation_error.dart';

// Membership model
class Membership {
  final String id;
  final String userId;
  final String orgId;
  final String role;
  final DateTime createdAt;

  Membership({
    required this.id,
    required this.userId,
    required this.orgId,
    required this.role,
    required this.createdAt,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'],
      userId: json['user_id'],
      orgId: json['org_id'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'org_id': orgId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Membership(id: $id, userId: $userId, orgId: $orgId, role: $role, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Membership && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy of this membership with updated fields
  Membership copyWith({
    String? id,
    String? userId,
    String? orgId,
    String? role,
    DateTime? createdAt,
  }) {
    return Membership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orgId: orgId ?? this.orgId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Request models
class CreateMembershipRequest {
  final String userId;
  final String orgId;
  final String role;

  CreateMembershipRequest({
    required this.userId,
    required this.orgId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'org_id': orgId, 'role': role};
  }

  @override
  String toString() {
    return 'CreateMembershipRequest(userId: $userId, orgId: $orgId, role: $role)';
  }
}

// Extended models for rich data operations
class MembershipWithUserInfo {
  final Membership membership;
  final String? userEmail;
  final String? userFullName;
  final bool? isUserActive;

  MembershipWithUserInfo({
    required this.membership,
    this.userEmail,
    this.userFullName,
    this.isUserActive,
  });

  @override
  String toString() {
    return 'MembershipWithUserInfo(membership: $membership, userEmail: $userEmail, userFullName: $userFullName)';
  }
}

class MembershipWithOrgInfo {
  final Membership membership;
  final String? orgName;
  final String? orgSlug;

  MembershipWithOrgInfo({required this.membership, this.orgName, this.orgSlug});

  @override
  String toString() {
    return 'MembershipWithOrgInfo(membership: $membership, orgName: $orgName, orgSlug: $orgSlug)';
  }
}

// Common role constants
class MembershipRoles {
  static const String admin = 'admin';
  static const String member = 'member';
  static const String viewer = 'viewer';
  static const String owner = 'owner';
  static const String contributor = 'contributor';

  static const List<String> allRoles = [
    admin,
    member,
    viewer,
    owner,
    contributor,
  ];

  static bool isValidRole(String role) {
    return allRoles.contains(role.toLowerCase());
  }
}

// Custom Exceptions
class AdminMembershipsServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AdminMembershipsServiceException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'AdminMembershipsServiceException: $message';
}

class ValidationException extends AdminMembershipsServiceException {
  final ValidationError validationError;

  ValidationException(this.validationError)
    : super('Validation failed', statusCode: 422, details: validationError);
}

class BadRequestException extends AdminMembershipsServiceException {
  final ApiError apiError;

  BadRequestException(this.apiError)
    : super(apiError.detail, statusCode: 400, details: apiError);
}

class UnauthorizedException extends AdminMembershipsServiceException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AdminMembershipsServiceException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class ConflictException extends AdminMembershipsServiceException {
  ConflictException(super.message) : super(statusCode: 409);
}

class NotFoundException extends AdminMembershipsServiceException {
  NotFoundException(super.message) : super(statusCode: 404);
}

// Admin Memberships Service
class ClaudeAdminMembershipsService {
  final String domain;
  String? _authToken;

  ClaudeAdminMembershipsService({required this.domain, String? authToken})
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
      throw AdminMembershipsServiceException(
        'Request failed with status ${response.statusCode}: $responseBody',
        statusCode: response.statusCode,
      );
    }
  }

  /// Create a new membership - Add user to organization (superadmin only)
  Future<Membership> createMembership({
    required String userId,
    required String orgId,
    required String role,
  }) async {
    final url = Uri.parse('$domain/admin/memberships');
    final request = CreateMembershipRequest(
      userId: userId,
      orgId: orgId,
      role: role,
    );

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(request.toJson()),
      );

      return await _handleResponse(response, (data) {
        if (data is Map<String, dynamic>) {
          return Membership.fromJson(data);
        } else {
          throw AdminMembershipsServiceException(
            'Expected membership object, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException('Error creating membership: $e');
    }
  }

  /// Add user to organization with role validation
  Future<Membership> addUserToOrganization({
    required String userId,
    required String orgId,
    required String role,
  }) async {
    // Validate role
    if (!MembershipRoles.isValidRole(role)) {
      throw ValidationException(
        ValidationError.fromJson({
          'detail': [
            {
              'loc': ['body', 'role'],
              'msg':
                  'Invalid role. Must be one of: ${MembershipRoles.allRoles.join(', ')}',
              'type': 'value_error',
            },
          ],
        }),
      );
    }

    return await createMembership(
      userId: userId,
      orgId: orgId,
      role: role.toLowerCase(),
    );
  }

  // Note: Since only POST endpoint is provided, the following methods are
  // conceptual and would need GET endpoints to be implemented in the API

  /// Get memberships (conceptual - would need API endpoint)
  /// This method shows how it would work if GET /admin/memberships existed
  Future<List<Membership>> getMemberships({
    String? userId,
    String? orgId,
    String? role,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['user_id'] = userId;
    if (orgId != null) queryParams['org_id'] = orgId;
    if (role != null) queryParams['role'] = role;

    final uri = Uri.parse(
      '$domain/admin/memberships',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _getAuthHeaders());

      return await _handleResponse(response, (data) {
        if (data is List) {
          return data
              .map(
                (membershipJson) =>
                    Membership.fromJson(membershipJson as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw AdminMembershipsServiceException(
            'Expected list of memberships, got: ${data.runtimeType}',
          );
        }
      });
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException('Error getting memberships: $e');
    }
  }

  /// Get memberships for a specific user
  Future<List<Membership>> getUserMemberships(String userId) async {
    return await getMemberships(userId: userId);
  }

  /// Get memberships for a specific organization
  Future<List<Membership>> getOrganizationMemberships(String orgId) async {
    return await getMemberships(orgId: orgId);
  }

  /// Get memberships by role
  Future<List<Membership>> getMembershipsByRole(String role) async {
    return await getMemberships(role: role);
  }

  /// Check if user is member of organization
  Future<bool> isUserMemberOfOrganization(String userId, String orgId) async {
    try {
      final memberships = await getMemberships(userId: userId, orgId: orgId);
      return memberships.isNotEmpty;
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException(
        'Error checking user membership: $e',
      );
    }
  }

  /// Get user's role in organization
  Future<String?> getUserRoleInOrganization(String userId, String orgId) async {
    try {
      final memberships = await getMemberships(userId: userId, orgId: orgId);
      return memberships.isNotEmpty ? memberships.first.role : null;
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException('Error getting user role: $e');
    }
  }

  /// Get organization members count
  Future<int> getOrganizationMembersCount(String orgId) async {
    try {
      final memberships = await getOrganizationMemberships(orgId);
      return memberships.length;
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException('Error getting members count: $e');
    }
  }

  /// Get organization members by role
  Future<List<Membership>> getOrganizationMembersByRole(
    String orgId,
    String role,
  ) async {
    try {
      final memberships = await getOrganizationMemberships(orgId);
      return memberships
          .where(
            (membership) => membership.role.toLowerCase() == role.toLowerCase(),
          )
          .toList();
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException(
        'Error getting members by role: $e',
      );
    }
  }

  /// Get organization admins
  Future<List<Membership>> getOrganizationAdmins(String orgId) async {
    return await getOrganizationMembersByRole(orgId, MembershipRoles.admin);
  }

  /// Get organization owners
  Future<List<Membership>> getOrganizationOwners(String orgId) async {
    return await getOrganizationMembersByRole(orgId, MembershipRoles.owner);
  }

  /// Get all memberships grouped by organization
  Future<Map<String, List<Membership>>>
  getMembershipsGroupedByOrganization() async {
    try {
      final memberships = await getMemberships();
      final Map<String, List<Membership>> grouped = {};

      for (final membership in memberships) {
        if (!grouped.containsKey(membership.orgId)) {
          grouped[membership.orgId] = [];
        }
        grouped[membership.orgId]!.add(membership);
      }

      return grouped;
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException(
        'Error grouping memberships by organization: $e',
      );
    }
  }

  /// Get all memberships grouped by user
  Future<Map<String, List<Membership>>> getMembershipsGroupedByUser() async {
    try {
      final memberships = await getMemberships();
      final Map<String, List<Membership>> grouped = {};

      for (final membership in memberships) {
        if (!grouped.containsKey(membership.userId)) {
          grouped[membership.userId] = [];
        }
        grouped[membership.userId]!.add(membership);
      }

      return grouped;
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException(
        'Error grouping memberships by user: $e',
      );
    }
  }

  /// Get all memberships grouped by role
  Future<Map<String, List<Membership>>> getMembershipsGroupedByRole() async {
    try {
      final memberships = await getMemberships();
      final Map<String, List<Membership>> grouped = {};

      for (final membership in memberships) {
        final role = membership.role.toLowerCase();
        if (!grouped.containsKey(role)) {
          grouped[role] = [];
        }
        grouped[role]!.add(membership);
      }

      return grouped;
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException(
        'Error grouping memberships by role: $e',
      );
    }
  }

  /// Get membership statistics
  Future<Map<String, dynamic>> getMembershipStatistics() async {
    try {
      final memberships = await getMemberships();
      final roleGroups = await getMembershipsGroupedByRole();
      final orgGroups = await getMembershipsGroupedByOrganization();
      final userGroups = await getMembershipsGroupedByUser();

      return {
        'total_memberships': memberships.length,
        'total_organizations_with_members': orgGroups.length,
        'total_users_with_memberships': userGroups.length,
        'memberships_by_role': roleGroups.map(
          (role, memberships) => MapEntry(role, memberships.length),
        ),
        'average_members_per_organization':
            orgGroups.isEmpty ? 0 : memberships.length / orgGroups.length,
        'average_organizations_per_user':
            userGroups.isEmpty ? 0 : memberships.length / userGroups.length,
      };
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException(
        'Error getting membership statistics: $e',
      );
    }
  }

  /// Create multiple memberships at once (batch operation)
  Future<List<Membership>> createMultipleMemberships(
    List<CreateMembershipRequest> requests,
  ) async {
    final results = <Membership>[];

    for (final request in requests) {
      try {
        final membership = await createMembership(
          userId: request.userId,
          orgId: request.orgId,
          role: request.role,
        );
        results.add(membership);
      } catch (e) {
        // Continue with other memberships even if one fails
        print('Failed to create membership for user ${request.userId}: $e');
      }
    }

    return results;
  }

  /// Add multiple users to organization with same role
  Future<List<Membership>> addMultipleUsersToOrganization({
    required List<String> userIds,
    required String orgId,
    required String role,
  }) async {
    final requests =
        userIds
            .map(
              (userId) => CreateMembershipRequest(
                userId: userId,
                orgId: orgId,
                role: role,
              ),
            )
            .toList();

    return await createMultipleMemberships(requests);
  }

  /// Check if user has specific role in organization
  Future<bool> userHasRoleInOrganization(
    String userId,
    String orgId,
    String role,
  ) async {
    try {
      final userRole = await getUserRoleInOrganization(userId, orgId);
      return userRole?.toLowerCase() == role.toLowerCase();
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException('Error checking user role: $e');
    }
  }

  /// Check if user is admin of organization
  Future<bool> isUserAdminOfOrganization(String userId, String orgId) async {
    return await userHasRoleInOrganization(
      userId,
      orgId,
      MembershipRoles.admin,
    );
  }

  /// Check if user is owner of organization
  Future<bool> isUserOwnerOfOrganization(String userId, String orgId) async {
    return await userHasRoleInOrganization(
      userId,
      orgId,
      MembershipRoles.owner,
    );
  }

  /// Get recent memberships (sorted by creation date)
  Future<List<Membership>> getRecentMemberships({int limit = 10}) async {
    try {
      final memberships = await getMemberships();
      memberships.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return memberships.take(limit).toList();
    } catch (e) {
      if (e is AdminMembershipsServiceException) rethrow;
      throw AdminMembershipsServiceException(
        'Error getting recent memberships: $e',
      );
    }
  }
}

// Factory method to create service from auth service
class ClaudeAdminMembershipsServiceFactory {
  static ClaudeAdminMembershipsService fromAuthService(
    String domain,
    String? authToken,
  ) {
    return ClaudeAdminMembershipsService(domain: domain, authToken: authToken);
  }
}

// Example usage:
/*
void main() async {
  // Create service with auth token
  final adminMembershipsService = ClaudeAdminMembershipsService(
    domain: 'https://latente-cms-415c09785677.herokuapp.com',
    authToken: 'your_bearer_token_here',
  );

  try {
    // Create a new membership - Add user to organization
    print('--- Creating Membership ---');
    const userId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
    const orgId = '3fa85f64-5717-4562-b3fc-2c963f66afa7';
    
    final newMembership = await adminMembershipsService.addUserToOrganization(
      userId: userId,
      orgId: orgId,
      role: MembershipRoles.member,
    );
    print('Created membership: ${newMembership.id}');
    print('User: ${newMembership.userId}');
    print('Organization: ${newMembership.orgId}');
    print('Role: ${newMembership.role}');
    print('Created at: ${newMembership.createdAt}');

    // Add admin to organization
    print('\n--- Adding Admin to Organization ---');
    final adminMembership = await adminMembershipsService.addUserToOrganization(
      userId: 'admin-user-id',
      orgId: orgId,
      role: MembershipRoles.admin,
    );
    print('Added admin: ${adminMembership.role}');

    // Add multiple users to organization
    print('\n--- Adding Multiple Users ---');
    final multipleUsers = ['user1-id', 'user2-id', 'user3-id'];
    final multipleMemberships = await adminMembershipsService.addMultipleUsersToOrganization(
      userIds: multipleUsers,
      orgId: orgId,
      role: MembershipRoles.member,
    );
    print('Added ${multipleMemberships.length} members to organization');

    // The following methods would work once GET endpoints are available:

    // Get organization memberships
    print('\n--- Getting Organization Memberships ---');
    try {
      final orgMemberships = await adminMembershipsService.getOrganizationMemberships(orgId);
      print('Found ${orgMemberships.length} members in organization:');
      for (final membership in orgMemberships) {
        print('- User: ${membership.userId}, Role: ${membership.role}');
      }
    } catch (e) {
      print('GET endpoint not available yet: $e');
    }

    // Get user memberships
    print('\n--- Getting User Memberships ---');
    try {
      final userMemberships = await adminMembershipsService.getUserMemberships(userId);
      print('User belongs to ${userMemberships.length} organizations:');
      for (final membership in userMemberships) {
        print('- Org: ${membership.orgId}, Role: ${membership.role}');
      }
    } catch (e) {
      print('GET endpoint not available yet: $e');
    }

    // Check user role in organization
    print('\n--- Checking User Role ---');
    try {
      final userRole = await adminMembershipsService.getUserRoleInOrganization(userId, orgId);
      print('User role in organization: ${userRole ?? 'Not a member'}');

      final isAdmin = await adminMembershipsService.isUserAdminOfOrganization(userId, orgId);
      print('Is user admin? $isAdmin');

      final isMember = await adminMembershipsService.isUserMemberOfOrganization(userId, orgId);
      print('Is user member? $isMember');
    } catch (e) {
      print('GET endpoint not available yet: $e');
    }

    // Get membership statistics
    print('\n--- Membership Statistics ---');
    try {
      final stats = await adminMembershipsService.getMembershipStatistics();
      print('Total memberships: ${stats['total_memberships']}');
      print('Organizations with members: ${stats['total_organizations_with_members']}');
      print('Users with memberships: ${stats['total_users_with_memberships']}');
      print('Memberships by role: ${stats['memberships_by_role']}');
    } catch (e) {
      print('GET endpoint not available yet: $e');
    }

  } on UnauthorizedException catch (e) {
    print('Authentication failed: ${e.message}');
    print('Make sure you have a valid auth token and superadmin privileges');
  } on ValidationException catch (e) {
    print('Validation error: ${e.validationError.detail}');
  } on ConflictException catch (e) {
    print('Conflict error: ${e.message}');
    print('This usually means the user is already a member of the organization');
  } on NotFoundException catch (e) {
    print('Not found: ${e.message}');
    print('User or organization not found');
  } on BadRequestException catch (e) {
    print('Bad request: ${e.apiError.detail}');
  } on ForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
    print('Make sure you have superadmin privileges');
  } on AdminMembershipsServiceException catch (e) {
    print('Admin memberships service error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

// Integration example with auth, users, and organizations services:
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

    final token = authResult.token.accessToken;

    // Create services
    final usersService = ClaudeAdminUsersServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      token,
    );
    final orgsService = ClaudeAdminOrgsServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      token,
    );
    final membershipsService = ClaudeAdminMembershipsServiceFactory.fromAuthService(
      'https://latente-cms-415c09785677.herokuapp.com',
      token,
    );

    // Get users and organizations
    final users = await usersService.getUsers();
    final orgs = await orgsService.getOrganizations();

    if (users.isEmpty || orgs.isEmpty) {
      print('Need at least one user and one organization');
      return;
    }

    final firstUser = users.first;
    final firstOrg = orgs.first;

    print('Adding user ${firstUser.email} to organization ${firstOrg.name}');

    // Add user to organization
    final membership = await membershipsService.addUserToOrganization(
      userId: firstUser.id,
      orgId: firstOrg.id,
      role: MembershipRoles.member,
    );

    print('Successfully created membership: ${membership.id}');
    print('User: ${firstUser.email}');
    print('Organization: ${firstOrg.name}');
    print('Role: ${membership.role}');

  } catch (e) {
    print('Error: $e');
  }
}
*/
*/
