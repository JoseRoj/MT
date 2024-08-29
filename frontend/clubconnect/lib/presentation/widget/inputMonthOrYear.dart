import 'package:clubconnect/globales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputFechaWidget extends StatelessWidget {
  final double width;
  dynamic date;
  final String? type;
  final String value;
  final Function(int)? onMonthYearChanged;
  final Function(DateTime, String)? updateDate;

  InputFechaWidget({
    Key? key,
    required this.width,
    this.date,
    this.type,
    required this.value,
    this.onMonthYearChanged,
    this.updateDate,
  }) : super(key: key);

  List<int> years = List.generate(3, (index) => DateTime.now().year + index);

  Widget cuppertino() {
    switch (value) {
      case "month":
        return CupertinoPicker(
          magnification: 1.22,
          squeeze: 1.2,
          useMagnifier: true,
          itemExtent: 30,
          scrollController: FixedExtentScrollController(
            initialItem: date!.month - 1,
          ),
          onSelectedItemChanged: (int selectedItem) {
            /*Meses selectedMonth = Months[selectedItem];
                      MonthYear updatedMonthYear = MonthYear(
                        selectedMonth.value,
                        selectedMonthYear.year,
                        selectedMonth.mes,
                      );*/
            onMonthYearChanged!(selectedItem);
          },
          children: List<Widget>.generate(Months.length, (int index) {
            return Center(child: Text(Months[index].mes));
          }),
        );
      case "year":
        return CupertinoPicker(
          magnification: 1.22,
          squeeze: 1.2,
          useMagnifier: true,
          itemExtent: 30,
          scrollController: FixedExtentScrollController(
            initialItem: date!.year - DateTime.now().year,
          ),
          onSelectedItemChanged: (int selectedItem) {
            /*MonthYear updatedMonthYear = MonthYear(
                        date.month,
                        years[selectedItem],
                        date.month,
                      );*/
            onMonthYearChanged!(selectedItem);
          },
          children: List<Widget>.generate(years.length, (int index) {
            return Center(
              child: Text(years[index].toString()),
            );
          }),
        );
      case "date":
        return CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          backgroundColor: Colors.white,
          initialDateTime: date ?? DateTime.now(),
          onDateTimeChanged: (DateTime value) {
            updateDate!(value, type!);
          },
        );

      default:
        return Container();
    }
  }

  Widget textDate() {
    switch (value) {
      case "month":
        return Text(
          date!.nameMonth,
          textAlign: TextAlign.center,
        );
      case "year":
        return Text(
          date.year.toString(),
          textAlign: TextAlign.center,
        );
      case "date":
        return Text(
          date != null ? DateFormat('dd / MM / yyyy').format(date!) : "",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        );
      default:
        return Text(
          "",
          textAlign: TextAlign.center,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              height: 200,
              child: cuppertino()),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: textDate(),
      ),
    );
  }
}
