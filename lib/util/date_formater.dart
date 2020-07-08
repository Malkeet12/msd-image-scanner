import 'package:intl/intl.dart';

/*
usage
var startDate = DateFormatter.formatWithTime(date);
date in seconds

*/

class DateFormatter {
  static formatWithTime(String epoch) {
    DateTime dateObj =
        DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000);
    var date = DateFormat('dd MMM, yy').add_jm().format(dateObj);
    return date;
  }

  static isPast(String epoch) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000)
            .compareTo(DateTime.now()) <
        0;
  }

  static isToday(String epoch) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000)
            .difference(DateTime.now())
            .inDays ==
        0;
  }

  static getTime(String epoch) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(int.parse(epoch)).toLocal();
    String hour =
        date.hour > 12 ? (date.hour - 12).toString() : date.hour.toString();
    if (hour.length == 1) {
      hour = '0' + hour;
    }
    String minutes = date.minute.toString();
    if (minutes.length == 1) {
      minutes = '0' + minutes;
    }
    String amPm = date.hour >= 12 ? 'PM' : 'AM';
    return hour + ':' + minutes + ' ' + amPm;
  }

  static readableDelta(epoch) {
    String formattedDelta = '';
    epoch = (epoch / 1000).round().toString();
    int delta = DateTime.now()
        .difference(
            DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000))
        .inSeconds;

    String type;
    int n;

    if (delta == 0)
      type = 'now';
    else if (delta > 0 && delta < 60) {
      type = 'now';
      n = delta;
    } else if (delta >= 60 && delta < 3600) {
      type = 'minute';
      n = (delta / 60).round();
    } else if (delta >= 3600 && delta < 3600 * 24) {
      type = 'hour';
      n = (delta / 3600).round();
    } else if (delta >= 3600 * 24) {
      type = 'day';
      n = (delta / (3600 * 24)).round();
    }

    if (n != 1 && type != 'now' && type != null) type += 's'; // handle plural
    if (type == 'now') return 'Last modified few seconds ago';
    formattedDelta = "Last modified $n $type ago ";
    return formattedDelta;
  }
}
