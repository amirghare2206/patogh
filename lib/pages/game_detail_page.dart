import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

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

  bool _searching = false;

  final List<_GameRoom> _rooms = [
    const _GameRoom(
      code: '248731',
      host: 'علی',
      players: 1,
      maxPlayers: 2,
      isPrivate: false,
    ),
    const _GameRoom(
      code: '731924',
      host: 'سارا',
      players: 1,
      maxPlayers: 2,
      isPrivate: false,
    ),
    const _GameRoom(
      code: '519842',
      host: 'امیر',
      players: 2,
      maxPlayers: 4,
      isPrivate: false,
    ),
  ];

  @override
  void dispose() {
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
            ..._rooms.map(
              (room) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _roomCard(context, room),
              ),
            ),
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
            'رقابت آنلاین با دوستان و هم‌پاتوقی‌ها',
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
                Icons.wifi_rounded,
                'آنلاین',
              ),
              const SizedBox(width: 8),
              _heroBadge(
                Icons.people_alt_rounded,
                'چندنفره',
              ),
              const SizedBox(width: 8),
              _heroBadge(
                Icons.emoji_events_rounded,
                'رقابتی',
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
          Stack(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: PatoghTheme.surface2,
                child: Icon(Icons.people_alt_rounded),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: PatoghTheme.teal,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PatoghTheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بازیکنان آنلاین',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '۱۲ هم‌پاتوقی آماده بازی هستند',
                  style: TextStyle(
                    color: PatoghTheme.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _inviteFriend,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 17,
            ),
            label: const Text('دعوت'),
          ),
        ],
      ),
    );
  }

  Widget _roomsHeader() {
  return const Row(
    children: [
      Expanded(
        child: Text(
          'اتاق‌های فعال',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      Icon(
        Icons.radio_button_checked_rounded,
        color: PatoghTheme.teal,
        size: 17,
      ),
      SizedBox(width: 5),
      Text(
        'زنده',
        style: TextStyle(
          color: PatoghTheme.teal,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
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
                    '${room.players}/${room.maxPlayers} بازیکن',
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

void _createRoom(BuildContext context) {
  final code =
      (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

  setState(() {
    _rooms.insert(
      0,
      _GameRoom(
        code: code,
        host: 'من',
        players: 1,
        maxPlayers: widget.title == 'مار و پله' ? 4 : 2,
        isPrivate: true,
      ),
    );
  });

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'اتاق ساخته شد 🎮',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'این کد رو برای دوستت بفرست:',
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PatoghTheme.surface2,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('بستن'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _inviteFriend();
            },
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('دعوت دوست'),
          ),
        ],
      );
    },
  );
}

void _showJoinRoomDialog(BuildContext context) {
  _roomCodeController.clear();

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'ورود به اتاق',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: TextField(
          controller: _roomCodeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'کد ۶ رقمی اتاق',
            prefixIcon: Icon(Icons.key_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final code = _roomCodeController.text.trim();

              if (code.length != 6) {
                return;
              }

              Navigator.of(dialogContext).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'در حال ورود به اتاق $code...',
                  ),
                ),
              );
            },
            child: const Text('ورود'),
          ),
        ],
      );
    },
  );
}

void _joinRoom(
  BuildContext context,
  _GameRoom room,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'در حال ورود به اتاق ${room.host}...',
      ),
    ),
  );
}

Future<void> _quickMatch(BuildContext context) async {
  setState(() {
    _searching = true;
  });

  await Future<void>.delayed(
    const Duration(milliseconds: 1200),
  );

if (!context.mounted) return;
  setState(() {
    _searching = false;
  });

  final availableRooms = _rooms
      .where(
        (room) => !room.isPrivate && room.players < room.maxPlayers,
      )
      .toList();

  if (availableRooms.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'فعلاً حریف آزادی پیدا نشد.',
        ),
      ),
    );
    return;
  }

  _joinRoom(
    context,
    availableRooms.first,
  );
}

void _inviteFriend() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'بخش دعوت هم‌پاتوقی در مرحله اتصال به سیستم اجتماعی فعال می‌شود.',
      ),
    ),
  );
}
}

class _GameRoom {
  final String code;
  final String host;
  final int players;
  final int maxPlayers;
  final bool isPrivate;

  const _GameRoom({
    required this.code,
    required this.host,
    required this.players,
    required this.maxPlayers,
    required this.isPrivate,
  });
}