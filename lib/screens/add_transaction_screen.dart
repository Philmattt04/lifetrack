import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/lifetrack_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  BudgetCategory _category = BudgetCategory.food;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _amountCtrl.text = t.amount.toStringAsFixed(2);
      _noteCtrl.text = t.note;
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
  }

  @override
  void dispose() { _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    final p = context.read<LifeTrackProvider>();
    if (_isEditing) {
      p.updateTransaction(widget.transaction!.copyWith(
          type: _type, amount: amount, category: _category,
          note: _noteCtrl.text.trim(), date: _date));
    } else {
      p.addTransaction(p.buildTransaction(
          type: _type, amount: amount, category: _category,
          note: _noteCtrl.text.trim(), date: _date));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction'),
        actions: [TextButton(
          onPressed: _save,
          child: const Text('Save', style: TextStyle(color: Color(0xFF10b981), fontWeight: FontWeight.w600)),
        )],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _Lbl(text: 'TYPE', isDark: isDark),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _TypeBtn(label: 'Expense', icon: Icons.arrow_upward_rounded,
              color: const Color(0xFFef4444), selected: _type == TransactionType.expense,
              isDark: isDark, onTap: () => setState(() => _type = TransactionType.expense))),
          const SizedBox(width: 10),
          Expanded(child: _TypeBtn(label: 'Income', icon: Icons.arrow_downward_rounded,
              color: const Color(0xFF10b981), selected: _type == TransactionType.income,
              isDark: isDark, onTap: () => setState(() => _type = TransactionType.income))),
        ]),
        const SizedBox(height: 20),
        _Lbl(text: 'AMOUNT', isDark: isDark),
        const SizedBox(height: 8),
        TextField(
          controller: _amountCtrl, autofocus: !_isEditing,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ', hintText: '0.00',
            filled: true, fillColor: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        _Lbl(text: 'CATEGORY', isDark: isDark),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8,
          children: BudgetCategory.values.map((c) {
            final sel = c == _category;
            return GestureDetector(
              onTap: () => setState(() => _category = c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF10b981).withValues(alpha: 0.12)
                      : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel
                      ? const Color(0xFF10b981).withValues(alpha: 0.5)
                      : isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(c.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(c.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: sel ? const Color(0xFF10b981)
                          : isDark ? const Color(0xFF9ca3af) : const Color(0xFF6b7280))),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _Lbl(text: 'NOTE (OPTIONAL)', isDark: isDark),
        const SizedBox(height: 8),
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(
            hintText: 'e.g. Grocery run',
            filled: true, fillColor: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ]),
    );
  }
}

class _Lbl extends StatelessWidget {
  final String text; final bool isDark;
  const _Lbl({required this.text, required this.isDark});
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8,
    color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
  ));
}

class _TypeBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  final bool selected, isDark; final VoidCallback onTap;
  const _TypeBtn({required this.label, required this.icon, required this.color,
      required this.selected, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: color.withValues(alpha: 0.5)) : null,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: selected ? color : isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
            color: selected ? color : isDark ? const Color(0xFFd1d5db) : const Color(0xFF374151))),
      ]),
    ),
  );
}
