import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crud/data/dummy_users.dart';
import 'package:flutter_crud/models/user.dart';
import 'package:http/http.dart' as http;

class UsersProvider with ChangeNotifier {
  static const _baseUrl = 'https://crud-firebases-default-rtdb.firebaseio.com/';

  final Map<String, User> _items = {...DUMMY_USERS};

  List<User> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  Future<void> put(User user) async {
    if (user == null) {
      return;
    }

    if (user.id != null && _items.containsKey(user.id)) {
      await http.patch(
        Uri.parse("$_baseUrl/users/${user.id}.json"),
        body: json.encode(
          {
            'name': user.name,
            'email': user.email,
            'avatarUrl': user.avatarUrl,
          },
        ),
      );

      _items.update(
        user.id!,
        (_) => User(
          id: user.id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    } else {
      final response = await http.post(
        Uri.parse("$_baseUrl/users.json"),
        body: json.encode(
          {
            'name': user.name,
            'email': user.email,
            'avatarUrl': user.avatarUrl,
          },
        ),
      );

      final id = json.decode(response.body)['name'];

      _items.putIfAbsent(
        id,
        () => User(
          id: id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    }

    //Alterar

    notifyListeners();
  }

  Future<void> remove(User user) async {
    if (user != null && user.id != null) {
      await http.delete(
        Uri.parse("$_baseUrl/users/${user.id}.json"),
        body: json.encode(
          {
            'name': user.name,
            'email': user.email,
            'avatarUrl': user.avatarUrl,
          },
        ),
      );

      _items.remove(user.id);
      notifyListeners();
    }
  }
}
