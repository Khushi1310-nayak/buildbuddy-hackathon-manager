import 'package:flutter/foundation.dart';
import 'package:buildbuddy/openai/openai_config.dart';

/// Simple orchestrator around OpenAIClient for different BuildBuddy prompts.
class AiService {
  AiService({OpenAIClient? client}) : _client = client ?? OpenAIClient();
  final OpenAIClient _client;

  Future<String> generateIdeas({required String domain, required String level, required String theme}) async {
    try {
      return await _client.chat(messages: Prompts.ideaGenerator(domain: domain, level: level, theme: theme));
    } catch (e) {
      debugPrint('AI generateIdeas error: $e');
      rethrow;
    }
  }

  Future<String> generateIdeaExample({required String domain, required String level, required String theme}) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      return await _client.chat(
        messages: Prompts.ideaGeneratorExample(domain: domain, level: level, theme: theme, salt: salt),
        model: 'gpt-4o-mini',
      );
    } catch (e) {
      debugPrint('AI generateIdeaExample error: $e');
      rethrow;
    }
  }

  Future<String> teamMatchExample({required List<String> roles, required List<String> skills}) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      return await _client.chat(messages: Prompts.teamMatchingExample(roles: roles, skills: skills, salt: salt), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI teamMatchExample error: $e');
      rethrow;
    }
  }

  Future<String> planExample({required String ideaSummary}) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      return await _client.chat(messages: Prompts.plannerExample(ideaSummary: ideaSummary, salt: salt), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI planExample error: $e');
      rethrow;
    }
  }

  Future<String> recommendTechExample({required String platform, required String constraints}) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      return await _client.chat(messages: Prompts.techStackExample(platform: platform, constraints: constraints, salt: salt), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI recommendTechExample error: $e');
      rethrow;
    }
  }

  Future<String> designAssistExample({required String vibe, required String audience}) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      return await _client.chat(messages: Prompts.designAssistantExample(vibe: vibe, audience: audience, salt: salt), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI designAssistExample error: $e');
      rethrow;
    }
  }

  Future<String> pitchExample({required String ideaSummary}) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      return await _client.chat(messages: Prompts.pitchDeckExample(ideaSummary: ideaSummary, salt: salt), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI pitchExample error: $e');
      rethrow;
    }
  }

  Future<String> readinessExample({required String plan, required String team}) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      return await _client.chat(messages: Prompts.readinessExample(plan: plan, team: team, salt: salt), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI readinessExample error: $e');
      rethrow;
    }
  }
  Future<String> teamMatch({required List<String> roles, required List<String> skills}) async {
    try {
      return await _client.chat(messages: Prompts.teamMatching(roles: roles, skills: skills), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI teamMatch error: $e');
      rethrow;
    }
  }

  Future<String> plan({required String ideaSummary}) async {
    try {
      // Use a chat-compatible model to avoid empty responses on some endpoints.
      return await _client.chat(messages: Prompts.planner(ideaSummary: ideaSummary), model: 'gpt-4o');
    } catch (e) {
      debugPrint('AI plan error: $e');
      rethrow;
    }
  }

  Future<String> recommendTech({required String platform, required String constraints}) async {
    try {
      return await _client.chat(messages: Prompts.techStack(platform: platform, constraints: constraints), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI recommendTech error: $e');
      rethrow;
    }
  }

  Future<String> designAssist({required String vibe, required String audience}) async {
    try {
      return await _client.chat(messages: Prompts.designAssistant(vibe: vibe, audience: audience), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI designAssist error: $e');
      rethrow;
    }
  }

  Future<String> mentorChat({
    required List<Map<String, String>> history,
    String? imageBase64,
    String imageMime = 'image/jpeg',
  }) async {
    try {
      return await _client.chat(
        messages: Prompts.mentorChat(messages: history, lastUserImageBase64: imageBase64, lastUserImageMime: imageMime),
        model: 'gpt-4o',
      );
    } catch (e) {
      debugPrint('AI mentorChat error: $e');
      rethrow;
    }
  }

  Future<String> pitch({required String ideaSummary}) async {
    try {
      return await _client.chat(messages: Prompts.pitchDeck(ideaSummary: ideaSummary));
    } catch (e) {
      debugPrint('AI pitch error: $e');
      rethrow;
    }
  }

  Future<String> readiness({required String plan, required String team}) async {
    try {
      return await _client.chat(messages: Prompts.readiness(plan: plan, team: team), model: 'gpt-4o-mini');
    } catch (e) {
      debugPrint('AI readiness error: $e');
      rethrow;
    }
  }
}
