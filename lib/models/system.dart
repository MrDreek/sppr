import 'dart:collection';
import 'dart:math';

import 'package:sppr/models/bo.dart';
import 'package:sppr/models/tournament_item.dart';
import 'package:sppr/utils.dart';
import 'package:tuple/tuple.dart';

class System {
  static const int delimiterSize = 40;
  static const int formatStringLength = 30;

  final List<BO> bos;
  final Map<int, String> names;

  System(this.bos, this.names);

  List<String> get boNames => bos.map((element) => element.name).toList();

  int get size => bos.length;

  void dominanceMechanism() {
    print('-' * delimiterSize);
    print('Механизм доминирования:');
    var counts = <List<int>>[];

    for (var bo in bos) {
      var indexes = <int>[];

      bo.values.asMap().forEach((key, value) {
        if (value.fold(0, (p, c) => p + c) == value.length) {
          indexes.add(key);
        }
      });

      print(formatString(bo.name) + ': ' + namesByIndex(indexes).join(', '));
      counts.add(indexes);
    }

    positionCount('\nКоличество доминирующих позиций:', counts);

    print('-' * delimiterSize);
  }

  void lockingMechanism() {
    print('-' * delimiterSize);
    print('Механизм блокировки:');
    var counts = <List<int>>[];

    for (var bo in bos) {
      var indexes = <int>[];

      for (var i = 0; i < bo.values.length; i++) {
        var col = bo.values.map<int>((row) => row[i]).toList(growable: false);
        if (col.fold(0, (p, c) => p + c) == 1) {
          indexes.add(i);
        }
      }

      print(formatString(bo.name) + ': ' + namesByIndex(indexes).join(', '));
      counts.add(indexes);
    }

    positionCount('\nКоличество блокирующих позиций:', counts);

    print('-' * delimiterSize);
  }

  void tournamentMechanism() {
    print('-' * delimiterSize);
    print('Турнирный механизм:');

    var tournamentResult = <Tuple2<String, List<TournamentItem>>>[];

    for (var bo in bos) {
      var indexes = <TournamentItem>[];
      for (var i = 0; i < size; i++) {
        var currentSum = 0.0;
        for (var j = 0; j < size; j++) {
          if (i == j) {
            continue;
          }
          if (bo.values[i][j] == 1 && bo.values[j][i] == 0) {
            currentSum += 1;
          } else if (bo.values[j][i] == 1 && bo.values[i][j] == 0) {
            currentSum += 0;
          } else {
            currentSum += 0.5;
          }
        }
        indexes.add(TournamentItem(names[i], currentSum, bo.weight));
      }

      tournamentResult
          .add(Tuple2<String, List<TournamentItem>>(bo.name, indexes));

      print(formatString(bo.name) +
          ': ' +
          indexes
              .map((e) => (e.name + '(' + e.sum.toStringAsPrecision(2) + ')'))
              .join(', '));
    }

    var sums = <String, double>{};

    print('\nУмножение на весовые коэффициенты');
    for (var bo in tournamentResult) {
      bo.item2.forEach((element) {
        element.sum *= element.weight;
        sums.update(element.name, (value) => value + element.sum,
            ifAbsent: () => element.sum);
      });
      print(formatString(bo.item1) +
          ': ' +
          bo.item2
              .map((e) => (e.name + '(' + e.sum.toStringAsPrecision(2) + ')'))
              .join(', '));
    }

    print('\nСумма сумм для каждого варианта-решения.');
    sums.forEach(
        (key, value) => print(key + ': ' + value.toStringAsPrecision(2)));

    var sortedKeys = sums.keys.toList(growable: false)
      ..sort((k2, k1) => sums[k1].compareTo(sums[k2]));
    var sortedMap = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => sums[k]);

