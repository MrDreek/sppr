class BO {
  final String name;
  final List<List<int>> values;
  final double weight;

  BO(this.name, this.values, this.weight);

  BO.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      values = convertValues(json['values']),
      weight = double.parse(json['weight']);


  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'values': values.map((x) => x.join(', ')).join('\n'),
      };

  static List<List<int>> convertValues(List<dynamic> json) {
    var values = <List<int>>[];

    json.forEach((element) {
      values.add(List.from(element));
    });

    return values;
  }
}