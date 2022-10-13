import 'package:animation_model/animation_model.dart';

void main() {
  final model = AnimationModel();

  model.setPropertyJson('a', {0.5: 10, 1: 0});
  model.setPropertyJson('b', {0: 10, 1: 0});
  model.setPropertyJson('c', {0: 10, 1: 5});

  for (double i = 0; i < 1; i += 0.1) {
    print('$i: ${model.calculate(i)}');
  }
}
