import 'package:sppr/data_loader.dart';

void main(List<String> arguments) async {
  var system = await createSystem();

  print(system.boNames.join('\n'));

  system.dominanceMechanism();
  print('');
  system.lockingMechanism();
  print('');
  system.tournamentMechanism();
  print('');
  system.kMax();
}
