import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// OpenAI configuration
// Values are provided at runtime via environment variables.
const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');

/// Minimal client for OpenAI Chat Completions and Responses APIs.
/// All OpenAI networking code must live in this file as per project spec.
class OpenAIClient {
  OpenAIClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  bool get isConfigured => apiKey.isNotEmpty && endpoint.isNotEmpty;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  /// Calls the Chat Completions API with simple text messages.
  /// model: gpt-4o (default) or others.
  Future<String> chat({
    required List<Map<String, dynamic>> messages,
    String model = 'gpt-4o',
    Map<String, dynamic>? responseFormat,
  }) async {
    if (!isConfigured) {
      throw StateError('OpenAI not configured. Set OPENAI_PROXY_API_KEY and OPENAI_PROXY_ENDPOINT.');
    }

    final uri = Uri.parse(endpoint);
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (responseFormat != null) 'response_format': responseFormat,
      'temperature': 0.7,
    };

    try {
      final resp = await _client.post(uri, headers: _headers, body: utf8.encode(jsonEncode(body))).timeout(const Duration(seconds: 40));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        final choices = decoded['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices.first['message']?['content'];
          if (content is String) return content;
          if (content is List) {
            // When using multimodal responses
            final textPart = content.firstWhere(
              (e) => e is Map && (e['type'] == 'text'),
              orElse: () => null,
            );
            if (textPart is Map && textPart['text'] is String) return textPart['text'] as String;
          }
        }
        throw StateError('OpenAI: Empty response');
      } else {
        debugPrint('OpenAI error ${resp.statusCode}: ${resp.body}');
        throw StateError('OpenAI request failed: ${resp.statusCode}');
      }
    } on TimeoutException {
      throw StateError('OpenAI request timed out');
    } catch (e) {
      debugPrint('OpenAI client error: $e');
      rethrow;
    }
  }
}

/// Common prompt builders used across the app.
class Prompts {
  static List<Map<String, dynamic>> ideaGenerator({required String domain, required String level, required String theme}) => [
        {
          'role': 'system',
          'content': 'You are BuildBuddy, an expert hackathon mentor. Provide concise, practical project ideas with clear value and realistic scope.'
        },
        {
          'role': 'user',
          'content': 'Generate 3 hackathon project ideas for domain=$domain, skillLevel=$level, theme=$theme. For each, include: one-liner, core features (3-5), target users, differentiation, stretch goals. Return as markdown.'
        }
      ];

  /// Variant prompt for the "Load Example" action. It should feel fresh and trend-aware.
  /// The salt helps nudge output variance across clicks.
  static List<Map<String, dynamic>> ideaGeneratorExample({
    required String domain,
    required String level,
    required String theme,
    required String salt,
  }) => [
        {
          'role': 'system',
          'content': 'You are BuildBuddy, an expert hackathon mentor. Provide realistic, trend-aware examples aligned to current market conversations. Favor practical scope for a weekend build.'
        },
        {
          'role': 'user',
          'content': 'Salt=$salt. Generate 3 fresh hackathon project ideas for domain=$domain, skillLevel=$level, theme=$theme. Incorporate a specific niche or current trend (e.g., agentic AI, RAG with small datasets, climate tools, campus services, student finance), and avoid repeating common examples. For each, include: one-liner, core features (3-5), target users, differentiation, stretch goals. Return as markdown.'
        }
      ];

  static List<Map<String, dynamic>> teamMatchingExample({
    required List<String> roles,
    required List<String> skills,
    required String salt,
  }) => [
        {
          'role': 'system',
          'content': 'You match roles to skills and suggest missing roles for a balanced hackathon team. Keep it concise and practical.'
        },
        {
          'role': 'user',
          'content': 'Salt=$salt. Given roles=${roles.join(', ')} and skills=${skills.join(', ')}: 1) role→skill mapping, 2) missing roles, 3) top risks, 4) first onboarding tasks. Make it feel fresh and trend-aware. Return as brief markdown.'
        }
      ];

  static List<Map<String, dynamic>> plannerExample({
    required String ideaSummary,
    required String salt,
  }) => [
        {
          'role': 'system',
          'content': 'Create a pragmatic 24-48h hackathon execution plan with milestones and timeline. Keep scope realistic.'
        },
        {
          'role': 'user',
          'content': 'Salt=$salt. Based on this idea: $ideaSummary\nOutput a sample: 1) MVP features with priorities, 2) 24-48h milestones, 3) timeline with owners, 4) demo checklist. Add small twists to feel fresh. Return markdown.'
        }
      ];

  static List<Map<String, dynamic>> techStackExample({
    required String platform,
    required String constraints,
    required String salt,
  }) => [
        {
          'role': 'system',
          'content': 'Recommend minimal, proven stacks for fast hackathon delivery with brief rationale.'
        },
        {
          'role': 'user',
          'content': 'Salt=$salt. Target platform: $platform. Constraints: $constraints. Recommend frontend, backend, database, auth, hosting/CDN, and reasons in a compact markdown table. Prefer simple, reliable picks.'
        }
      ];

