import 'package:alochat/Configs/app_constants.dart';
import 'package:alochat/Services/helpers/size.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

enum TaskAlertTime {
  noAlert,
  whenDue,
  fiveMinutes,
  fifteenMinutes,
  thirtyMinutes,
  anHour,
  twoHours,
  aDay,
  twoDays,
  aWeek
}

const taskAlertTimeList = <TaskAlertTime, String>{
  TaskAlertTime.noAlert: 'No alert',
  TaskAlertTime.whenDue: 'When it`s due',
  TaskAlertTime.fiveMinutes: '5 minutes before',
  TaskAlertTime.fifteenMinutes: '15 minutes before',
  TaskAlertTime.thirtyMinutes: '30 minutes before',
  TaskAlertTime.anHour: '1 hour before',
  TaskAlertTime.twoHours: '2 hours before',
  TaskAlertTime.aDay: '1 day before',
  TaskAlertTime.twoDays: '2 days before',
  TaskAlertTime.aWeek: '1 week before',
};

class TaskDateTimeData {
  final DateTime datetime;
  final TaskAlertTime alertTime;

  const TaskDateTimeData({
    required this.datetime,
    required this.alertTime,
  });
}

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({Key? key}) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime _pickedDate = DateTime.now();
  TimeOfDay _pickedTime = TimeOfDay.now();
  bool _dueTime = true;
  bool _showDueTimePicker = false;
  bool _showAlertTimePicker = false;
  TaskAlertTime _alertTime = TaskAlertTime.whenDue;

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      padding: const EdgeInsets.only(top: 6.0),
      color: cupertino.CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: cupertino.CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: alochatMain,
        actions: [
          GestureDetector(
            onTap: () {
              final pickDateTime = DateTime(
                _pickedDate.year,
                _pickedDate.month,
                _pickedDate.day,
                _dueTime ? _pickedTime.hour : 0,
                  _dueTime ? _pickedTime.minute : 0
              );
              Navigator.pop(context, TaskDateTimeData(datetime: pickDateTime, alertTime: _alertTime));
            },
            child: Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ))
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SfDateRangePicker(
              headerHeight: 20.0,
              minDate: DateTime.now(),
              onSelectionChanged: (selectedDate) {
                setState(() {
                  _pickedDate = selectedDate.value;
                });
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Due time'),
                  SizedBox(
                    height: 20.0,
                    child: Switch(
                      value: _dueTime,
                      activeColor: alochatMain,
                      onChanged: (toggle) {
                        setState(() {
                          _dueTime = toggle;
                        });
                      }
                    ),
                  )
                ],
              ),
            ),
            if (_dueTime)...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Due'),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAlertTimePicker = false;
                          _showDueTimePicker = !_showDueTimePicker;
                        });
                      },
                      child: Text('${_pickedTime.hour}:${_pickedTime.minute<10?"0":""}${_pickedTime.minute}',
                        style: TextStyle(color: _showDueTimePicker ? alochatMain : Colors.black),
                      )
                    )
                  ],
                ),
              ),
              if (_showDueTimePicker)...[
                const Divider(),
                Expanded(
                  child: _buildBottomPicker(
                      cupertino.CupertinoDatePicker(
                        use24hFormat: true,
                        mode: cupertino.CupertinoDatePickerMode.time,
                        onDateTimeChanged: (datetime) {
                          setState(() {
                            _pickedTime = TimeOfDay(
                                hour: datetime.hour,
                                minute: datetime.minute
                            );
                          });
                        },
                      )
                  ),
                )
              ],
            ],
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Alert time'),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _showDueTimePicker = false;
                          _showAlertTimePicker = !_showAlertTimePicker;
                        });
                      },
                    child: Text(taskAlertTimeList[_alertTime]!,
                      style: TextStyle(color: _showAlertTimePicker ? alochatMain : Colors.black),
                    )
                  )
                ],
              ),
            ),
            if (_showAlertTimePicker)...[
              const Divider(),
              Expanded(
                child: _buildBottomPicker(
                    cupertino.CupertinoPicker(
                        magnification: 1.5,
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _alertTime = TaskAlertTime.values[index];
                          });
                        },
                        children: taskAlertTimeList.entries.map((e) => Center(
                          child: Text(e.value, style: TextStyle(fontSize: 14)))
                        ).toList()
                    )
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
