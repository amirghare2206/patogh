class ExternalCalendarRecord {
  final String externalId;
  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String source;
  final String sourceVersion;
  final double certainty;
  final Map<String, dynamic> metadata;

  const ExternalCalendarRecord({
    required this.externalId,
    required this.title,
    required this.startsAt,
    this.endsAt,
    required this.source,
    required this.sourceVersion,
    required this.certainty,
    this.metadata = const {},
  });
}

abstract interface class CalendarFeedProvider {
  String get providerId;
  Future<List<ExternalCalendarRecord>> fetch({
    required DateTime from,
    required DateTime to,
  });
}

abstract interface class SportsFeedProvider {
  String get providerId;
  Future<List<ExternalCalendarRecord>> upcomingSports({
    required DateTime from,
    required DateTime to,
  });
}

abstract interface class OpportunitySignalProvider {
  String get providerId;
  Future<Map<String, dynamic>> demandSignals({
    required String provinceId,
    required String cityId,
  });
}
