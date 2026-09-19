import 'package:flutter/foundation.dart';
import 'package:patogh/models/v10_models.dart';

class V10State extends ChangeNotifier {
  PrivateEventPricingConfig privateEventPricing =
      const PrivateEventPricingConfig(
        basePublishFee: 300000,
        includedInvites: 20,
        extraInviteFee: 10000,
        smsUnitFee: 1500,
        boostFee: 250000,
        premiumTemplateFee: 180000,
      );

  final Map<String, PrivateEventPublicationRecord> publicationRecords =
      <String, PrivateEventPublicationRecord>{};

  final List<SurprisePlan> surprises = <SurprisePlan>[
    const SurprisePlan(
      id: 'surprise-1',
      title: 'تولد غافلگیرکننده برای سارا',
      occasion: 'تولد',
      targetLabel: '@sara_patogh',
      revealLabel: 'جمعه، ساعت ۲۰',
      audienceLabel: 'دوستان نزدیک',
      invitedCount: 12,
      joinedCount: 9,
      hiddenFromTarget: true,
      status: SurpriseStatus.inviting,
    ),
  ];

  final List<GolrizonCampaign> golrizons = <GolrizonCampaign>[
    const GolrizonCampaign(
      id: 'gol-1',
      title: 'یک صندلی برای یک هم‌پاتوقی',
      purpose: GolrizonPurpose.eventSeat,
      beneficiaryLabel: 'هویت برای عموم مخفی است',
      goalAmount: 850000,
      raisedAmount: 620000,
      deadlineLabel: 'تا ۳ روز دیگر',
      eventId: 'breakfast-01',
      eventTitle: 'قرار صبحانه پاتوق',
      beneficiaryVerified: true,
      publicListing: true,
      status: GolrizonStatus.active,
      contributorCount: 8,
    ),
    const GolrizonCampaign(
      id: 'gol-2',
      title: 'گل‌ریزون برای تهیه بسته‌های فرهنگی کودک',
      purpose: GolrizonPurpose.charity,
      beneficiaryLabel: 'پویش تأییدشده پاتوق',
      goalAmount: 5000000,
      raisedAmount: 3400000,
      deadlineLabel: 'تا پایان ماه',
      beneficiaryVerified: true,
      publicListing: true,
      status: GolrizonStatus.active,
      contributorCount: 31,
    ),
  ];

  final List<GolrizonContribution> contributions = <GolrizonContribution>[];

  PrivateEventPublicationRecord publicationFor(String eventId) {
    return publicationRecords[eventId] ??
        PrivateEventPublicationRecord(eventId: eventId);
  }

  PrivateEventPublicationQuote quotePrivateEvent({
    required int inviteCount,
    int smsCount = 0,
    bool includeBoost = false,
    bool premiumTemplate = false,
  }) {
    final extraInvites = (inviteCount - privateEventPricing.includedInvites)
        .clamp(0, 1000000)
        .toInt();

    return PrivateEventPublicationQuote(
      baseFee: privateEventPricing.basePublishFee,
      extraInviteCost: extraInvites * privateEventPricing.extraInviteFee,
      smsCost: smsCount * privateEventPricing.smsUnitFee,
      boostCost: includeBoost ? privateEventPricing.boostFee : 0,
      premiumTemplateCost: premiumTemplate
          ? privateEventPricing.premiumTemplateFee
          : 0,
    );
  }

  Future<void> payAndPublishPrivateEvent({
    required String eventId,
    required PrivateEventPublicationQuote quote,
    required bool boostEnabled,
    required bool premiumTemplateEnabled,
  }) async {
    publicationRecords[eventId] = PrivateEventPublicationRecord(
      eventId: eventId,
      amountPaid: quote.total,
      paid: true,
      published: true,
      boostEnabled: boostEnabled,
      premiumTemplateEnabled: premiumTemplateEnabled,
    );
    notifyListeners();
  }

