import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../services/subscription_service.dart';
import '../../models/subscription_model.dart';
import '../../services/budget_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _service = SubscriptionService();
  final _budgetService = BudgetService();

  // Shared muted colors for charts
  final List<Color> _pieColors = const [
    Color(0xff4e79a7),
    Color(0xffe15759),
    Color(0xff76b7b2),
    Color(0xfff28e2b),
    Color(0xff59a14f),
    Color(0xff9e75b7),
    Color(0xffedc948),
    Color(0xffbab0ac),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Analytics",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<SubscriptionModel>>(
        stream: _service.getSubscriptions(),
        builder: (context, snapSubs) {
          if (!snapSubs.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final subs = snapSubs.data!;
          if (subs.isEmpty) return _emptyState();

          return StreamBuilder<Map<String, double>>(
            stream: _budgetService.getBudgetsStream(),
            builder: (context, snapBudgets) {
              final budgets = snapBudgets.data ?? {};

              final now = DateTime.now();
              final lastMonth = DateTime(now.year, now.month - 1, 1);

              double totalCurrent = 0;
              double totalLast = 0;
              final Map<String, double> categoryTotals = {};
              final Map<int, double> dayTotals = {};

              // Build all analytics from subs
              for (var s in subs) {
                final d = _parseDate(s.date);

                // Current month totals
                if (_isSameMonth(d, now)) {
                  totalCurrent += s.price;
                  categoryTotals[s.category] =
                      (categoryTotals[s.category] ?? 0) + s.price;
                  dayTotals[d.day] = (dayTotals[d.day] ?? 0) + s.price;
                }

                // Last month total
                if (_isSameMonth(d, lastMonth)) {
                  totalLast += s.price;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                child: Column(
                  children: [
                    _headerCard(totalCurrent),
                    const SizedBox(height: 24),

                    if (dayTotals.isNotEmpty) ...[
                      _section("Spending trend this month"),
                      _trendCard(dayTotals),
                      const SizedBox(height: 24),
                    ],

                    _section("Spending by category"),
                    _pieCard(categoryTotals),
                    const SizedBox(height: 24),

                    _section("Month-to-month comparison"),
                    _monthComparisonCard(
                      totalCurrent,
                      totalLast,
                      now,
                      lastMonth,
                    ),
                    const SizedBox(height: 24),

                    _section("Budgets"),
                    ...categoryTotals.entries.map((e) => _budgetTile(
                          category: e.key,
                          spending: e.value,
                          budget: budgets[e.key],
                        )),

                    const SizedBox(height: 26),

                    _section("Export"),
                    _exportButton(subs, totalCurrent, categoryTotals),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ========== BASIC UI ==========

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_graph_rounded,
                size: 110, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            Text(
              "No Analytics Yet",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              "Add subscriptions to view spending insights ✨",
              style:
                  GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );

  Widget _headerCard(double total) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 6),
              color: Colors.red.withOpacity(.38),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total this month",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.white.withOpacity(.8)),
            ),
            const SizedBox(height: 6),
            Text(
              "₹${total.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  Widget _section(String title) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      );

  // ========== TREND LINE CHART (2) ==========

  Widget _trendCard(Map<int, double> dayTotals) {
    final spots = dayTotals.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final maxY = spots.isEmpty
        ? 1.0
        : (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.25),
                strokeWidth: 0.6,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.18),
                strokeWidth: 0.5,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    "₹${value.toInt()}",
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: Colors.red.shade600,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade600.withOpacity(0.28),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== PIE CHART + LEGEND (CATEGORY) ==========

  Widget _pieCard(Map<String, double> totals) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(.08),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 45,
                sectionsSpace: 2,
                sections: _buildPieSections(totals),
              ),
              swapAnimationDuration:
                  const Duration(milliseconds: 800), // (4) animation
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 12),
          _pieLegend(totals),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<String, double> totals) {
    final totalVal = totals.values.fold(0.0, (a, b) => a + b);

    return List.generate(totals.length, (i) {
      final key = totals.keys.elementAt(i);
      final value = totals[key]!;
      final pct = totalVal == 0 ? 0 : (value / totalVal * 100);

      return PieChartSectionData(
        color: _pieColors[i % _pieColors.length],
        radius: 80,
        value: value,
        title: "${pct.toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _pieLegend(Map<String, double> totals) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(totals.length, (i) {
        final key = totals.keys.elementAt(i);
        final color = _pieColors[i % _pieColors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _categoryIcon(key),
              size: 16,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              key,
              style: GoogleFonts.poppins(fontSize: 12.5),
            ),
          ],
        );
      }),
    );
  }

  // ========== MONTH-TO-MONTH BAR GRAPH (1) ==========

  Widget _monthComparisonCard(
    double current,
    double last,
    DateTime now,
    DateTime lastMonth,
  ) {
    final theme = Theme.of(context);
    final maxYBase = (current > last ? current : last);
    final maxY = maxYBase == 0 ? 1.0 : maxYBase * 1.3;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: last,
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: current,
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.red.shade500,
                  ),
                ],
              ),
            ],
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 0.5,
              ),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) => Text(
                    "₹${value.toInt()}",
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return Text(
                          DateFormat.MMM().format(lastMonth),
                          style: const TextStyle(fontSize: 11),
                        );
                      case 1:
                        return Text(
                          DateFormat.MMM().format(now),
                          style: const TextStyle(fontSize: 11),
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 700),
          swapAnimationCurve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  // ========== BUDGET TILE (+ delete + suggestion 5 & 6 & 7) ==========

  Widget _budgetTile({
    required String category,
    required double spending,
    required double? budget,
  }) {
    final theme = Theme.of(context);
    double pct;
    if (budget == null || budget == 0) {
      pct = 0;
    } else {
      pct = (spending / budget).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(.07),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // (7) Category icon in list
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _categoryIcon(category),
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                (budget == null || budget == 0)
                    ? "No budget"
                    : "₹${spending.toStringAsFixed(0)} / ₹${budget.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    _editBudgetDialog(category, budget, spending),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0, end: pct.toDouble()),
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 9,
                backgroundColor: Colors.grey.shade300,
                color:
                    value < .8 ? Colors.green : value < 1 ? Colors.orange : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog with suggestion + delete button
  Future<void> _editBudgetDialog(
      String category, double? current, double currentSpending) async {
    final controller = TextEditingController(
      text: current != null && current != 0
          ? current.toStringAsFixed(0)
          : "",
    );

    final suggested = currentSpending; // (6) auto-suggest

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Budget for $category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "₹ Enter monthly budget amount",
              ),
            ),
            const SizedBox(height: 8),
            if (suggested > 0) ...[
              Text(
                "Suggested: ₹${suggested.toStringAsFixed(0)} "
                "based on your current spending.",
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade700),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    controller.text = suggested.toStringAsFixed(0);
                  },
                  child: const Text("Use suggestion"),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // (5) Delete / clear budget button
          TextButton(
            onPressed: () async {
              // treat as delete: set to 0
              await _budgetService.setBudget(category, 0);
              Navigator.pop(context);
            },
            child: const Text(
              "Clear budget",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = double.tryParse(controller.text);
              if (v != null) {
                await _budgetService.setBudget(category, v);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ========== EXPORT BUTTON & PDF ==========

  Widget _exportButton(
      List<SubscriptionModel> subs, double total, Map<String, double> totals) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.picture_as_pdf_rounded),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.red.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      label: Text(
        "Export Analytics PDF",
        style:
            GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      onPressed: () => _exportPdf(subs, total, totals),
    );
  }

  Future<void> _exportPdf(
    List<SubscriptionModel> subs,
    double total,
    Map<String, double> totals,
  ) async {
    final font = pw.Font.helvetica();
    final bold = pw.Font.helveticaBold();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: bold),
        build: (_) => [
          pw.Text(
            "SubTrack Analytics",
            style:
                pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            "Generated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            "Total this month: ₹${total.toStringAsFixed(2)}",
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            "Spending by category",
            style:
                pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ["Category", "Amount (₹)"],
            data: totals.entries
                .map((e) => [e.key, e.value.toStringAsFixed(2)])
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Subscriptions",
            style:
                pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ["Name", "Price", "Category", "Date"],
            data: subs
                .map(
                  (s) => [
                    s.name,
                    "₹${s.price.toStringAsFixed(2)}",
                    s.category,
                    s.date,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ========== HELPERS ==========

  DateTime _parseDate(String raw) {
    try {
      final parts = raw.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  IconData _categoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('entertainment')) return Icons.movie;
    if (c.contains('edu')) return Icons.school;
    if (c.contains('productivity')) return Icons.task_alt;
    if (c.contains('music')) return Icons.music_note;
    if (c.contains('game')) return Icons.sports_esports;
    return Icons.category;
  }
}
