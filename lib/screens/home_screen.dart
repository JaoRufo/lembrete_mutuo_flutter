import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/history_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = StorageService();
  final notifier = NotificationService();

  DateTime? selectedDate;
  List<Payment> payments = [];
  late Timer _timer;

  static const _purple = Color(0xFF6C63FF);
  static const _pink = Color(0xFFFF6584);
  // static const _orange = Color(0xFFFFB347);
  static const _bg = Color(0xFF0F0F1A);
  static const _card = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    loadData();
    notifier.init();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    payments = await storage.getPayments();
    setState(() {});
  }

  DateTime? getNextPayment() {
    if (payments.isEmpty) return null;
    final last = payments.last.date;
    return DateTime(last.year, last.month + 2, last.day);
  }

  Duration? getRemaining() {
    final next = getNextPayment();
    if (next == null) return null;
    final diff = next.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<void> registerPayment() async {
    if (selectedDate == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar pagamento',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Registrar pagamento em ${DateFormat('dd/MM/yyyy').format(selectedDate!)}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    payments.add(Payment(date: selectedDate!));
    await storage.savePayments(payments);
    final nextDate = DateTime(
      selectedDate!.year,
      selectedDate!.month + 2,
      selectedDate!.day,
    );
    await notifier.scheduleNotifications(nextDate);
    setState(() => selectedDate = null);
  }

  Future<void> deletePayment(int index) async {
    payments.removeAt(index);
    await storage.savePayments(payments);
    final next = getNextPayment();
    if (next != null) await notifier.scheduleNotifications(next);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final next = getNextPayment();
    final remaining = getRemaining();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildCountdownCard(remaining, next),
              const SizedBox(height: 20),
              _buildRegisterCard(),
              const SizedBox(height: 12),
              _buildHistoryButton(),
              const SizedBox(height: 12),
              // _buildTestNotificationsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset(
          'lib/assets/logo-lembrete-mutuo-new.png',
          height: 48,
          errorBuilder: (ctx, err, stack) =>
              const Icon(Icons.monetization_on, color: _purple, size: 48),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lembrete Mútuo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Controle de pagamentos',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountdownCard(Duration? remaining, DateTime? next) {
    final days = remaining?.inDays ?? 0;
    final hours = remaining != null ? remaining.inHours % 24 : 0;
    final minutes = remaining != null ? remaining.inMinutes % 60 : 0;
    final seconds = remaining != null ? remaining.inSeconds % 60 : 0;

    final isUrgent = remaining != null && days <= 7;
    final accentColor = isUrgent ? _pink : _purple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _card,
            isUrgent ? const Color(0xFF2A1A2E) : const Color(0xFF1A1A3E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            remaining == null
                ? 'Nenhum pagamento registrado'
                : days == 0 && remaining == Duration.zero
                ? '⚠️ Vencimento hoje!'
                : 'Próximo vencimento em',
            style: TextStyle(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          if (remaining != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _timeUnit(days.toString().padLeft(2, '0'), 'DIAS', accentColor),
                _timeSeparator(accentColor),
                _timeUnit(
                  hours.toString().padLeft(2, '0'),
                  'HORAS',
                  accentColor,
                ),
                _timeSeparator(accentColor),
                _timeUnit(
                  minutes.toString().padLeft(2, '0'),
                  'MIN',
                  accentColor,
                ),
                _timeSeparator(accentColor),
                _timeUnit(
                  seconds.toString().padLeft(2, '0'),
                  'SEG',
                  accentColor,
                ),
              ],
            )
          else
            const Icon(Icons.hourglass_empty, color: Colors.white24, size: 48),
          if (next != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Vence em ${DateFormat('dd/MM/yyyy').format(next)}',
                style: TextStyle(color: accentColor, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeUnit(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 10, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _timeSeparator(Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrar Pagamento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(primary: _purple),
                  ),
                  child: child!,
                ),
              );
              if (date != null) setState(() => selectedDate = date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _purple.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: _purple, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                        : 'Selecionar data do pagamento',
                    style: TextStyle(
                      color: selectedDate != null
                          ? Colors.white
                          : Colors.white38,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedDate != null ? registerPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                disabledBackgroundColor: _purple.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmar Pagamento',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => showDialog(
          context: context,
          builder: (_) =>
              HistoryModal(payments: payments, onDelete: deletePayment),
        ),
        icon: const Icon(Icons.history, color: _purple),
        label: const Text('Ver Histórico', style: TextStyle(color: _purple)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _purple),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Widget _buildTestNotificationsButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: OutlinedButton.icon(
  //       onPressed: () async {
  //         await notifier.requestExactAlarmPermission();
  //         await notifier.scheduleTestNotifications();
  //         if (!mounted) return;
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('3 notificações agendadas: 10s, 20s e 30s'),
  //             backgroundColor: Color(0xFF1A1A2E),
  //           ),
  //         );
  //       },
  //       icon: const Icon(Icons.notifications_active, color: _orange),
  //       label: const Text(
  //         'Testar Notificações',
  //         style: TextStyle(color: _orange),
  //       ),
  //       style: OutlinedButton.styleFrom(
  //         side: const BorderSide(color: _orange),
  //         padding: const EdgeInsets.symmetric(vertical: 14),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
