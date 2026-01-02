import 'package:buildbuddy/pages/home_page.dart';
import 'package:buildbuddy/pages/idea_generator_page.dart';
import 'package:buildbuddy/pages/team_builder_page.dart';
import 'package:buildbuddy/pages/planner_page.dart';
import 'package:buildbuddy/pages/tech_stack_page.dart';
import 'package:buildbuddy/pages/design_assistant_page.dart';
import 'package:buildbuddy/pages/mentor_chat_page.dart';
import 'package:buildbuddy/pages/pitch_deck_page.dart';
import 'package:buildbuddy/pages/readiness_score_page.dart';
import 'package:buildbuddy/pages/portfolio_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GoRouter configuration for app navigation
///
/// This uses go_router for declarative routing, which provides:
/// - Type-safe navigation
/// - Deep linking support (web URLs, app links)
/// - Easy route parameters
/// - Navigation guards and redirects
///
/// To add a new route:
/// 1. Add a route constant to AppRoutes below
/// 2. Add a GoRoute to the routes list
/// 3. Navigate using context.go() or context.push()
/// 4. Use context.pop() to go back.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const HomePage(),
        ),
      ),
        GoRoute(
          path: AppRoutes.ideaGenerator,
          name: 'ideaGenerator',
          builder: (context, state) => const IdeaGeneratorPage(),
        ),
        GoRoute(
          path: AppRoutes.teamBuilder,
          name: 'teamBuilder',
          builder: (context, state) => const TeamBuilderPage(),
        ),
        GoRoute(
          path: AppRoutes.planner,
          name: 'planner',
          builder: (context, state) => const PlannerPage(),
        ),
        GoRoute(
          path: AppRoutes.techStack,
          name: 'techStack',
          builder: (context, state) => const TechStackPage(),
        ),
        GoRoute(
          path: AppRoutes.designAssistant,
          name: 'designAssistant',
          builder: (context, state) => const DesignAssistantPage(),
        ),
        GoRoute(
          path: AppRoutes.mentorChat,
          name: 'mentorChat',
          builder: (context, state) => const MentorChatPage(),
        ),
        GoRoute(
          path: AppRoutes.pitchDeck,
          name: 'pitchDeck',
          builder: (context, state) => const PitchDeckPage(),
        ),
        GoRoute(
          path: AppRoutes.readiness,
          name: 'readiness',
          builder: (context, state) => const ReadinessScorePage(),
        ),
        GoRoute(
          path: AppRoutes.portfolio,
          name: 'portfolio',
          builder: (context, state) => const PortfolioPage(),
        ),
    ],
  );
}

/// Route path constants
/// Use these instead of hard-coding route strings
class AppRoutes {
  static const String home = '/';
    static const String ideaGenerator = '/idea';
    static const String teamBuilder = '/team';
    static const String planner = '/planner';
    static const String techStack = '/tech';
    static const String designAssistant = '/design';
    static const String mentorChat = '/chat';
    static const String pitchDeck = '/pitch';
    static const String readiness = '/readiness';
    static const String portfolio = '/portfolio';
}
