import 'package:flutter/material.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminApprovalsPage extends StatelessWidget {
  const AdminApprovalsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'تأییدها',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'تأیید کسب‌وکار میزبان، مدیر رویداد، آژانس و درخواست‌های دسترسی',
              style: TextStyle(color: Color(0xFFAAAAAA)),
            ),
            const SizedBox(height: 18),
            ...appState.roleRequests.map(
              (request) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      request.applicantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.requestedRole.label,
                      style: const TextStyle(
                        color: PatoghTheme.orange,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.note,
                      style: const TextStyle(
                        color: Color(0xFFBBBBBB),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (request.status == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  appState.approveRoleRequest(request.id),
                              child: const Text('تأیید'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  appState.rejectRoleRequest(request.id),
                              child: const Text('رد'),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        request.status == 'approved' ? 'تأیید شده' : 'رد شده',
                        style: TextStyle(
                          color: request.status == 'approved'
                              ? const Color(0xFF7BE0A8)
                              : const Color(0xFFFF9B9B),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
