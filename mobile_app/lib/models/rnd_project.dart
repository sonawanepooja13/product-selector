enum EcoStatus { draft, inReview, approved, implemented }

class EcoChangeOrder {
  final String ecoNumber; // ECO-2026-001
  final String title;
  final String proposedBy;
  final String impactLevel; // High, Medium, Low
  final EcoStatus status;
  final DateTime date;

  const EcoChangeOrder({
    required this.ecoNumber,
    required this.title,
    required this.proposedBy,
    required this.impactLevel,
    required this.status,
    required this.date,
  });

  String get statusLabel {
    switch (status) {
      case EcoStatus.draft:
        return 'Draft';
      case EcoStatus.inReview:
        return 'In Review';
      case EcoStatus.approved:
        return 'Approved';
      case EcoStatus.implemented:
        return 'Implemented';
    }
  }
}

class RndPdlcPhase {
  final String phaseName; // Concept, Design & CAD, Prototype, Testing, Certification
  final double completionPercentage;
  final bool isCompleted;

  const RndPdlcPhase({
    required this.phaseName,
    required this.completionPercentage,
    required this.isCompleted,
  });
}
