enum SurpriseStatus { planning, inviting, ready, revealed, cancelled }

extension SurpriseStatusX on SurpriseStatus {
  String get label {
    switch (this) {
      case SurpriseStatus.planning:
        return 'در حال برنامه‌ریزی';
      case SurpriseStatus.inviting:
        return 'در حال جمع‌کردن همراه‌ها';
      case SurpriseStatus.ready:
        return 'آماده سورپرایز';
      case SurpriseStatus.revealed:
        return 'سورپرایز انجام شد';
      case SurpriseStatus.cancelled:
        return 'لغو شده';
    }
  }
}

class SurprisePlan {
  final String id;
  final String title;
  final String occasion;
  final String targetLabel;
  final String revealLabel;
  final String audienceLabel;
  final int invitedCount;
  final int joinedCount;
  final bool hiddenFromTarget;
  final SurpriseStatus status;

  const SurprisePlan({
    required this.id,
    required this.title,
    required this.occasion,
    required this.targetLabel,
    required this.revealLabel,
    required this.audienceLabel,
    required this.invitedCount,
    required this.joinedCount,
    this.hiddenFromTarget = true,
    this.status = SurpriseStatus.planning,
  });

  SurprisePlan copyWith({
    int? invitedCount,
    int? joinedCount,
    bool? hiddenFromTarget,
    SurpriseStatus? status,
  }) {
    return SurprisePlan(
      id: id,
      title: title,
      occasion: occasion,
      targetLabel: targetLabel,
      revealLabel: revealLabel,
      audienceLabel: audienceLabel,
      invitedCount: invitedCount ?? this.invitedCount,
      joinedCount: joinedCount ?? this.joinedCount,
      hiddenFromTarget: hiddenFromTarget ?? this.hiddenFromTarget,
      status: status ?? this.status,
    );
  }
}

enum GolrizonPurpose { eventSeat, charity, personalHelp, communityCause }

extension GolrizonPurposeX on GolrizonPurpose {
  String get label {
    switch (this) {
      case GolrizonPurpose.eventSeat:
        return 'کمک هزینه شرکت در رویداد';
      case GolrizonPurpose.charity:
        return 'کار خیر';
      case GolrizonPurpose.personalHelp:
        return 'حل مشکل یک فرد';
      case GolrizonPurpose.communityCause:
        return 'هدف جمعی / عام‌المنفعه';
    }
  }
}

enum GolrizonStatus { pendingApproval, active, funded, closed, rejected }

extension GolrizonStatusX on GolrizonStatus {
  String get label {
    switch (this) {
      case GolrizonStatus.pendingApproval:
        return 'در انتظار تأیید';
      case GolrizonStatus.active:
        return 'فعال';
      case GolrizonStatus.funded:
        return 'تکمیل شده';
      case GolrizonStatus.closed:
        return 'بسته شده';
      case GolrizonStatus.rejected:
        return 'رد شده';
    }
  }
}

class GolrizonCampaign {
  final String id;
  final String title;
  final GolrizonPurpose purpose;
  final String beneficiaryLabel;
  final int goalAmount;
  final int raisedAmount;
  final String deadlineLabel;
  final String? eventId;
  final String? eventTitle;
  final bool beneficiaryVerified;
  final bool publicListing;
  final GolrizonStatus status;
  final int contributorCount;

  const GolrizonCampaign({
    required this.id,
    required this.title,
    required this.purpose,
    required this.beneficiaryLabel,
    required this.goalAmount,
    required this.raisedAmount,
    required this.deadlineLabel,
    this.eventId,
    this.eventTitle,
    this.beneficiaryVerified = false,
    this.publicListing = true,
    this.status = GolrizonStatus.pendingApproval,
    this.contributorCount = 0,
  });

  double get progress {
    if (goalAmount <= 0) return 0;
    return (raisedAmount / goalAmount).clamp(0, 1).toDouble();
  }

  int get remaining => (goalAmount - raisedAmount).clamp(0, goalAmount).toInt();

  GolrizonCampaign copyWith({
    int? raisedAmount,
    bool? beneficiaryVerified,
    GolrizonStatus? status,
    int? contributorCount,
  }) {
    return GolrizonCampaign(
      id: id,
      title: title,
      purpose: purpose,
      beneficiaryLabel: beneficiaryLabel,
      goalAmount: goalAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      deadlineLabel: deadlineLabel,
      eventId: eventId,
      eventTitle: eventTitle,
      beneficiaryVerified: beneficiaryVerified ?? this.beneficiaryVerified,
      publicListing: publicListing,
      status: status ?? this.status,
      contributorCount: contributorCount ?? this.contributorCount,
    );
  }
}

class GolrizonContribution {
  final String id;
  final String campaignId;
  final String contributorLabel;
  final int amount;
  final bool anonymous;
  final String createdAtLabel;

  const GolrizonContribution({
    required this.id,
    required this.campaignId,
    required this.contributorLabel,
    required this.amount,
    required this.anonymous,
    required this.createdAtLabel,
  });
}

class PrivateEventPricingConfig {
  final int basePublishFee;
  final int includedInvites;
  final int extraInviteFee;
  final int smsUnitFee;
  final int boostFee;
  final int premiumTemplateFee;

  const PrivateEventPricingConfig({
    required this.basePublishFee,
    required this.includedInvites,
    required this.extraInviteFee,
    required this.smsUnitFee,
    required this.boostFee,
    required this.premiumTemplateFee,
  });

  PrivateEventPricingConfig copyWith({
    int? basePublishFee,
    int? includedInvites,
    int? extraInviteFee,
    int? smsUnitFee,
    int? boostFee,
    int? premiumTemplateFee,
  }) {
    return PrivateEventPricingConfig(
      basePublishFee: basePublishFee ?? this.basePublishFee,
      includedInvites: includedInvites ?? this.includedInvites,
      extraInviteFee: extraInviteFee ?? this.extraInviteFee,
      smsUnitFee: smsUnitFee ?? this.smsUnitFee,
      boostFee: boostFee ?? this.boostFee,
      premiumTemplateFee: premiumTemplateFee ?? this.premiumTemplateFee,
    );
  }
}

class PrivateEventPublicationQuote {
  final int baseFee;
  final int extraInviteCost;
  final int smsCost;
  final int boostCost;
  final int premiumTemplateCost;

  const PrivateEventPublicationQuote({
    required this.baseFee,
    required this.extraInviteCost,
    required this.smsCost,
    required this.boostCost,
    required this.premiumTemplateCost,
  });

  int get total =>
      baseFee + extraInviteCost + smsCost + boostCost + premiumTemplateCost;
}

class PrivateEventPublicationRecord {
  final String eventId;
  final int amountPaid;
  final bool paid;
  final bool published;
  final bool boostEnabled;
  final bool premiumTemplateEnabled;

  const PrivateEventPublicationRecord({
    required this.eventId,
    this.amountPaid = 0,
    this.paid = false,
    this.published = false,
    this.boostEnabled = false,
    this.premiumTemplateEnabled = false,
  });
}
