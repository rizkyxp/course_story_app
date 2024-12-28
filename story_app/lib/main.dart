import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/data/api/story_api.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/provider/story_provider.dart';
import 'package:story_app/ui/detail_story_screen.dart';
import 'package:story_app/ui/login_screen.dart';
import 'package:story_app/ui/new_story_screen.dart';
import 'package:story_app/ui/picker_screen.dart';
import 'package:story_app/ui/register_screen.dart';
import 'package:story_app/ui/story_screen.dart';
import 'package:story_app/ui/welcome_screen.dart';
import 'package:story_app/util/colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RegisterProvider(
            storyApi: StoryApi(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginProvider(
            storyApi: StoryApi(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ListStoryProvider(
            storyApi: StoryApi(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DetailStoryProvider(
            storyApi: StoryApi(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NewStoryProvider(
            storyApi: StoryApi(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _router = GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) async {
      final loggedIn = await isLoggedIn();

      if (state.fullPath == '/welcome') {
        if (loggedIn) {
          return '/story';
        } else {
          return null;
        }
      } else {
        return null;
      }
    },
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/story',
        name: 'story',
        builder: (context, state) => const StoryScreen(),
        routes: [
          GoRoute(
            path: 'newStory',
            name: 'newStory',
            builder: (context, state) {
              return NewStoryScreen();
            },
            routes: [
              GoRoute(
                path: 'pickerScreen',
                name: 'pickerScreen',
                builder: (context, state) => const PickerScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'detailStory/:id',
            name: 'detailStory',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DetailStoryScreen(id: id);
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return token != null && token.isNotEmpty;
}
