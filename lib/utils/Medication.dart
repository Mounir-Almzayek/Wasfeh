class Medication {
  final String name;
  final DateTime lastTakenTime;
  final Duration interval;
  final int id;

  Medication({
    required this.name,
    required this.lastTakenTime,
    required this.interval,
    required this.id,
  });
}
