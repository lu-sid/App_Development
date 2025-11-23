import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/subscription_model.dart';
import '../../../services/subscription_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';

const _accentRed = Color(0xFFE50914);

class AddSubscriptionScreen extends StatefulWidget {
  final SubscriptionModel? existingSub;
  const AddSubscriptionScreen({super.key, this.existingSub});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _selectedCategory = 'Entertainment';

  String _selectedReminder = "On billing day";
  final reminderOptions = [
    "No reminder",
    "On billing day",
    "1 day before",
    "3 days before",
    "7 days before"
  ];

  final _formKey = GlobalKey<FormState>();
  final _service = SubscriptionService();
  final categories = ["Entertainment", "Education", "Productivity", "Other"];

  @override
  void initState() {
    super.initState();
    if (widget.existingSub != null) {
      _nameCtrl.text = widget.existingSub!.name;
      _priceCtrl.text = widget.existingSub!.price.toString();
      _dateCtrl.text = widget.existingSub!.date;
      _selectedCategory = widget.existingSub!.category;
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      _dateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
      setState(() {});
    }
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    final userData = await AuthService().getUserData();
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in again.")),
      );
      return;
    }

    final count = await _service.getSubscriptionCount();
    if (!userData['isPremium'] && count >= 2 && widget.existingSub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          margin: EdgeInsets.all(16),
          behavior: SnackBarBehavior.floating,
          content: Text("Upgrade to Premium to add more than 2 subscriptions!"),
        ),
      );
      return;
    }

    final sub = SubscriptionModel(
      id: widget.existingSub?.id,
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
      date: _dateCtrl.text.trim(),
      category: _selectedCategory,
      reminder: _selectedReminder,
    );

    try {
      if (widget.existingSub == null) {
        await _service.addSubscription(sub);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subscription added successfully!")),
        );
      } else {
        await _service.updateSubscription(sub);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subscription updated successfully!")),
        );
      }

      if (_selectedReminder != "No reminder" && _dateCtrl.text.isNotEmpty) {
        DateTime billingDate = _convertToDate(_dateCtrl.text);

        switch (_selectedReminder) {
          case "1 day before":
            billingDate = billingDate.subtract(const Duration(days: 1));
            break;
          case "3 days before":
            billingDate = billingDate.subtract(const Duration(days: 3));
            break;
          case "7 days before":
            billingDate = billingDate.subtract(const Duration(days: 7));
            break;
        }

        if (billingDate.isBefore(DateTime.now())) {
          billingDate = DateTime.now().add(const Duration(minutes: 1));
        }

        await NotificationService.scheduleReminder(
          title: "Subscription Reminder",
          body: "${_nameCtrl.text} subscription is due soon.",
          scheduled: billingDate,
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving subscription: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: isDark
          ? const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF31005F), Color(0xFF0B071D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            )
          : null,
      child: Scaffold(
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _mainCard(isDark),
                          const SizedBox(height: 28),
                          _saveButton(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final isEditing = widget.existingSub != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? Colors.black.withOpacity(0.45) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.15) : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Colors.red),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? "Edit Subscription" : "Add Subscription",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    isEditing
                        ? "Update your recurring bill details"
                        : "Track a new recurring expense",
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.subscriptions_outlined,
                color: _accentRed, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _mainCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.18) : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          _buildField(_nameCtrl, "Subscription Name", Icons.subscriptions_outlined, isDark),
          _buildField(_priceCtrl, "Price", Icons.currency_rupee_rounded, isDark, number: true),
          _buildField(_dateCtrl, "Billing Date", Icons.calendar_month_rounded, isDark,
              readOnly: true, onTap: _pickDate),
          if (_dateCtrl.text.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Next charge on ${_dateCtrl.text}",
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          const SizedBox(height: 18),
          _sectionLabel("Category", isDark),
          const SizedBox(height: 10),
          _categoryRow(isDark),
          const SizedBox(height: 22),
          _sectionLabel("Reminder", isDark),
          const SizedBox(height: 8),
          _reminderDropdown(isDark),
        ],
      ),
    );
  }

  Widget _categoryRow(bool isDark) {
    final Map<String, IconData> categoryIcons = {
      "Entertainment": Icons.tv_rounded,
      "Education": Icons.school_rounded,
      "Productivity": Icons.work_history_rounded,
      "Other": Icons.more_horiz_rounded,
    };

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: categories.map((cat) {
        final bool selected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected
                  ? _accentRed
                  : isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoryIcons[cat], size: 18,
                    color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black54)),
                const SizedBox(width: 6),
                Text(
                  cat,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _reminderDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedReminder,
      dropdownColor: isDark ? const Color(0xFF1B1027) : Colors.white,
      items: reminderOptions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => _selectedReminder = v!),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.black.withOpacity(0.35) : Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: isDark ? Colors.white70 : Colors.black54),
      style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black),
    );
  }

  Widget _saveButton(bool isDark) {
    final isEditing = widget.existingSub != null;
    return BounceInUp(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentRed,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _saveSubscription,
        child: Text(
          isEditing ? "Update Subscription" : "Save Subscription",
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.8),
        ),
      ),
    );
  }

  DateTime _convertToDate(String d) {
    final parts = d.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]), 10);
  }
}
  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData icon,
      bool isDark, {
        bool number = false,
        bool readOnly = false,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: number ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          if (number && double.tryParse(value.trim()) == null) {
            return "Please enter a valid number";
          }
          return null;
        },
        style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
          filled: true,
          fillColor: isDark ? Colors.black.withOpacity(0.35) : Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }