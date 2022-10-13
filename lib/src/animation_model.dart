import 'breakpoint.dart';

class AnimationModel {
  final Map<String, Breakpoint> _props = {};

  /// returns list of all defined properties
  List<String> get keys => _props.entries.map((e) => e.key).toList();

  /// get property model of [key] to ease control
  AnimationModelProperty getProperty(String key) =>
      AnimationModelProperty(this, key);

  /// add new or set [value] at [pointer] from the property of [key]
  void setProperty(String key, double pointer, double value) {
    if (!_props.containsKey(key)) {
      _props[key] = Breakpoint(0, value);
    }
    _props[key]!.add(pointer, value);
  }

  /// set property values using [json] for the property with [key]
  void setPropertyJson(String key, Map<double, double> json) {
    if (!_props.containsKey(key)) {
      _props[key] = Breakpoint.fromJson(json);
    } else {
      _props[key]!.addFromJson(json);
    }
  }

  /// set all properties values with [json]
  void setJson(Map<String, Map<double, double>> json) {
    for (final e in json.entries) {
      setPropertyJson(e.key, e.value);
    }
  }

  /// get value of property [key] at [pointer]
  ///
  /// throws [Exception] of property with [key] is not defined
  double getValue(String key, double pointer) {
    if (!_props.containsKey(key)) {
      throw Exception('property with key: $key is not defined yet!');
    }
    return _props[key]!.getValueAt(pointer);
  }

  /// calculate all properties values at [pointer] and return [Map]
  /// with key as property key and value as property calculated value
  Map<String, double> calculate(double pointer) =>
      Map.fromEntries(keys.map((e) => MapEntry(e, getValue(e, pointer))));
}

class AnimationModelProperty {
  AnimationModelProperty(this.model, this.key);

  /// the property key
  final String key;

  /// the model where the property breakpoints stored
  final AnimationModel model;

  /// add new or set breakpoint for this property at [pointer] with [value]
  void add(double pointer, double value) =>
      model.setProperty(key, pointer, value);

  /// set property values using [json]
  void setJson(Map<double, double> json) => model.setPropertyJson(key, json);

  /// get property value at [pointer]
  double value(double pointer) => model.getValue(key, pointer);

  /// alias for [value]
  double operator [](double pointer) => value(pointer);

  /// alias for [add]
  void operator []=(double pointer, double value) => add(pointer, value);
}
