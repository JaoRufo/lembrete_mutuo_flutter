import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';

class HistoryModal extends StatefulWidget {
  final List<Payment> payments;
  final Future<void> Function(int index) onDelete;

  const HistoryModal({super.key, required this.payments, required this.onDelete});

  @override
  State<HistoryModal> createState() => _HistoryModalState();
}

class _HistoryModalState extends State<HistoryModal> {
  int page = 0;
  static const pageSize = 10;
  static const _purple = Color(0xFF6C63FF);
  static const _card = Color(0xFF1A1A2E);

  late List<Payment> _payments;

  @override
  void initState() {
    super.initState();
    _payments = List.from(widget.payments);
  }

  Future<void> _delete(int itemIndex) async {
    final originalIndex = _payments.length - 1 - (page * pageSize + itemIndex);
    await widget.onDelete(originalIndex);
    setState(() {
      _payments.removeAt(originalIndex);
      final totalPages = (_payments.length / pageSize).ceil();
      if (page > 0 && page >= totalPages) page--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reversed = _payments.reversed.toList();
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, reversed.length);
    final items = reversed.sublist(start, end);
    final totalPages = (_payments.isEmpty ? 1 : (_payments.length / pageSize).ceil());

    return Dialog(
      backgroundColor: const Color(0xFF0F0F1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.history, color: _purple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Histórico de Pagamentos',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista com altura máxima para não estourar a tela
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhum pagamento registrado', style: TextStyle(color: Colors.white38)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final globalNumber = start + i + 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _purple.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _purple.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$globalNumber',
                              style: const TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(items[i].date),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _delete(i),
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Excluir',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Paginação
            if (totalPages > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: page > 0 ? () => setState(() => page--) : null,
                    icon: const Icon(Icons.chevron_left),
                    color: _purple,
                    disabledColor: Colors.white12,
                  ),
                  Text(
                    '${page + 1} / $totalPages',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  IconButton(
                    onPressed: page < totalPages - 1 ? () => setState(() => page++) : null,
                    icon: const Icon(Icons.chevron_right),
                    color: _purple,
                    disabledColor: Colors.white12,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