  static List<Map<String, dynamic>> designAssistantExample({
    required String vibe,
    required String audience,
    required String salt,
  }) => [
        {
          'role': 'system',
          'content': 'Suggest accessible palettes (hex), Google Font pairings, and layout patterns for modern, student-friendly apps.'
        },
        {
          'role': 'user',
          'content': 'Salt=$salt. Vibe: $vibe, Audience: $audience. Provide: 2 palettes (primary, secondary, surface, accent), 2 font pairings, and layout tips with subtle, fresh twists. Return markdown.'
        }
      ];

  static List<Map<String, dynamic>> pitchDeckExample({
    required String ideaSummary,
    required String salt,
  }) => [
        {
          'role': 'system',
          'content': 'Draft succinct pitch outline and demo flow for hackathons. Aim for clarity and momentum.'
        },
        {
          'role': 'user',
          'content': 'Salt=$salt. Create 8-slide outline (problem, solution, demo, differentiation, market, tech, roadmap, ask) and a 3-min demo script for: $ideaSummary. Make it feel timely. Return markdown.'
        }
      ];

  static List<Map<String, dynamic>> readinessExample({
    required String plan,
    required String team,
    required String salt,
  }) => [
        {
          'role': 'system',
          'content': 'Score hackathon readiness 0-100, explain gaps, and give 5 concrete actions.'
        },
        {
          'role': 'user',
          'content': 'Salt=$salt. Plan: $plan\nTeam: $team. Provide an example readiness score, 3-5 gaps, and 5 prioritized actions. Keep it crisp and realistic. Return markdown.'
        }
      ];
  static List<Map<String, dynamic>> teamMatching({required List<String> roles, required List<String> skills}) => [
        {
          'role': 'system',
          'content': 'You match roles to skills and suggest missing roles for a balanced hackathon team.'
        },
        {
          'role': 'user',
          'content': 'Given roles=${roles.join(', ')} and skills=${skills.join(', ')}: 1) mapping, 2) missing roles, 3) risk areas, 4) onboarding tasks. Keep it brief.'
        }
      ];

  static List<Map<String, dynamic>> planner({required String ideaSummary}) => [
        {
          'role': 'system',
          'content': 'Create a pragmatic 24-48h hackathon execution plan with milestones and timeline.'
        },
        {
          'role': 'user',
          'content': 'Based on this idea: $ideaSummary\nOutput: 1) feature list with priorities, 2) milestones across 24-48h, 3) timeline with owners, 4) demo checklist.'
        }
      ];

  static List<Map<String, dynamic>> techStack({required String platform, required String constraints}) => [
        {
          'role': 'system',
          'content': 'Recommend a minimal, proven tech stack for fast hackathon delivery.'
        },
        {
          'role': 'user',
          'content': 'Target platform: $platform. Constraints: $constraints. Recommend frontend, backend, database, auth, hosting, and reasons in a table-like markdown.'
        }
      ];

  static List<Map<String, dynamic>> designAssistant({required String vibe, required String audience}) => [
        {
          'role': 'system',
          'content': 'Suggest accessible color palettes (hex), Google Fonts, and layout patterns for modern student-friendly apps.'
        },
        {
          'role': 'user',
          'content': 'Vibe: $vibe, Audience: $audience. Provide: 2 palettes (primary, secondary, surface, accent), 2 font pairings, layout tips.'
        }
      ];

  static List<Map<String, dynamic>> mentorChat({
    required List<Map<String, String>> messages,
    String? lastUserImageBase64,
    String lastUserImageMime = 'image/jpeg',
  }) {
    final chatMessages = <Map<String, dynamic>>[
      {'role': 'system', 'content': 'You are BuildBuddy, a friendly, concise hackathon mentor for coding, design, and pitching. If the user provides an image, analyze it carefully and tailor your advice to what is visible.'}
    ];

    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      final isLast = i == messages.length - 1;
      final role = m['role'];
      final content = m['content'] ?? '';
      if (isLast && role == 'user' && lastUserImageBase64 != null && lastUserImageBase64.isNotEmpty) {
        chatMessages.add({
          'role': 'user',
          'content': [
            {'type': 'text', 'text': content.isEmpty ? 'Consider the attached image.' : content},
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$lastUserImageMime;base64,$lastUserImageBase64'
              }
            }
          ],
        });
      } else {
        chatMessages.add({'role': role, 'content': content});
      }
    }
    return chatMessages;
  }

  static List<Map<String, dynamic>> pitchDeck({required String ideaSummary}) => [
        {
          'role': 'system',
          'content': 'Draft succinct pitch outline and demo flow for hackathons.'
        },
        {
          'role': 'user',
          'content': 'Create 8-slide outline (problem, solution, demo, differentiation, market, tech, roadmap, ask) and a 3-min demo script for: $ideaSummary.'
        }
      ];

  static List<Map<String, dynamic>> readiness({required String plan, required String team}) => [
        {
          'role': 'system',
          'content': 'Score hackathon readiness 0-100, explain gaps, and give 5 concrete actions.'
        },
        {
          'role': 'user',
          'content': 'Plan: $plan\nTeam: $team. Score and suggestions please.'
        }
      ];
}
