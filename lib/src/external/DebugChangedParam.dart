
class DebugChangedParam<ENUM> {
  final ENUM param;
  final Object? before;
  final Object? after;
  const DebugChangedParam(
    this.param,
    this.before,
    this.after,
  );

  @override
  String toString() => "[$param] '$before' = '$after'";
}