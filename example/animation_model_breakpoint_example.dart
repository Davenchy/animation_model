import 'package:animation_model/animation_model.dart';

void main() {
  final point = Breakpoint(0, 10);

  final point2 = Breakpoint(0.2, 7); // create another point
  point.insert(point2); // insert to the linked list

  // use add to add values faster also you can chain it
  point.add(0.5, 3).add(0.7, 2);

  point[1] = 0; // alias for add

  for (double i = 0; i < 1; i += 0.1) {
    print('$i: ${point[i]}'); // or use `point.getValue(i)`
  }
}
