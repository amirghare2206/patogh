#!/usr/bin/env python3
"""Static guard checks for the V14 working snapshot; not a Dart/SQL compiler."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

def read(path: str) -> str:
    file = ROOT / path
    if not file.is_file():
        raise RuntimeError(f"Required file missing: {path}")
    return file.read_text(encoding="utf-8")

checks = []
def check(name: str, condition: bool) -> None:
    checks.append((name, condition))

home = read("lib/pages/home_page.dart")
quiz = read("lib/pages/auth/personality_test_page.dart")
profile = read("lib/models/user_profile.dart")
app = read("lib/app.dart")
services = read("lib/services/platform_services.dart")
app_state = read("lib/state/app_state.dart")
games = read("lib/pages/game_detail_page.dart")
game_play = read("lib/pages/game_room_play_page.dart")
matching = read("lib/pages/matching_page.dart")
help_widget = read("lib/widgets/page_help_button.dart")
edit_profile = read("lib/pages/edit_profile_page.dart")
mock_data = read("lib/data/mock_data.dart")
game_sql = read("backend/supabase/migrations/20261021100000_v14_turn_based_game_state.sql")

baseline_ids = re.findall(r"id: '(intro|talk|game|work|learn|travel|think|sport|story|empathy|volunteer|companion)'", mock_data)
check("12 baseline category IDs", len(set(baseline_ids)) == 12)
check("home uses category grid", "_serviceCategories(context)" in home and "GridView.builder" in home)
check("home header has profile action", "right: 0" in home and "ProfilePage" in home)
check("home header keeps notification action", "NotificationsPage" in home)
check("eight preference questions", quiz.count("    _Question(") == 8)
check("quiz requires all answers", "answered == _questions.length" in quiz)
check("quiz answers stored in profile", "personalityAnswers" in quiz and "personalityAnswers" in profile)
check("global help entry wired", "PageHelpButton" in app)
check("guide covers category/onboarding/beta workflows", all(term in help_widget for term in ["۱۲ دسته پاتوق", "پرسش‌نامه اجتماعی", "تست گروهی ۱۰ نفره"]))
check("matching error string uses escaped newline", "Migration پیشنهاد هم‌پاتوقی را بررسی کن.\\n${snapshot.error}" in matching)
check("matching refreshes after shared app-state changes", "addListener(_onSharedStateChanged)" in matching and "removeListener(_onSharedStateChanged)" in matching)
check("profile editor preserves V14 personality fields", all(x in edit_profile for x in ["personalityAnswers: current?.personalityAnswers", "personalityTags: current?.personalityTags", "leisureStyle: current?.leisureStyle"]))
check("profile editor uses full interest catalog", "محیط زیست" in edit_profile and "کافه و دورهمی" in edit_profile and "حداقل ۳ مورد" in edit_profile)
check("remote profile suggestions wired", "list_suggested_profiles_v14" in services)
check("profile migration exists", (ROOT / "backend/supabase/migrations/20261020130000_v14_profile_personality.sql").is_file())
check("shared game-room migration exists", (ROOT / "backend/supabase/migrations/20261020140000_v14_shared_game_rooms.sql").is_file())
check("turn-based game state migration exists", (ROOT / "backend/supabase/migrations/20261021100000_v14_turn_based_game_state.sql").is_file())
check("shared room RPCs wired", all(x in services for x in ["create_game_room_v14", "list_game_rooms_v14", "join_game_room_v14", "leave_game_room_v14"]))
check("turn-based game state RPCs wired", all(x in services for x in ["get_game_state_v14", "submit_game_action_v14"]) and all(x in game_play for x in ["_ticTacToe", "_snakesLadders", "Timer.periodic"]))
check("game state SQL enforces membership and turn", all(x in game_sql for x in ["room membership required", "not your turn", "cell already used", "auth.uid()", "enable row level security"]))
check("server-side game actions include win and dice logic", all(x in game_sql for x in ["winner_seat", "random()*6", "game_type='tic_tac_toe'", "game_type='snakes_ladders'"]))
check("game room navigates to play screen", "GameRoomPlayPage" in games)
check("beta test plan exists", (ROOT / "docs/V14_BETA_10_TEST_PLAN_FA.md").is_file())
check("acceptance matrix exists", (ROOT / "docs/V14_ACCEPTANCE_MATRIX_FA.md").is_file())
check("Realtime subscription and queued refresh", "subscribeToSharedData" in services and "_sharedRefreshPending" in app_state)
check("no hard-coded sample room codes", all(code not in games for code in ["248731", "731924", "519842"]))
check("no fake online-player counter", "۱۲ هم‌پاتوقی آماده بازی هستند" not in games)

sensitive_patterns = [r"(^|/)secret\.txt$", r"(^|/)keystore\.base64$", r"(^|/)key\.properties$", r"\.jks$", r"\.keystore$", r"\.p12$", r"\.pfx$", r"\.pem$", r"(^|/)\.env(\..*)?$"]
found_sensitive = []
for file in ROOT.rglob("*"):
    if not file.is_file():
        continue
    rel = file.relative_to(ROOT).as_posix()
    if any(re.search(pattern, rel, re.I) for pattern in sensitive_patterns):
        found_sensitive.append(rel)
check("no obvious signing/secret files in source tree", not found_sensitive)

for name, ok in checks:
    print(f"{'PASS' if ok else 'FAIL'}: {name}")
if found_sensitive:
    print("Sensitive-looking paths:")
    for path in found_sensitive:
        print(f"  {path}")
print("NOTE: Static repository checks only; run flutter analyze/test and apply SQL migrations on Staging before building/testing APK.")
sys.exit(0 if all(ok for _, ok in checks) else 1)
