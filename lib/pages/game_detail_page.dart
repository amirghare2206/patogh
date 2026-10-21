import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/pages/game_room_play_page.dart';

class GameDetailPage extends StatefulWidget {
  final String title;
  final IconData icon;

  const GameDetailPage({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  final TextEditingController _roomCodeController = TextEditingController();
  List<_GameRoom> _rooms = <_GameRoom>[];
  bool _searching = false;
  bool _loadingRooms = true;
  bool _roomRefreshRunning = false;
  String? _roomsError;

  String get _gameType => switch (widget.title) {
        'شطرنج آنلاین' => 'chess',
        'دوز' => 'tic_tac_toe',
        'مار و پله' => 'snakes_ladders',
        'تخته نرد' => 'backgammon',
        _ => 'tic_tac_toe',
      };

  int get _maxPlayers => _gameType == 'snakes_ladders' ? 4 : 2;

  @override
  void initState() {
    super.initState();
    appState.addListener(_onSharedStateChanged);
    _refreshRooms();
  }

  void _onSharedStateChanged() {
    if (AppConfig.useSupabase && !_loadingRooms) {
      _refreshRooms(showLoading: false);
    }
  }

  Future<void> _refreshRooms({bool showLoading = true}) async {
    if (_roomRefreshRunning) return;
    _roomRefreshRunning = true;
    if (!AppConfig.useSupabase) {
      if (!mounted) return;
      setState(() {
        _rooms = <_GameRoom>[];
        _loadingRooms = false;
        _roomsError = 'اتاق‌های مشترک به اتصال Staging نیاز دارند.';
        _roomRefreshRunning = false;
      });
      return;
    }
    if (showLoading && mounted) setState(() => _loadingRooms = true);
    try {
      final rows = await PlatformServices.fetchGameRoomsV14(gameType: _gameType);
      if (!mounted) return;
      setState(() {
        _rooms = rows.map(_GameRoom.fromMap).toList();
        _roomsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _roomsError = 'دریافت اتاق‌ها انجام نشد: $error');
    } finally {
      _roomRefreshRunning = false;
      if (mounted) setState(() => _loadingRooms = false);
    }
  }

  @override
  void dispose() {
    appState.removeListener(_onSharedStateChanged);
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
          children: [
            _gameHero(),
            const SizedBox(height: 22),
            _quickActions(context),
            const SizedBox(height: 26),
            _onlinePlayers(),
            const SizedBox(height: 26),
            _roomsHeader(),
            const SizedBox(height: 12),
            if (_loadingRooms) const LinearProgressIndicator(minHeight: 2),
            if (_roomsError != null) _roomMessage(_roomsError!, error: true),
            if (!_loadingRooms && _rooms.isEmpty && _roomsError == null)
              _roomMessage('اتاق عمومی فعالی نیست. می‌توانی اتاق بسازی و کدش را برای دوستت بفرستی.'),
            ..._rooms.map(
              (room) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _roomCard(context, room),
              ),
            ),
            const SizedBox(height: 10),
            _roomMessage('ساخت و عضویت اتاق روی سرور مشترک ثبت می‌شود؛ موتور قوانین و اجرای نوبت‌های بازی هنوز تکمیل نشده است.'),
          ],
        ),
      ),
    );
  }

  Widget _gameHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: PatoghTheme.brandGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: PatoghTheme.purple.withAlpha(50),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ساخت اتاق مشترک و هماهنگی با هم‌پاتوقی‌ها',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heroBadge(
                Icons.sync_rounded,
                'اتاق مشترک',
              ),
              const SizedBox(width: 8),
              _heroBadge(
                Icons.people_alt_rounded,
                'دعوت دوستان',
              ),
              const SizedBox(width: 8),
              _heroBadge(
                Icons.rule_rounded,
                'قوانین در حال تکمیل',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'چطور می‌خوای بازی کنی؟',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.add_circle_rounded,
                title: 'ساخت اتاق',
                subtitle: 'اتاق خودت رو بساز',
                color: PatoghTheme.purple,
                onTap: () => _createRoom(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.login_rounded,
                title: 'ورود با کد',
                subtitle: 'کد دوستت رو وارد کن',
                color: PatoghTheme.teal,
                onTap: () => _showJoinRoomDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _searching ? null : () => _quickMatch(context),
          icon: _searching
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.flash_on_rounded),
          label: Text(
            _searching ? 'در حال پیدا کردن حریف...' : 'بازی سریع',
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(24),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withAlpha(95),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(38),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: PatoghTheme.muted,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onlinePlayers() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: PatoghTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: PatoghTheme.surface2,
            child: Icon(Icons.people_alt_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اتاق‌های مشترک', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${_rooms.length} اتاق عمومی برای این بازی', style: const TextStyle(color: PatoghTheme.muted, fontSize: 10)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _inviteFriend,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
            label: const Text('دعوت'),
          ),
        ],
      ),
    );
  }

  Widget _roomMessage(String text, {bool error = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PatoghTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: error ? Colors.redAccent.withAlpha(120) : PatoghTheme.surface2),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, height: 1.65)),
    );
  }

  Widget _roomsHeader() {
    return Row(
      children: [
        const Expanded(child: Text('اتاق‌های عمومی از سرور', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
        IconButton(
          tooltip: 'به‌روزرسانی',
          onPressed: _loadingRooms ? null : () => _refreshRooms(),
          icon: const Icon(Icons.refresh_rounded, color: PatoghTheme.teal),
        ),
      ],
    );
  }

Widget _roomCard(
  BuildContext context,
  _GameRoom room,
) {
  final isFull = room.players >= room.maxPlayers;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: PatoghTheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: PatoghTheme.surface2,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: PatoghTheme.orange.withAlpha(25),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            widget.icon,
            color: PatoghTheme.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اتاق ${room.host}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.people_alt_rounded,
                    size: 14,
                    color: PatoghTheme.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.players}/${room.maxPlayers} بازیکن • کد ${room.code}',
                    style: const TextStyle(
                      color: PatoghTheme.muted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (room.isPrivate)
                    const Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: PatoghTheme.muted,
                    ),
                ],
              ),
            ],
          ),
        ),
        FilledButton.tonal(
          onPressed: isFull ? null : () => _joinRoom(context, room),
          child: Text(
            isFull ? 'پر' : 'ورود',
          ),
        ),
      ],
    ),
  );
}

