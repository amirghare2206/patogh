import 'dart:async';
import 'package:flutter/material.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/theme/patogh_theme.dart';

/// Server-authoritative game view. The server validates turns and moves.
/// Tic-tac-toe and Snakes & Ladders are implemented in migration V14.
/// Chess and Backgammon are not advertised as playable until their engines exist.
class GameRoomPlayPage extends StatefulWidget {
  final String roomCode;
  final String title;
  final IconData icon;
  final String? gameType;
  const GameRoomPlayPage({super.key, required this.roomCode, required this.title, required this.icon, this.gameType});
  @override
  State<GameRoomPlayPage> createState() => _GameRoomPlayPageState();
}

class _GameRoomPlayPageState extends State<GameRoomPlayPage> {
  Timer? _timer;
  Map<String, dynamic>? _payload;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  Map<String, dynamic> get _state => Map<String, dynamic>.from((_payload?['state'] as Map?) ?? const {});
  String get _type => '${_payload?['game_type'] ?? widget.gameType ?? ''}';
  List<Map<String, dynamic>> get _players => ((_payload?['players'] as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  int? get _mySeat {
    final id = PlatformServices.currentUserId;
    for (final p in _players) { if ('${p['user_id']}' == id) return (p['seat'] as num?)?.toInt(); }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh(showLoading: false));
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _refresh({bool showLoading = true}) async {
    if (_busy) return;
    if (showLoading && mounted) setState(() => _loading = true);
    try {
      final data = await PlatformServices.getGameStateV14(widget.roomCode);
      if (mounted) setState(() { _payload = data; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = _friendly(e));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  String _friendly(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('room membership')) return 'این حساب عضو اتاق نیست؛ با کد اتاق دوباره وارد شو.';
    if (s.contains('room not found')) return 'اتاق پیدا نشد یا بسته شده است.';
    if (s.contains('wait for another player')) return 'برای شروع بازی منتظر بازیکن دیگری بمان.';
    if (s.contains('not your turn')) return 'الان نوبت تو نیست.';
    if (s.contains('cell already used')) return 'این خانه قبلاً انتخاب شده است.';
    if (s.contains('engine not yet available')) return 'موتور این بازی هنوز فعال نشده است.';
    return 'ارتباط با اتاق بازی برقرار نشد. اتصال را بررسی کن و دوباره تلاش کن.';
  }

  Future<void> _action(Map<String, dynamic> action) async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final data = await PlatformServices.submitGameActionV14(roomCode: widget.roomCode, action: action);
      if (mounted) setState(() => _payload = data);
    } catch (e) { if (mounted) setState(() => _error = _friendly(e)); }
    finally { if (mounted) setState(() => _busy = false); await _refresh(showLoading: false); }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final status = '${state['status'] ?? 'loading'}';
    final turn = (state['current_seat'] as num?)?.toInt();
    final myTurn = status == 'active' && turn != null && turn == _mySeat;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_forward_rounded)), actions: [IconButton(onPressed: _loading ? null : () => _refresh(), icon: const Icon(Icons.refresh_rounded), tooltip: 'تازه‌سازی')]),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: PatoghTheme.brandGradient, borderRadius: BorderRadius.circular(22)), child: Row(children: [Icon(widget.icon, size: 32, color: Colors.white), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), Text('کد اتاق ${widget.roomCode} • ${_statusLabel(status)}', style: const TextStyle(color: Colors.white70, fontSize: 11))]))])),
        const SizedBox(height: 12),
        if (_loading && _payload == null) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
        if (_error != null) _message(_error!, error: true),
        if (_payload != null) ...[
          _playersPanel(turn),
          const SizedBox(height: 16),
          if (_type == 'tic_tac_toe') _ticTacToe(state, myTurn && !_busy),
          if (_type == 'snakes_ladders') _snakesLadders(state, myTurn && !_busy),
          if (_type == 'chess' || _type == 'backgammon' || status == 'engine_unavailable') _message('اتاق مشترک فعال است، اما موتور قوانین و صفحه بازی ${widget.title} هنوز پیاده‌سازی نشده؛ این بازی در این نسخه قابل انجام نیست.'),
          if (status == 'waiting') _message('برای شروع بازی باید حداقل یک بازیکن دیگر وارد اتاق شود.'),
          if (status == 'won') _message('بازی تمام شد؛ برنده صندلی ${state['winner_seat']} است.'),
          if (status == 'draw') _message('بازی مساوی شد.'),
          if (status == 'active' && !myTurn) _message('نوبت بازیکن صندلی $turn است. وضعیت هر سه ثانیه تازه می‌شود.'),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator(minHeight: 2)),
        ],
        const SizedBox(height: 10), _message('وضعیت بازی از سرور خوانده می‌شود؛ حرکت‌ها باید از طرف سرور تأیید شوند.'),
      ])),
    );
  }

  String _statusLabel(String status) => switch (status) {'active' => 'در حال بازی', 'waiting' => 'منتظر بازیکن', 'won' => 'پایان بازی', 'draw' => 'مساوی', 'engine_unavailable' => 'موتور فعال نیست', _ => 'در حال دریافت وضعیت'};

  Widget _playersPanel(int? turn) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: PatoghTheme.surface, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('بازیکنان', style: TextStyle(fontWeight: FontWeight.w900)), ..._players.map((p) { final seat = (p['seat'] as num?)?.toInt() ?? 0; return ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: seat == turn ? PatoghTheme.teal : PatoghTheme.surface2, child: Text('$seat')), title: Text('${p['name'] ?? 'کاربر پاتوق'}${seat == _mySeat ? ' (من)' : ''}'), trailing: seat == turn && '${_state['status']}' == 'active' ? const Text('نوبت', style: TextStyle(color: PatoghTheme.teal)) : null); })]));

  Widget _ticTacToe(Map<String, dynamic> state, bool enabled) {
    final board = (state['board'] as List?)?.map((v) => (v as num).toInt()).toList() ?? List<int>.filled(9, 0);
    return Column(children: [const Text('دوز', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 12), AspectRatio(aspectRatio: 1, child: GridView.builder(physics: const NeverScrollableScrollPhysics(), itemCount: 9, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8), itemBuilder: (context, i) { final v = board[i]; return Material(color: PatoghTheme.surface, borderRadius: BorderRadius.circular(16), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: enabled && v == 0 ? () => _action({'cell': i}) : null, child: Center(child: Text(v == 1 ? '×' : v == 2 ? '○' : '', style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: v == 1 ? PatoghTheme.orange : PatoghTheme.teal))))); })), const SizedBox(height: 8), Text(enabled ? 'نوبت توست؛ یک خانه خالی را انتخاب کن.' : 'برای حرکت باید نوبت تو باشد.', style: const TextStyle(color: PatoghTheme.muted))]);
  }

  Widget _snakesLadders(Map<String, dynamic> state, bool enabled) {
    final positions = (state['positions'] as List?)?.map((v) => (v as num).toInt()).toList() ?? List<int>.filled(4, 0);
    final maxPlayers = (_payload?['max_players'] as num?)?.toInt() ?? 2;
    final dice = state['last_dice'];
    final colors = <Color>[PatoghTheme.orange, PatoghTheme.teal, PatoghTheme.purple, const Color(0xFFFFD166)];
    return Column(children: [const Text('مار و پله', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('آخرین تاس: ${dice ?? '—'}', style: const TextStyle(color: PatoghTheme.muted)), const SizedBox(height: 10), AspectRatio(aspectRatio: 1, child: GridView.builder(physics: const NeverScrollableScrollPhysics(), itemCount: 100, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 2, mainAxisSpacing: 2), itemBuilder: (context, i) { final n = i + 1; final seats = <int>[]; for (var j = 0; j < maxPlayers && j < positions.length; j++) { if (positions[j] == n) seats.add(j + 1); } return Container(decoration: BoxDecoration(color: n.isEven ? PatoghTheme.surface : PatoghTheme.surface2, borderRadius: BorderRadius.circular(4)), child: Stack(children: [Align(alignment: Alignment.topLeft, child: Text('$n', style: const TextStyle(fontSize: 8, color: PatoghTheme.muted))), if (seats.isNotEmpty) Center(child: Wrap(spacing: 1, children: seats.map((seat) => Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[(seat - 1) % colors.length], shape: BoxShape.circle))).toList()))])); })), const SizedBox(height: 12), FilledButton.icon(onPressed: enabled ? () => _action({'type': 'roll'}) : null, icon: const Icon(Icons.casino_rounded), label: const Text('تاس بریز')), const SizedBox(height: 6), Text(enabled ? 'نوبت توست؛ تاس از سمت سرور تولید می‌شود.' : 'وقتی نوبت تو برسد، می‌توانی تاس بریزی.', style: const TextStyle(color: PatoghTheme.muted))]);
  }

  Widget _message(String text, {bool error = false}) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: PatoghTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: error ? Colors.redAccent.withAlpha(130) : PatoghTheme.surface2)), child: Text(text, style: const TextStyle(fontSize: 12, height: 1.65)));
}
