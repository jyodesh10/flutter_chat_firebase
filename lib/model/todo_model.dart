import 'package:flutter/material.dart';

class TodoModel {
  int id;
  String title;
  String body;
  bool isCompleted;

  TodoModel(
      {required this.id,
      required this.title,
      required this.body,
      required this.isCompleted});
}

List<TodoModel> todoslist = [
  TodoModel(id: 1, title: 'Title1', body: "body", isCompleted: true),
  TodoModel(id: 2, title: 'Title2', body: "body", isCompleted: true),
  TodoModel(id: 3, title: 'Title3', body: "body", isCompleted: false),
  TodoModel(id: 4, title: 'Title4', body: "body", isCompleted: false),
];

class AppTheme {
  ThemeData lightTheme = ThemeData.light();
  ThemeData darkTheme = ThemeData.dark();
  // ThemeData(primaryColor: Colors.black38, backgroundColor: Colors.black38);
}