  Future<void> updatePrivateEventPricing(
    PrivateEventPricingConfig config,
  ) async {
    privateEventPricing = config;
    notifyListeners();
  }

  Future<void> createSurprise({
    required String title,
    required String occasion,
    required String targetLabel,
    required String revealLabel,
    required String audienceLabel,
  }) async {
    surprises.insert(
      0,
      SurprisePlan(
        id: 'surprise-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        occasion: occasion,
        targetLabel: targetLabel,
        revealLabel: revealLabel,
        audienceLabel: audienceLabel,
        invitedCount: 0,
        joinedCount: 0,
        hiddenFromTarget: true,
        status: SurpriseStatus.planning,
      ),
    );
    notifyListeners();
  }

  Future<void> inviteToSurprise(String surpriseId) async {
    final index = surprises.indexWhere((item) => item.id == surpriseId);
    if (index == -1) return;

    final current = surprises[index];
    surprises[index] = current.copyWith(
      invitedCount: current.invitedCount + 1,
      status: SurpriseStatus.inviting,
    );
    notifyListeners();
  }

  Future<void> revealSurprise(String surpriseId) async {
    final index = surprises.indexWhere((item) => item.id == surpriseId);
    if (index == -1) return;

    surprises[index] = surprises[index].copyWith(
      hiddenFromTarget: false,
      status: SurpriseStatus.revealed,
    );
    notifyListeners();
  }

  Future<void> createGolrizon({
    required String title,
    required GolrizonPurpose purpose,
    required String beneficiaryLabel,
    required int goalAmount,
    required String deadlineLabel,
    String? eventId,
    String? eventTitle,
  }) async {
    golrizons.insert(
      0,
      GolrizonCampaign(
        id: 'gol-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        purpose: purpose,
        beneficiaryLabel: beneficiaryLabel,
        goalAmount: goalAmount,
        raisedAmount: 0,
        deadlineLabel: deadlineLabel,
        eventId: eventId,
        eventTitle: eventTitle,
        beneficiaryVerified: false,
        publicListing: true,
        status: GolrizonStatus.pendingApproval,
        contributorCount: 0,
      ),
    );
    notifyListeners();
  }

  Future<void> approveGolrizon(String campaignId) async {
    final index = golrizons.indexWhere((item) => item.id == campaignId);
    if (index == -1) return;

    golrizons[index] = golrizons[index].copyWith(
      beneficiaryVerified: true,
      status: GolrizonStatus.active,
    );
    notifyListeners();
  }

  Future<void> rejectGolrizon(String campaignId) async {
    final index = golrizons.indexWhere((item) => item.id == campaignId);
    if (index == -1) return;

    golrizons[index] = golrizons[index].copyWith(
      status: GolrizonStatus.rejected,
    );
    notifyListeners();
  }

  Future<void> contribute({
    required String campaignId,
    required String contributorLabel,
    required int amount,
    required bool anonymous,
  }) async {
    if (amount <= 0) return;

    final index = golrizons.indexWhere((item) => item.id == campaignId);
    if (index == -1) return;

    final current = golrizons[index];
    if (current.status != GolrizonStatus.active) return;

    final actualAmount = amount.clamp(0, current.remaining).toInt();
    if (actualAmount <= 0) return;

    contributions.insert(
      0,
      GolrizonContribution(
        id: 'contribution-${DateTime.now().microsecondsSinceEpoch}',
        campaignId: campaignId,
        contributorLabel: contributorLabel,
        amount: actualAmount,
        anonymous: anonymous,
        createdAtLabel: 'همین الان',
      ),
    );

    final updatedRaised = current.raisedAmount + actualAmount;
    golrizons[index] = current.copyWith(
      raisedAmount: updatedRaised,
      contributorCount: current.contributorCount + 1,
      status: updatedRaised >= current.goalAmount
          ? GolrizonStatus.funded
          : GolrizonStatus.active,
    );

    notifyListeners();
  }
}

final V10State v10State = V10State();
