class SampleData {
  static const ideaMarkdown = '''
# AI Tutoring Assistant for STEM Students
- One-liner: A chat-based tutor that explains STEM problems step-by-step.
- Core features: OCR for problems, step explanations, practice sets, progress.
- Users: High school & undergrad students.
- Differentiation: Simple UX, fast answers, study streaks.
- Stretch: Live whiteboard, peer matching.

# Campus Food Saver
- One-liner: App that redirects leftover campus food to students quickly.
- Core features: Real-time listings, pickup QR, volunteer loop, safety notes.
- Users: Student orgs, hungry students.
- Differentiation: Instant alerts, zero-friction pickup.
- Stretch: Partnerships, donation tracking.

# Event Radar for Hackathons
- One-liner: Tracks hackathon tasks, mentors, and workshops live.
- Core features: Schedule sync, mentor availability, task board, team check-ins.
- Users: Hackathon teams.
- Differentiation: Realtime mentor queues + team visibility.
- Stretch: Discord/Slack bots, judging automation.
''';

  static const teamAdvice = '''
Role mapping:
- Frontend: React/Flutter dev with UI skills
- Backend: Node/Express dev with DB
- AI/ML: Model integration and prompt design
- PM/Design: Scoping, UX, and pitch

Missing roles: QA/Tester, DevOps/Deploy
Risks: Over-scoping, no demo flow
Onboarding: Define MVP, create repo, pick stack, draft demo script
''';

  static const planMarkdown = '''
## Features (MVP)
- Auth, Core flow, Demo data, Read-only admin

## Milestones
- 0-6h: Setup repo, choose stack, scaffolding
- 6-18h: Build core features, integrate APIs
- 18-30h: Polish UI, demo data, bugfixing
- 30-36h: Pitch + demo rehearsal, backups

## Demo Checklist
- Live flow scripted, offline fallback, seed data, screen recording
''';

  static const techStack = '''
| Layer | Choice | Why |
| --- | --- | --- |
| Frontend | Flutter Web | fast UI, one codebase |
| Backend | Supabase | auth + DB in minutes |
| DB | Postgres | relational, easy |
| Hosting | Vercel/Netlify | quick deploy |
''';

  static const designTips = '''
Palettes:
- Primary #5B7C99, Secondary #6B7C8C, Surface #FBFCFD, Accent #ACC7E3
- Primary #4F46E5, Secondary #14B8A6, Surface #0B1020, Accent #F59E0B

Fonts:
- Inter + Space Grotesk
- DM Sans + JetBrains Mono

Layout:
- Cards with generous padding, subtle dividers, rounded corners, no heavy shadows
''';

  static const pitch = '''
Slides: Problem, Solution, Demo, Differentiation, Market, Tech, Roadmap, Ask.
Demo: 1) Pain 2) Core flow 3) Key feature 4) Stretch 5) CTA.
''';

  static const readiness = '''
Score: 72/100
Gaps: unclear scope, missing QA, risky integrations
Actions: freeze MVP, seed data, demo script, backups, rehearsal
''';

  /// Lightweight, non-network fallback for Idea Generator examples.
  /// Produces varied markdown using the provided inputs and a time-based salt.
  static String ideaExample({required String domain, required String level, required String theme}) {
    final salt = DateTime.now().millisecondsSinceEpoch % 7;
    final nichesByDomain = <String, List<String>>{
      'AI/ML': ['agentic assistants', 'small-context RAG', 'on-device inference', 'data labeling', 'AI safety tooling', 'edtech tutoring', 'productivity copilots'],
      'Web': ['campus services', 'creator dashboards', 'marketplace micro-SaaS', 'student finance tools', 'event management', 'study groups', 'note sharing'],
      'Mobile': ['habit trackers', 'campus logistics', 'health & wellness', 'lightweight social', 'language learning', 'sports analytics', 'mentorship apps'],
      'Hardware': ['IoT sensors', 'wearables', 'raspberry pi kiosks', 'smart dorms', 'robotics demos', 'environment monitors', 'assistive devices'],
      'Data': ['dashboards', 'ETL helpers', 'data viz', 'CSV to API', 'privacy tooling', 'analytics for clubs', 'scraper pipelines'],
    };
    final niches = nichesByDomain[domain] ?? nichesByDomain['Web']!;
    final niche = niches[salt % niches.length];

    String idea(String title, List<String> features, String users, String diff, String stretch) => '''
# $title
- One-liner: ${title.replaceAll('# ', '')} for $users.
- Core features: ${features.join(', ')}.
- Users: $users.
- Differentiation: $diff.
- Stretch: $stretch.
''';

    final i1 = idea(
      '$domain $niche Assistant',
      ['auth', 'core flow', 'share/export', 'offline fallback'],
      level == 'Beginner' ? 'students and beginners' : 'hackathon teams',
      'fast setup, scoped MVP, clear demo path',
      'integrations and polish',
    );
    final i2 = idea(
      '$theme Tracker ($domain)',
      ['input capture', 'smart defaults', 'progress view', 'reminders'],
      'people interested in $theme',
      'actionable insights, minimal clicks',
      'collaboration and templates',
    );
    final i3 = idea(
      '$domain $niche Toolkit',
      ['starter templates', 'guided wizard', 'demo data', 'export to markdown'],
      'clubs and campus builders',
      'weekend-build friendly, reusable pieces',
      'plugin marketplace',
    );

    return [i1, i2, i3].join('\n');
  }