Future<void> _createRoom(BuildContext context) async {
  if (!AppConfig.useSupabase) {
    _snack(context, 'برای ساخت اتاق مشترک، نسخه Staging و اتصال سرور لازم است.');
    return;
  }
  try {
    final room = await PlatformServices.createGameRoomV14(
      gameType: _gameType,
      maxPlayers: _maxPlayers,
      isPrivate: false,
    );
    await _refreshRooms();
    if (!context.mounted) return;
    final code = '${room['room_code']}';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('اتاق مشترک ساخته شد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('این کد را برای دوستت بفرست تا به اتاق بپیوندد.'),
            const SizedBox(height: 14),
            SelectableText(code, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
            const SizedBox(height: 12),
            Text(_gameType == 'tic_tac_toe' || _gameType == 'snakes_ladders' ? 'اتاق و نوبت‌های این بازی در Staging ذخیره می‌شوند.' : 'اتاق ساخته می‌شود، اما موتور قوانین این بازی هنوز در دسترس نیست.', style: const TextStyle(fontSize: 11, height: 1.6)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('بستن')),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) _snack(context, 'کد اتاق کپی شد.');
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('کپی کد'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameRoomPlayPage(
          roomCode: code,
          title: widget.title,
          icon: widget.icon,
        ),
      ),
    );
  } catch (error) {
    if (context.mounted) _snack(context, 'ساخت اتاق انجام نشد: $error');
  }
}

void _showJoinRoomDialog(BuildContext context) {
  _roomCodeController.clear();
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('ورود به اتاق'),
      content: TextField(
        controller: _roomCodeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(labelText: 'کد ۶ رقمی اتاق', prefixIcon: Icon(Icons.key_rounded)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('انصراف')),
        FilledButton(
          onPressed: () async {
            final code = _roomCodeController.text.trim();
            if (!RegExp(r'^\d{6}$').hasMatch(code)) {
              _snack(context, 'کد اتاق باید ۶ رقم باشد.');
              return;
            }
            Navigator.of(dialogContext).pop();
            await _joinRoomByCode(context, code);
          },
          child: const Text('ورود'),
        ),
      ],
    ),
  );
}

Future<void> _joinRoom(BuildContext context, _GameRoom room) =>
    _joinRoomByCode(context, room.code);

Future<void> _joinRoomByCode(BuildContext context, String code) async {
  if (!AppConfig.useSupabase) {
    _snack(context, 'برای ورود به اتاق مشترک، نسخه Staging لازم است.');
    return;
  }
  try {
    final room = await PlatformServices.joinGameRoomV14(code);
    await _refreshRooms();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameRoomPlayPage(
          roomCode: code,
          title: widget.title,
          icon: widget.icon,
          gameType: '${room['game_type'] ?? _gameType}',
        ),
      ),
    );
  } catch (error) {
    if (context.mounted) _snack(context, 'ورود به اتاق انجام نشد: $error');
  }
}

Future<void> _quickMatch(BuildContext context) async {
  setState(() => _searching = true);
  try {
    final rooms = await PlatformServices.fetchGameRoomsV14(gameType: _gameType);
    if (!context.mounted) return;
    if (rooms.isEmpty) {
      _snack(context, 'اتاق عمومی آزادی پیدا نشد؛ می‌توانی یک اتاق بسازی.');
      return;
    }
    await _joinRoomByCode(context, '${rooms.first['room_code']}');
  } catch (error) {
    if (context.mounted) _snack(context, 'جست‌وجوی اتاق انجام نشد: $error');
  } finally {
    if (mounted) setState(() => _searching = false);
  }
}

void _inviteFriend() {
  _snack(context, 'برای دعوت دوست، یک اتاق بساز و کد ۶ رقمی آن را کپی کن.');
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
}

class _GameRoom {
  final String id;
  final String code;
  final String host;
  final int players;
  final int maxPlayers;
  final bool isPrivate;

  const _GameRoom({
    required this.id,
    required this.code,
    required this.host,
    required this.players,
    required this.maxPlayers,
    required this.isPrivate,
  });

  factory _GameRoom.fromMap(Map<String, dynamic> map) => _GameRoom(
        id: '${map['id']}',
        code: '${map['room_code'] ?? ''}',
        host: (map['host_name'] as String?) ?? 'کاربر پاتوق',
        players: (map['players'] as num?)?.toInt() ?? 0,
        maxPlayers: (map['max_players'] as num?)?.toInt() ?? 2,
        isPrivate: (map['is_private'] as bool?) ?? false,
      );
}
