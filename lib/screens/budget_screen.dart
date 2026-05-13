import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/lifetrack_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});
  static final _fmt = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LifeTrackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          Text(DateFormat('MMMM yyyy').format(now), style: TextStyle(
            fontSize: 13, color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
          const SizedBox(height: 2),
          Text('Budget', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827))),
          const SizedBox(height: 20),

          // Balance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: p.monthBalance >= 0
                    ? [const Color(0xFF059669), const Color(0xFF10b981)]
                    : [const Color(0xFFdc2626), const Color(0xFFef4444)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Net Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text(_fmt.format(p.monthBalance), style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(DateFormat('MMMM yyyy').format(now),
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: _StatCard(label: 'Income', amount: p.monthIncome,
                color: const Color(0xFF10b981), icon: Icons.arrow_downward_rounded,
                isDark: isDark, fmt: _fmt)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(label: 'Expenses', amount: p.monthExpenses,
                color: const Color(0xFFef4444), icon: Icons.arrow_upward_rounded,
                isDark: isDark, fmt: _fmt)),
          ]),
          const SizedBox(height: 24),

          if (p.expensesByCategory.isNotEmpty) ...[
            _SectionLabel(label: 'SPENDING BY CATEGORY', isDark: isDark),
            const SizedBox(height: 12),
            _CategoryChart(provider: p, isDark: isDark, fmt: _fmt),
            const SizedBox(height: 24),
          ],

          _SectionLabel(label: 'TRANSACTIONS', isDark: isDark),
          const SizedBox(height: 12),

          if (p.transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No transactions yet', style: TextStyle(
                color: isDark ? const Color(0xFF4b5563) : const Color(0xFF9ca3af)))),
            )
          else
            ...p.transactions.take(10).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TxnTile(
                txn: t, isDark: isDark, fmt: _fmt,
                onEdit: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AddTransactionScreen(transaction: t))),
                onDelete: () => p.deleteTransaction(t.id),
              ),
            )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label; final double amount; final Color color;
  final IconData icon; final bool isDark; final NumberFormat fmt;
  const _StatCard({required this.label, required this.amount, required this.color,
      required this.icon, required this.isDark, required this.fmt});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb)),
    ),
    child: Row(children: [
      Container(width: 34, height: 34,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10,
            color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
        Text(fmt.format(amount), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111827))),
      ])),
    ]),
  );
}

class _CategoryChart extends StatelessWidget {
  final LifeTrackProvider provider; final bool isDark; final NumberFormat fmt;
  const _CategoryChart({required this.provider, required this.isDark, required this.fmt});

  static const _colors = [
    Color(0xFF10b981), Color(0xFF3b82f6), Color(0xFFf59e0b),
    Color(0xFFef4444), Color(0xFF8b5cf6), Color(0xFFec4899), Color(0xFF6b7280),
  ];

  @override
  Widget build(BuildContext context) {
    final cats = provider.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = cats.fold(0.0, (s, e) => s + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb)),
      ),
      child: Row(children: [
        SizedBox(width: 110, height: 110, child: PieChart(PieChartData(
          sectionsSpace: 2, centerSpaceRadius: 28,
          sections: List.generate(cats.length, (i) {
            final pct = cats[i].value / total;
            return PieChartSectionData(
              value: cats[i].value, color: _colors[i % _colors.length], radius: 38,
              title: pct > 0.1 ? '${(pct * 100).round()}%' : '',
              titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
            );
          }),
        ))),
        const SizedBox(width: 14),
        Expanded(child: Column(children: List.generate(cats.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: _colors[i % _colors.length], shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Expanded(child: Text(cats[i].key.label, style: TextStyle(fontSize: 11,
                color: isDark ? const Color(0xFF9ca3af) : const Color(0xFF6b7280)),
                overflow: TextOverflow.ellipsis)),
            Text(fmt.format(cats[i].value), style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111827))),
          ]),
        )))),
      ]),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final Transaction txn; final bool isDark; final NumberFormat fmt;
  final VoidCallback onEdit, onDelete;
  const _TxnTile({required this.txn, required this.isDark, required this.fmt,
      required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    return GestureDetector(
      onLongPress: () => showModalBottomSheet(context: context,
          builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit'),
                onTap: () { Navigator.pop(context); onEdit(); }),
            ListTile(leading: const Icon(Icons.delete_outline, color: Color(0xFFef4444)),
                title: const Text('Delete', style: TextStyle(color: Color(0xFFef4444))),
                onTap: () { Navigator.pop(context); onDelete(); }),
          ]))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb)),
        ),
        child: Row(children: [
          Text(txn.category.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(txn.note.isNotEmpty ? txn.note : txn.category.label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF111827))),
            Text('${txn.category.label} · ${DateFormat('MMM d').format(txn.date)}',
                style: TextStyle(fontSize: 11,
                    color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
          ])),
          Text('${isIncome ? '+' : '-'}${fmt.format(txn.amount)}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isIncome ? const Color(0xFF10b981) : const Color(0xFFef4444))),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label; final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});
  @override
  Widget build(BuildContext context) => Text(label, style: TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8,
    color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
  ));
}