  /// Varied, non-network fallback for Team Builder suggestions
  static String teamAdviceExample({required List<String> roles, required List<String> skills}) {
    final salt = DateTime.now().millisecondsSinceEpoch % 5;
    final missingPools = [
      ['QA/Tester', 'DevOps/Deploy'],
      ['Data/Analytics', 'PM'],
      ['Security', 'Infra'],
      ['AI/ML', 'Prompt Engineer'],
      ['Mobile Dev', 'Tech Writer'],
    ];
    final risks = [
      'over-scoping features',
      'unclear ownership',
      'too many risky integrations',
      'no demo script',
      'missing seed data',
    ];
    final missing = missingPools[salt % missingPools.length];
    final risk = risks[salt % risks.length];
    final mapping = roles.map((r) => '- $r: ${skills.isNotEmpty ? skills[salt % skills.length] : 'generalist'}').join('\n');
    return '''
Role mapping:\n$mapping\n\nMissing roles: ${missing.join(', ')}\nRisks: $risk\nOnboarding: define MVP, create repo, pick stack, draft demo script
''';
  }

  /// Varied, non-network fallback for Planner
  static String planExample({required String ideaSummary}) {
    final salt = DateTime.now().millisecondsSinceEpoch % 3;
    final tracks = [
      ['Auth', 'Core flow', 'Demo data', 'Export'],
      ['UI polish', 'API integration', 'Offline fallback', 'Recording'],
      ['Onboarding', 'Data model', 'Docs', 'Stretch goal'],
    ][salt];
    return '''
## Idea\n$ideaSummary\n\n## Features (MVP)\n- ${tracks.join('\n- ')}\n\n## Milestones\n- 0-6h: setup + scaffolding\n- 6-18h: core features\n- 18-30h: polish + demo data\n- 30-36h: pitch rehearsal\n\n## Demo Checklist\n- scripted flow, seed data, backups, screen recording
''';
  }

  /// Varied, non-network fallback for Tech Stack
  static String techStackExample({required String platform, required String constraints}) {
    final salt = DateTime.now().millisecondsSinceEpoch % 3;
    final frontend = ['Flutter', 'Next.js', 'SvelteKit'][salt];
    final backend = ['Supabase', 'Firebase', 'Railway + FastAPI'][salt];
    final db = ['Postgres', 'Firestore', 'SQLite'][salt];
    final auth = ['Supabase Auth', 'Firebase Auth', 'Clerk'][salt];
    final hosting = ['Vercel', 'Netlify', 'Render'][salt];
    return '''
| Layer | Choice | Why |
| --- | --- | --- |
| Frontend | $frontend | fast UI, one codebase |
| Backend | $backend | quick setup |
| DB | $db | simple + familiar |
| Auth | $auth | built-in patterns |
| Hosting | $hosting | easy deploy |
\nConstraints: $constraints. Target: $platform.
''';
  }

  /// Varied, non-network fallback for Design Assistant
  static String designTipsExample({required String vibe, required String audience}) {
    final salt = DateTime.now().millisecondsSinceEpoch % 2;
    final palettes = [
      ['#4F46E5', '#14B8A6', '#0B1020', '#F59E0B'],
      ['#2563EB', '#22C55E', '#F8FAFC', '#A78BFA'],
    ];
    final p = palettes[salt];
    final fonts = salt == 0 ? 'Inter + Space Grotesk' : 'DM Sans + JetBrains Mono';
    return '''
Palettes:\n- Primary ${p[0]}, Secondary ${p[1]}, Surface ${p[2]}, Accent ${p[3]}\n\nFonts:\n- $fonts\n\nLayout:\n- cards with generous padding, rounded corners, subtle dividers\n- focus on contrast and large tap targets\n\nContext: $vibe for $audience
''';
  }

  /// Varied, non-network fallback for Pitch
  static String pitchExample({required String ideaSummary}) {
    final salt = DateTime.now().millisecondsSinceEpoch % 2;
    final diff = salt == 0 ? 'weekend-build friendly, clear value' : 'focus on demo-first approach';
    return '''
Slides: Problem, Solution, Demo, Differentiation ($diff), Market, Tech, Roadmap, Ask.\nDemo: 1) Pain 2) Core flow 3) Key feature 4) Stretch 5) CTA.\nIdea: $ideaSummary
''';
  }

  /// Varied, non-network fallback for Readiness score
  static String readinessExample({required String plan, required String team}) {
    final salt = DateTime.now().millisecondsSinceEpoch % 3;
    final score = [68, 74, 81][salt];
    final gap = ['scope creep', 'missing QA', 'unclear owners'][salt];
    return '''
Score: $score/100\nGaps: $gap, risky integrations, no backups\nActions: freeze MVP, seed data, demo script, backups, rehearsal\nContext plan: $plan\nTeam: $team
''';
  }
}
