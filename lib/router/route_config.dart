import 'package:firebase_chat_app/pages/auth/login.dart';
import 'package:firebase_chat_app/pages/notification/notificaiton_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/chat/chat_home.dart';
import '../pages/chat/one_on_one_chat.dart';

final GoRouter goRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return
            //  const NotificationPage();
            const LoginPage();
      },
      routes: const <RouteBase>[],
    ),
    GoRoute(
      path: LoginPage.routename,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
      routes: const <RouteBase>[],
    ),
    GoRoute(
      path: ChatHome.routename,
      builder: (BuildContext context, GoRouterState state) {
        return const ChatHome();
      },
      routes: const <RouteBase>[],
    ),
    GoRoute(
      path: OneOnOneChat.routename,
      name: 'oneOnone',
      builder: (BuildContext context, GoRouterState state) {
        return OneOnOneChat(
          username: state.queryParams['username'],
          chatDoc: state.queryParams['chatDoc'],
          email: state.queryParams['email'],
          pushToken: state.queryParams['pushToken'],
          profilePic: state.queryParams['profilePic'],
        );
      },
    ),
  ],
);
