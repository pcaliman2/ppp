import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/models/popup_submission.dart';
import 'package:owa_flutter/models/popup_submission_result.dart';

// =============================================================================
// EXCEPTIONS
// =============================================================================

class OWADashboardException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const OWADashboardException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'OWADashboardException($statusCode): $message';
}

class OWAValidationException extends OWADashboardException {
  const OWAValidationException(super.message, {super.details})
    : super(statusCode: 422);
}

class OWADashboardService {
  OWADashboardService({
    String? baseUrl,
    http.Client? client,
    Future<String?> Function()? getAuthToken,
  }) : _baseUrl = (baseUrl ??
               'https://latente-cms-core-f0bb6db1f7ac.herokuapp.com')
           .replaceAll(RegExp(r'/+$'), ''),
       _client = client ?? http.Client(),
       _getAuthToken = getAuthToken;

  final String _baseUrl;
  final http.Client _client;
  final Future<String?> Function()? _getAuthToken;

  void dispose() => _client.close();

  // ---------------------------------------------------------------------------
  // POST /api/v1/owa/popup-submissions
  // ---------------------------------------------------------------------------

  /// Submits the OWA signup popup form.
  ///
  /// [submission] contains email, gender, and birthDate (YYYY-MM-DD).
  /// Returns the created [PopupSubmissionResult] on success.
  Future<PopupSubmissionResult> submitPopup(PopupSubmission submission) async {
    final uri = Uri.parse('$_baseUrl/api/v1/owa/popup-submissions');

    try {
      final headers = await _buildHeaders();
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(submission.toJson()),
      );

      return _handleSubmissionResponse(response);
    } on OWADashboardException {
      rethrow;
    } catch (e) {
      throw OWADashboardException(
        'Network error while submitting popup form: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_getAuthToken != null) {
      final token = await _getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  PopupSubmissionResult _handleSubmissionResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return PopupSubmissionResult.fromJson(json);
        } catch (_) {
          // Some endpoints return 200 with a plain confirmation; handle gracefully.
          throw OWADashboardException(
            'Unexpected response format from popup-submissions.',
            statusCode: response.statusCode,
          );
        }

      case 422:
        Map<String, dynamic>? details;
        try {
          details = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {}
        throw OWAValidationException(
          'Validation error: please check email, gender, and birth date.',
          details: details,
        );

      case 401:
      case 403:
        throw OWADashboardException(
          'Unauthorized. Check your credentials.',
          statusCode: response.statusCode,
        );

      case 404:
        throw OWADashboardException(
          'Endpoint not found (404). Check the base URL.',
          statusCode: 404,
        );

      case 409:
        throw OWADashboardException(
          'This email has already been submitted.',
          statusCode: 409,
        );

      default:
        throw OWADashboardException(
          'Unexpected error (${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
    }
  }
}
