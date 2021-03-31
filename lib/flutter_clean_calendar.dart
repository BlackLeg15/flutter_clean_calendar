library flutter_clean_calendar;

import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart' as date;
import './simple_gesture_detector.dart';
import './calendar_tile.dart';

typedef DayBuilder(BuildContext context, DateTime day);

class Range {
  final DateTime from;
  final DateTime to;
  Range(this.from, this.to);
}

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged? onRangeSelected;
  final bool isExpandable;
  final DayBuilder? dayBuilder;
  final bool showArrows;
  final bool showTodayIcon;
  final Map? events;
  final Color? selectedColor;
  final Color? eventColor;
  final Color? eventDoneColor;
  final DateTime? initialDate;
  final bool isExpanded;
  final bool showInlineItems;
  final Color titleTextColor;
  final Color titleBackgroundColor;

  Calendar({
    this.onDateSelected,
    this.onRangeSelected,
    this.isExpandable = false,
    this.events,
    this.dayBuilder,
    this.showTodayIcon = true,
    this.showArrows = true,
    this.selectedColor,
    this.eventColor,
    this.eventDoneColor,
    this.initialDate,
    this.isExpanded = false,
    this.showInlineItems = true,
    this.titleTextColor = Colors.white,
    this.titleBackgroundColor = Colors.green,
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final calendarUtils = date.DateUtils();
  List<DateTime>? selectedMonthsDays;
  List<DateTime>? selectedWeeksDays;
  DateTime _selectedDate = DateTime.now();
  String? currentMonth;
  bool isExpanded = false;
  String? displayMonth;
  DateTime get selectedDate => _selectedDate;

  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    isExpanded = widget.isExpanded;
    selectedMonthsDays = date.DateUtils.daysInMonth(_selectedDate);
    var firstDayOfCurrentWeek = date.DateUtils.firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = date.DateUtils.lastDayOfWeek(_selectedDate);
    selectedWeeksDays = date.DateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
    displayMonth = date.DateUtils.formatMonth(_selectedDate);
  }

  Widget get nameAndIconRow {
    var todayIcon;
    var leftArrow;
    var rightArrow;

    if (widget.showArrows) {
      leftArrow = IconButton(
        onPressed: isExpanded ? previousMonth : previousWeek,
        icon: Icon(
          Icons.chevron_left,
          color: widget.titleTextColor,
        ),
      );
      rightArrow = IconButton(
        onPressed: isExpanded ? nextMonth : nextWeek,
        icon: Icon(
          Icons.chevron_right,
          color: widget.titleTextColor,
        ),
      );
    } else {
      leftArrow = Container();
      rightArrow = Container();
    }

    if (widget.showTodayIcon) {
      todayIcon = InkWell(
        child: Text('Today'),
        onTap: resetToToday,
      );
    } else {
      todayIcon = Container();
    }

    return Container(
      color: widget.titleBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leftArrow ?? Container(),
          Column(
            children: <Widget>[
              todayIcon ?? Container(),
              Text(
                displayMonth!,
                style: TextStyle(
                  fontSize: 20.0,
                  color: widget.titleTextColor,
                ),
              ),
            ],
          ),
          rightArrow ?? Container(),
        ],
      ),
    );
  }

  Widget get calendarGridView {
    return Container(
      child: SimpleGestureDetector(
        onSwipeUp: _onSwipeUp,
        onSwipeDown: _onSwipeDown,
        onSwipeLeft: _onSwipeLeft,
        onSwipeRight: _onSwipeRight,
        swipeConfig: SimpleSwipeConfig(
          verticalThreshold: 10.0,
          horizontalThreshold: 40.0,
          swipeDetectionMoment: SwipeDetectionMoment.onUpdate,
        ),
        child: Column(children: <Widget>[
          GridView.count(
            primary: false,
            shrinkWrap: true,
            crossAxisCount: 7,
            padding: EdgeInsets.only(bottom: 0.0),
            children: calendarBuilder(),
          ),
        ]),
      ),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    List<DateTime>? calendarDays = isExpanded ? selectedMonthsDays : selectedWeeksDays;

    date.DateUtils.weekdays.forEach(
      (day) {
        dayWidgets.add(
          CalendarTile(
            selectedColor: widget.selectedColor,
            eventColor: widget.eventColor,
            eventDoneColor: widget.eventDoneColor,
            events: widget.events?[day],
            isDayOfWeek: true,
            dayOfWeek: day,
            showInlineItems: widget.showInlineItems,
          ),
        );
      },
    );

    bool monthStarted = false;
    bool monthEnded = false;

    calendarDays?.forEach(
      (day) {
        if (day.hour > 0) {
          day = day.toLocal();

          day = day.subtract(new Duration(hours: day.hour));
        }

        if (monthStarted && day.day == 01) {
          monthEnded = true;
        }

        if (date.DateUtils.isFirstDayOfMonth(day)) {
          monthStarted = true;
        }

        if (this.widget.dayBuilder != null) {
          dayWidgets.add(
            CalendarTile(
              selectedColor: widget.selectedColor,
              eventColor: widget.eventColor,
              eventDoneColor: widget.eventDoneColor,
              events: widget.events?[day],
              child: this.widget.dayBuilder!(context, day),
              date: day,
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
              showInlineItems: widget.showInlineItems,
            ),
          );
        } else {
          dayWidgets.add(
            CalendarTile(
              selectedColor: widget.selectedColor,
              eventColor: widget.eventColor,
              eventDoneColor: widget.eventDoneColor,
              events: widget.events?[day],
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
              date: day,
              dateStyles: configureDateStyle(monthStarted, monthEnded),
              isSelected: date.DateUtils.isSameDay(selectedDate, day),
              inMonth: day.month == selectedDate.month,
              showInlineItems: widget.showInlineItems,
            ),
          );
        }
      },
    );
    return dayWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle dateStyles;
    final TextStyle body1Style = Theme.of(context).textTheme.bodyText2 ?? TextStyle();

    if (isExpanded) {
      final TextStyle body1StyleDisabled = body1Style.copyWith(
          color: Color.fromARGB(
        100,
        body1Style.color!.red,
        body1Style.color!.green,
        body1Style.color!.blue,
      ));

      dateStyles = monthStarted && !monthEnded ? body1Style : body1StyleDisabled;
    } else {
      dateStyles = body1Style;
    }
    return dateStyles;
  }

  Widget get expansionButtonRow {
    if (widget.isExpandable) {
      return GestureDetector(
        onTap: toggleExpanded,
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.07),
          height: 40,
          margin: EdgeInsets.only(top: 8.0),
          padding: EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 40.0),
              Text(date.DateUtils.fullDayFormat(selectedDate)),
              IconButton(
                onPressed: () {},
                iconSize: 20.0,
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                icon: isExpanded ? Icon(Icons.arrow_drop_up) : Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          nameAndIconRow,
          ExpansionCrossFade(
            collapsed: calendarGridView,
            expanded: calendarGridView,
            isExpanded: isExpanded,
          ),
          expansionButtonRow
        ],
      ),
    );
  }

  void resetToToday() {
    _selectedDate = DateTime.now();
    var firstDayOfCurrentWeek = date.DateUtils.firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = date.DateUtils.lastDayOfWeek(_selectedDate);

    setState(() {
      selectedWeeksDays = date.DateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = date.DateUtils.daysInMonth(_selectedDate);
      displayMonth = date.DateUtils.formatMonth(_selectedDate);
    });

    _launchDateSelectionCallback(_selectedDate);
  }

  void nextMonth() {
    setState(() {
      _selectedDate = date.DateUtils.nextMonth(_selectedDate);
      var firstDateOfNewMonth = date.DateUtils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = date.DateUtils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = date.DateUtils.daysInMonth(_selectedDate);
      displayMonth = date.DateUtils.formatMonth(_selectedDate);
    });
  }

  void previousMonth() {
    setState(() {
      _selectedDate = date.DateUtils.previousMonth(_selectedDate);
      var firstDateOfNewMonth = date.DateUtils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = date.DateUtils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = date.DateUtils.daysInMonth(_selectedDate);
      displayMonth = date.DateUtils.formatMonth(_selectedDate);
    });
  }

  void nextWeek() {
    setState(() {
      _selectedDate = date.DateUtils.nextWeek(_selectedDate);
      var firstDayOfCurrentWeek = date.DateUtils.firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = date.DateUtils.lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = date.DateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
      displayMonth = date.DateUtils.formatMonth(_selectedDate);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void previousWeek() {
    setState(() {
      _selectedDate = date.DateUtils.previousWeek(_selectedDate);
      var firstDayOfCurrentWeek = date.DateUtils.firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = date.DateUtils.lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = date.DateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
      displayMonth = date.DateUtils.formatMonth(_selectedDate);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    Range _rangeSelected = Range(start, end);
    if (widget.onRangeSelected != null) {
      widget.onRangeSelected!(_rangeSelected);
    }
  }

  void _onSwipeUp() {
    if (isExpanded) toggleExpanded();
  }

  void _onSwipeDown() {
    if (!isExpanded) toggleExpanded();
  }

  void _onSwipeRight() {
    if (isExpanded) {
      previousMonth();
    } else {
      previousWeek();
    }
  }

  void _onSwipeLeft() {
    if (isExpanded) {
      nextMonth();
    } else {
      nextWeek();
    }
  }

  void toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => isExpanded = !isExpanded);
    }
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    var firstDayOfCurrentWeek = date.DateUtils.firstDayOfWeek(day);
    var lastDayOfCurrentWeek = date.DateUtils.lastDayOfWeek(day);
    if (_selectedDate.month > day.month) {
      previousMonth();
    }
    if (_selectedDate.month < day.month) {
      nextMonth();
    }
    setState(() {
      _selectedDate = day;
      selectedWeeksDays = date.DateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = date.DateUtils.daysInMonth(day);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(day);
    }
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget? collapsed;
  final Widget? expanded;
  final bool isExpanded;

  ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: AnimatedCrossFade(
        firstChild: collapsed ?? Container(),
        secondChild: expanded ?? Container(),
        firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.decelerate,
        crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
