import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';

class CalendarTile extends StatelessWidget {
  final VoidCallback onDateSelected;
  final DateTime date;
  final String dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final bool inMonth;
  final List<Map> events;
  final TextStyle dayOfWeekStyles;
  final TextStyle dateStyles;
  final Widget child;
  final Color selectedColor;
  final Color eventColor;
  final Color eventDoneColor;
  final bool showInlineItems;

  CalendarTile({
    this.onDateSelected,
    this.date,
    this.child,
    this.dateStyles,
    this.dayOfWeek,
    this.dayOfWeekStyles,
    this.isDayOfWeek = false,
    this.isSelected = false,
    this.inMonth = true,
    this.events,
    this.selectedColor,
    this.eventColor,
    this.eventDoneColor,
    this.showInlineItems = true,
  });

  Widget renderDateOrDayOfWeek(BuildContext context) {
    var eventCount = 0;
    if (isDayOfWeek) {
      return InkWell(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            dayOfWeek,
            style: dayOfWeekStyles,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: onDateSelected,
        child: Container(
          margin: EdgeInsets.all(0.5),
          decoration: isSelected
              ? BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                      style: BorderStyle.solid,
                      width: 2,
                      color: selectedColor != null
                          ? selectedColor
                          : Theme.of(context).primaryColor),
                  color: events == null
                      ? Colors.grey[200]
                      : events.any((item) => item['isDone'])
                          ? Colors.green[200]
                          : Colors.red[200],
                )
              : BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: events == null
                      ? Colors.grey[200]
                      : events.any((item) => item['isDone'])
                          ? Colors.green[200]
                          : Colors.red[200],
                ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Utils.formatDay(date).toString(),
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: inMonth ? Colors.black : Colors.grey),
              ),
              showInlineItems && events != null && events.length > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((event) {
                        eventCount++;
                        if (eventCount > 3) return Container();
                        return Container(
                          margin:
                              EdgeInsets.only(left: 2.0, right: 2.0, top: 3.0),
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: event['isDone']
                                ? eventDoneColor ??
                                    Theme.of(context).primaryColor
                                : eventColor ?? Theme.of(context).accentColor,
                          ),
                        );
                      }).toList())
                  : Container(),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return InkWell(
        child: child,
        onTap: onDateSelected,
      );
    }
    return Container(
      child: renderDateOrDayOfWeek(context),
    );
  }
}
