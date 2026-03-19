import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;

/// Works well for the selected date background
class PremiumCalendarDialog extends StatefulWidget {
  const PremiumCalendarDialog({
    super.key,
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<PremiumCalendarDialog> createState() => _PremiumCalendarDialogState();
}

class _PremiumCalendarDialogState extends State<PremiumCalendarDialog> {
  late DateTime _selected;
  late DateTime _viewMonth; // the month currently displayed

  static const String fontMono = 'Basier Square Mono';
  static const String fontBody = 'Arbeit';

  static const List<String> _months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];
  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _viewMonth = DateTime(widget.initial.year, widget.initial.month);
  }

  void _prevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
    });
  }

  bool _canGoPrev() {
    final prev = DateTime(_viewMonth.year, _viewMonth.month - 1);
    return !prev.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  bool _canGoNext() {
    final next = DateTime(_viewMonth.year, _viewMonth.month + 1);
    return !next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  void _close() => Navigator.of(context).pop();
  void _apply() => Navigator.of(context).pop(_selected);

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isWithinRange(DateTime value) {
    final date = _dateOnly(value);
    final first = _dateOnly(widget.firstDate);
    final last = _dateOnly(widget.lastDate);
    return !date.isBefore(first) && !date.isAfter(last);
  }

  DateTime _copyWithClampedDay(int year, int month, int day) {
    final maxDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, maxDay));
  }

  Future<void> _openYearPicker() async {
    final years = List<int>.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.lastDate.year - index,
    );

    final selectedYear = await showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss year picker',
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: Center(
              child: _YearPickerSheet(
                years: years,
                selectedYear: _viewMonth.year,
              ),
            ),
          ),
        );
      },
    );

    if (selectedYear == null || !mounted) return;

    setState(() {
      final nextViewMonth = DateTime(selectedYear, _viewMonth.month);
      _viewMonth = nextViewMonth;

      final candidate = _copyWithClampedDay(
        selectedYear,
        _selected.month,
        _selected.day,
      );
      if (_isWithinRange(candidate)) {
        _selected = candidate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 50,
            spreadRadius: -10,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomHeader(),
          _buildMonthNav(),
          _buildWeekdayLabels(),
          _buildDayGrid(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    final month = _months[_selected.month - 1];
    final day = _selected.day.toString().padLeft(2, '0');
    final year = _selected.year;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 4, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                'SELECTED DATE',
                style: TextStyle(
                  fontFamily: fontMono,
                  fontSize: 9,
                  letterSpacing: 3.0,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontFamily: fontBody,
                  fontSize: 72,
                  height: 0.8,
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                  letterSpacing: -2.0,
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month,
                      style: const TextStyle(
                        fontFamily: fontMono,
                        fontSize: 14,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$year',
                      style: TextStyle(
                        fontFamily: fontMono,
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            _months[_viewMonth.month - 1],
            style: const TextStyle(
              fontFamily: fontMono,
              fontSize: 12,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _openYearPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    '${_viewMonth.year}',
                    style: const TextStyle(
                      fontFamily: fontMono,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _NavArrow(
            icon: Icons.chevron_left,
            enabled: _canGoPrev(),
            onTap: _prevMonth,
          ),
          const SizedBox(width: 8),
          _NavArrow(
            icon: Icons.chevron_right,
            enabled: _canGoNext(),
            onTap: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children:
            _weekdays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontFamily: fontMono,
                      fontSize: 10,
                      letterSpacing: 2.0,
                      color: Colors.black45,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDayGrid() {
    final firstOfMonth = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final startWeekday = firstOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;

    final List<Widget> cells = [];

    // Leading empty cells
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_viewMonth.year, _viewMonth.month, day);
      final isSelected =
          date.year == _selected.year &&
          date.month == _selected.month &&
          date.day == _selected.day;
      final isDisabled =
          date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

      cells.add(
        _DayCell(
          day: day,
          isSelected: isSelected,
          isDisabled: isDisabled,
          onTap:
              isDisabled
                  ? null
                  : () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = date);
                  },
        ),
      );
    }

    while (cells.length < 42) {
      cells.add(const SizedBox());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: 288,
        child: GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2,
          crossAxisSpacing: 0,
          childAspectRatio: 1.0,
          children: cells,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _close,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black38,
              splashFactory: NoSplash.splashFactory,
              textStyle: const TextStyle(
                fontFamily: fontMono,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: _apply,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              textStyle: const TextStyle(
                fontFamily: fontMono,
                fontSize: 11,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────────

class _YearPickerSheet extends StatelessWidget {
  const _YearPickerSheet({
    required this.years,
    required this.selectedYear,
  });

  final List<int> years;
  final int selectedYear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: -8,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: SizedBox(
            height: 332,
            child: Column(
              children: [
                const SizedBox(height: 18),
                const Text(
                  'SELECT YEAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _PremiumCalendarDialogState.fontMono,
                    fontSize: 10,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.68,
                    ),
                    itemCount: years.length,
                    itemBuilder: (context, index) {
                      final year = years[index];
                      final isSelected = year == selectedYear;

                      return _YearPickerSheetItem(
                        year: year,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop(year);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YearPickerSheetItem extends StatelessWidget {
  const _YearPickerSheetItem({
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  final int year;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration:
            isSelected
                ? BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
                : const BoxDecoration(color: Colors.transparent),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style:
              isSelected
                  ? const TextStyle(
                    fontFamily: _PremiumCalendarDialogState.fontMono,
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: 0.6,
                  )
                  : const TextStyle(
                    fontFamily: _PremiumCalendarDialogState.fontMono,
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0.4,
                  ),
          child: Text('$year', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        size: 20,
        color: enabled ? Colors.black : Colors.black26,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF4A4A4A) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Arbeit',
              fontSize: 13,
              color:
                  isSelected
                      ? Colors.white
                      : isDisabled
                      ? Colors.black26
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
