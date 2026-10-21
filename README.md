# Patogh V14 — Integrated Working Snapshot

This is a working source snapshot based on the V14 branch supplied by the project owner. It is **not a release candidate** until the Flutter checks, Staging migrations, and device/multi-user tests in `V14_TRANSFER_README_FA.md` have passed.

Start with:

- `V14_TRANSFER_README_FA.md` — safe transfer and Staging-only migration order.
- `V14_INTEGRATED_PROGRESS_FA.md` — implemented vs pending work.
- `docs/V14_BETA_10_TEST_PLAN_FA.md` — ten-user beta acceptance checklist.
- `python3 tool/preflight_v14_working.py` — static repository guard checks (not a Dart/SQL compiler).

Do not run V14 migrations against Production. Signing files and local secrets are intentionally excluded from the transfer archive.