    print('\nРезультаты в отсортированном виде в порядке убывания');
    sortedMap.forEach(
        (key, value) => print(key + ': ' + value.toStringAsPrecision(2)));
    print('-' * delimiterSize);
  }

  void kMax() {
    print('-' * delimiterSize);
    print('Определение K-максимальных альтернатив:');

    var kIndexes = <int, List<int>>{};

    for (var bo in bos) {
      var k = <List<int>>[];
      var k_1 = <int>[];
      var k_2 = <int>[];
      var k_3 = <int>[];
      var k_4 = <int>[];

      for (var i = 0; i < size; i++) {
        var hor_num = 0;
        var nr_num = 0;
        var er_num = 0;
        for (var j = 0; j < size; j++) {
          if (i == j) {
            continue;
          }
          if (bo.values[i][j] == 1 && bo.values[j][i] == 0) {
            hor_num += 1;
          }
          if (bo.values[j][i] == 1 && bo.values[i][j] == 0) {
            nr_num += 1;
          }
          if (bo.values[i][j] == 1 && bo.values[j][i] == 1) {
            er_num += 1;
          }
        }
        k_1.add(hor_num + nr_num + er_num);
        k_2.add(hor_num + nr_num);
        k_3.add(hor_num + er_num);
        k_4.add(hor_num);
      }
      k.addAll([k_1, k_2, k_3, k_4]);

      print(bo.name + ':');
      print(formatString('kn', maxLength: 5) +
          names.values.map((i) => formatString(i, maxLength: 15)).join(''));

      var optimums = <Tuple3<String, Set, String>>[];
      for (var i = 0; i < 4; i++) {
        var result = ksValues(k[i], 'k${i} ');
        var optimum = 'Не оптимум';

        if (i == 0) {
          if (result.item1 == names.length - 1) {
            optimum = 'Максимальный';
          }
        } else if (i == 1) {
          if (result.item1 == names.length - 1) {
            optimum = 'Строго максимальный';
          }
        } else if (i == 2) {
          if (result.item1 == names.length - 1) {
            optimum = 'Наибольший';
          }
        } else if (i == 3) {
          if (result.item1 == names.length - 1) {
            optimum = 'Строго наибольший';
          }
        }
        optimums.add(Tuple3('k${i}', Set<int>.from(result.item2), optimum));

        if (kIndexes.containsKey(i)) {
          result.item2.asMap().forEach((key, value) {
            try {
              kIndexes[i][key] += 1;
            } catch (e) {
              kIndexes[i].insert(key, 1);
            }
          });
        } else {
          kIndexes[i] = result.item2.map((e) => 1).toList();
        }
      }
      print('');
      print(formatString('kn', maxLength: 5) +
          formatString('Вид оптимума', maxLength: 20) +
          'Наименование');

      for (var opt in optimums) {
        print(formatString(opt.item1, maxLength: 5) +
            formatString(opt.item3, maxLength: 20) +
            namesByIndex(opt.item2.toList()).join(', '));
      }
      print('');
    }

    names.forEach((key, name) {
      kIndexes.forEach((k, i) {
        var count = '0';
        try {
          count = i[key].toString();
        } catch (e) {
          count = '0';
        }
        print('k${k}: ' + name + ': ' + count);
      });
    });

    print('-' * delimiterSize);
  }

  Tuple2<int, List<int>> ksValues(List<int> k, String msg) {
    var maxVal = k.reduce(max);
    var keys = <int>[];
    k.asMap().forEach((key, value) {
      if (value == maxVal) {
        keys.add(key);
      }
    });
    var namesString =
        k.map((i) => formatString(i.toString(), maxLength: 15)).join('');
    print(formatString(msg, maxLength: 5) + namesString);
    return Tuple2(maxVal, keys);
  }

  void positionCount(String type, List<List<int>> counts) {
    print(formatString(type, maxLength: 31) + formatString(' ', maxLength: 10) + 'Вес');
    names.forEach((key, value) {
      var count = counts.where((element) => element.contains(key)).length;
      var weight = 0.0;
      counts.asMap().forEach((k, v) {
          if (v.contains(key)) {
            weight += bos[k].weight;
          }
      });
      print(formatString(value, maxLength: 31) + ': ' + formatString(count.toString(), maxLength: 5) + ' : ' + formatString(weight.toStringAsPrecision(2), maxLength: 10));
    });
  }

  List<String> namesByIndex(List<int> index) {
    var result = <String>[];

    names.forEach((key, value) {
      if (index.contains(key)) {
        result.add(value);
      }
    });

    return result.isEmpty ? ['Пусто'] : result;
  }
}
