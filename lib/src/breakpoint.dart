typedef BreakpointFindCondition = bool Function(Breakpoint point);

class Breakpoint {
  Breakpoint(this.pointer, this.value);

  factory Breakpoint.fromList(List<Breakpoint> points) {
    Breakpoint? first;
    for (final p in points) {
      if (first == null) {
        first = p;
      } else {
        first.insert(p);
      }
    }
    return first!;
  }

  factory Breakpoint.fromJson(Map<double, double> json) {
    final points = json.entries.map((e) => Breakpoint(e.key, e.value)).toList();
    return Breakpoint.fromList(points);
  }

  /// the current point pointer in the linked list
  final double pointer;

  /// the current point value
  double value;

  /// the next point in the linked list
  Breakpoint? next;

  /// the previous point in the linked list
  Breakpoint? prev;

  /// check if has next point
  bool get hasNext => next != null;

  /// check if has previous point
  bool get hasPrev => prev != null;

  /// returns the linked list length;
  int get length => toList().length;

  /// disconnects the current point from the linked list
  ///
  /// it disconnects the current point and sets the next and previous points with null
  void disconnect() {
    next?.prev = null;
    prev?.next = null;
    next = null;
    prev = null;
  }

  /// removes the current point from the linked list
  ///
  /// it disconnects the current point
  /// then connects the next and the previous points to gether
  void remove() {
    next?.prev = prev;
    prev?.next = next;
    next = null;
    prev = null;
  }

  /// inserts [point] directly after the current one
  void insertAfter(Breakpoint point) {
    next?.prev = point;
    point.next = next;
    point.prev = this;
    next = point;
  }

  /// inserts [point] directly before the current one
  void insertBefore(Breakpoint point) {
    prev?.next = point;
    point.prev = prev;
    point.next = this;
    prev = point;
  }

  /// find next point with [condition] if no point found returns null
  Breakpoint? findNext(BreakpointFindCondition condition) {
    Breakpoint? current = next;
    while (current != null) {
      if (condition(current)) return current;
      current = current.next;
    }
    return current;
  }

  /// find previous point with [condition] if no point found returns null
  Breakpoint? findPrev(BreakpointFindCondition condition) {
    Breakpoint? current = prev;
    while (current != null) {
      if (condition(current)) return current;
      current = current.prev;
    }
    return current;
  }

  /// returns the point at the beginning of the linked list
  Breakpoint getHead() {
    Breakpoint current = this;
    while (current.hasPrev) {
      current = current.prev!;
    }
    return current;
  }

  /// returns the point at the end of the linked list
  Breakpoint getTail() {
    Breakpoint current = this;
    while (current.hasNext) {
      current = current.next!;
    }
    return current;
  }

  /// inserts [value] at [pointer] as a new [Breakpoint]
  ///
  /// creates a new point with [value] at [pointer] then inserts it to the linked list
  ///
  /// returns the current point again so you can chain
  ///
  /// example
  /// ```
  /// final head = Breakpoint(0, 10).add(0.2, 8).add(1, 0);
  /// ```
  Breakpoint add(double pointer, double value) {
    final point = Breakpoint(pointer, value);
    insert(point);
    return this;
  }

  void addFromJson(Map<double, double> json) {
    for (final e in json.entries) {
      add(e.key, e.value);
    }
  }

  /// insert [point] into the linked list
  ///
  /// if [point] at the same [pointer] then only the value is copied to the current point
  void insert(Breakpoint point) {
    if (same(point)) {
      value = point.value;
    } else if (point > this) {
      final p = findNext((p) => p >= point);
      if (p == null) {
        getTail().insertAfter(point);
      } else if (p.same(point)) {
        p.insert(point);
      } else {
        p.insertBefore(point);
      }
    } else if (point < this) {
      final p = findPrev((p) => p <= point);
      if (p == null) {
        getHead().insertBefore(point);
      } else if (p.same(point)) {
        p.insert(point);
      } else {
        p.insertAfter(point);
      }
    }
  }

