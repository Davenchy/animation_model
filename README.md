AnimationModel is a pure dart package to animate multiple values at the same time
using the Breakpoint objects which is a linked list object

## Getting started

- To animate single property use [**Breakpoint**](#breakpoint) class
- To animate multiple properties use [**AnimationModel**](#animationmodel) class

## Usage

### Breakpoint

```dart
final point = Breakpoint(0, 10);

final point2 = Breakpoint(0.2, 7); // create another point
point.insert(point2); // insert to the linked list

// use add to add values faster also you can chain it
point.add(0.5, 3).add(0.7, 2);

point[1] = 0; // alias for add

for (double i = 0; i < 1; i += 0.1) {
  print('$i: ${point[i]}'); // or use `point.getValue(i)`
}
```

results

```text
0.0: 10.0 // at 0.0 = 10
0.1: 8.5  // calculated
0.2: 7.0  // at 0.2 = 7
0.3: 5.7  // calculated
0.4: 4.3  // calculated
0.5: 3.0  // at 0.5 = 3
0.6: 2.5  // calculated
0.7: 2.0  // at 0.7 = 2
0.8: 1.3  // calculated
0.9: 0.7  // calculated
1.0: 0.0    // at 1.0 = 0
```

### AnimationModel

```dart
  final model = AnimationModel();

  model.setPropertyJson('a', {0.5: 10, 1: 0});
  model.setPropertyJson('b', {0: 10, 1: 0});
  model.setPropertyJson('c', {0: 10, 1: 5});

  for (double i = 0; i < 1; i += 0.1) {
    print('$i: ${model.calculate(i)}');
  }

  // use model.getValue(key, pointer)
  // to get the value of the property with [key]
  // at [pointer]

  print('\nvalues at pointer = 0.5');
  print('a: ${model.getValue('a', 0.5)}');
  print('b: ${model.getValue('b', 0.5)}');
  print('c: ${model.getValue('c', 0.5)}');
```

results

```text
0.0: {a: 10.0, b: 10.0, c: 10.0}
0.1: {a: 10.0, b: 9.0, c: 9.5}
0.2: {a: 10.0, b: 8.0, c: 9.0}
0.3: {a: 10.0, b: 7.0, c: 8.5}
0.4: {a: 10.0, b: 6.0, c: 8.0}
0.5: {a: 10.0, b: 5.0, c: 7.5}
0.6: {a: 8.0, b: 4.0, c: 7.0}
0.7: {a: 6.0, b: 3.0, c: 6.5}
0.8: {a: 4.0, b: 2.0, c: 6.0}
0.9: {a: 2.0, b: 1.0, c: 5.5}
1.0: {a: 0, b: 0, c: 5.0}

values at pointer = 0.5
a: 10.0
b: 5.0
c: 7.5
```
