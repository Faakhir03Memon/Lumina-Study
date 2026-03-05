import 'package:go_router/go_router.dart';
import 'package:lumina_study/features/onboarding/splash_screen.dart';
import 'package:lumina_study/features/auth/login_screen.dart';
import 'package:lumina_study/features/auth/signup_screen.dart';
import 'package:lumina_study/features/onboarding/onboarding_screen.dart';
import 'package:lumina_study/features/shell/app_shell.dart';
import 'package:lumina_study/features/chat/chat_screen.dart';
import 'package:lumina_study/features/pdf_analyzer/pdf_analyzer_screen.dart';
import 'package:lumina_study/features/quiz/quiz_screen.dart';
import 'package:lumina_study/features/image_gen/image_gen_screen.dart';
import 'package:lumina_study/features/coding/coding_screen.dart';
import 'package:lumina_study/features/dashboard/dashboard_screen.dart';
import 'package:lumina_study/features/dashboard/settings_screen.dart';
import 'package:lumina_study/features/assignment/assignment_screen.dart';
import 'package:lumina_study/features/admin/admin_dashboard.dart';
import 'package:lumina_study/features/admin/user_management_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup' || state.matchedLocation == '/splash';

    if (user == null && !isLoggingIn) return '/login';
    if (user != null && state.matchedLocation == '/login') return '/dashboard';
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pdf',
              name: 'pdf',
              builder: (context, state) => const PdfAnalyzerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quiz',
              name: 'quiz',
              builder: (context, state) => const QuizScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/image',
              name: 'image',
              builder: (context, state) => const ImageGenScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/assignment',
      name: 'assignment',
      builder: (context, state) => const AssignmentScreen(),
    ),
    GoRoute(
      path: '/coding',
      name: 'coding',
      builder: (context, state) => const CodingScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminDashboard(),
      routes: [
        GoRoute(
          path: 'users',
          name: 'admin_users',
          builder: (context, state) => const UserManagementScreen(),
        ),
      ],
    ),
  ],
);
