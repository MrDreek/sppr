import 'dart:convert';
import 'dart:io';

import 'package:sppr/models/bo.dart';
import 'package:sppr/models/system.dart';

Future<System> createSystem() async {
  Map data = jsonDecode(await File('assets/data.json').readAsString());
  var bos = <BO>[];

  data['bos'].forEach((key, value) => bos.add(BO.fromJson(value)));

  var names = List<String>.from(data['names']).asMap();

  return System(bos, names);
}