  /// returns true if [other.pointer] equals to [pointer]
  bool same(Breakpoint other) => pointer == other.pointer;

  /// returns true if [other.value] equals to [value]
  bool equal(Breakpoint other) => value == other.value;

  /// returns the progress as [t] between the current breakpoint and [point]
  ///
  /// [t] and the returned progress are values between 0 included and 1 included
  double progressTo(Breakpoint point, double t) =>
      (point.pointer - pointer) * t + pointer;

  /// converts global pointer to local point (a pointer between [a] and [b])
  ///
  /// Say the linked list is: <0:10> - <0.2:8> - <1.0:0> then
  ///
  /// ```
  /// 0 |------------- Global Progress ------------| 1
  ///   <0:10> --- <0.2:8> ---------------- <1.0:0>
  /// ```
  ///  ---
  ///
  /// ```
  ///   <0.2:8> ---------------------------- <1.0:0>
  /// 0 |------------- Local Progress ---------------| 1
  /// ```
  ///
  double progressGlobalToLocal(Breakpoint a, Breakpoint b, double t) =>
      (t - b.pointer) / (a.pointer - b.pointer);

  /// returns the value at a progress point [t] between current point and [point]
  ///
  /// [t] is a value in range 0 included and 1 included
  double clampTo(Breakpoint point, double t) =>
      (point.value - value) * t + value;

  /// returns value at the progress point [t]
  ///
  /// [t] is a value in range 0 included and 1 included
  double getValueAt(double t) {
    final head = getHead();
    if (head.pointer >= t) return head.value;
    final p = head.findNext((p) => p.pointer >= t); // null, ==, >
    if (p == null) {
      return getTail().value;
    } else if (p.pointer == t) {
      return p.value;
    } else {
      if (!p.hasPrev) return p.value;
      final prog = progressGlobalToLocal(p, p.prev!, t);
      return p.prev!.clampTo(p, prog);
    }
  }

  /// returns all breakpoints as list from head til tail
  List<Breakpoint> toList() {
    Breakpoint current = getHead();
    final List<Breakpoint> points = [];
    while (true) {
      points.add(current);
      if (!current.hasNext) break;
      current = current.next!;
    }
    return points;
  }

  /// converts the linked list into a [Map] of pointers as keys
  Map<double, double> toJson() {
    final entries = toList().map((e) => MapEntry(e.pointer, e.value));
    return Map.fromEntries(entries);
  }

  @override
  String toString() => '<$pointer:$value>';

  /// alias for [add]
  void operator []=(double pointer, double value) => add(pointer, value);

  /// alias for [getValueAt]
  double operator [](double pointer) => getValueAt(pointer);

  /// returns true if current point is after the [other] point
  bool operator >(Breakpoint other) => pointer > other.pointer;

  /// returns true if current point is before the [other] point
  bool operator <(Breakpoint other) => pointer < other.pointer;

  /// returns true if current point is after the [other] point or at the same [pointer]
  bool operator >=(Breakpoint other) => pointer >= other.pointer;

  /// returns true if current point is before the [other] point or at the same [pointer]
  bool operator <=(Breakpoint other) => pointer <= other.pointer;

  /// compare current and [other] breakpoints and return -1, 0 or 1
  ///
  /// returns 1 if [other] pointer greater than current pointer
  ///
  /// returns 0 if [other] pointer equals to current pointer
  ///
  /// returns -1 if [other] pointer smaller than current pointer
  int compareTo(Breakpoint other) => other > this
      ? 1
      : other < this
          ? -1
          : 0;

  @override
  bool operator ==(Object other) =>
      other is Breakpoint &&
      identical(other, this) &&
      pointer == pointer &&
      value == value;

  @override
  int get hashCode => pointer.hashCode ^ value.hashCode;
}
