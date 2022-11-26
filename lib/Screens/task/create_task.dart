import 'package:alochat/Configs/Dbkeys.dart';
import 'package:alochat/Configs/Dbpaths.dart';
import 'package:alochat/Configs/app_constants.dart';
import 'package:alochat/Configs/optional_constants.dart';
import 'package:alochat/Models/DataModel.dart';
import 'package:alochat/Screens/Groups/AddContactsToGroup.dart';
import 'package:alochat/Screens/call_history/callhistory.dart';
import 'package:alochat/Screens/contact_screens/ContactsSelect.dart';
import 'package:alochat/Screens/task/task.dart';
import 'package:alochat/Services/Providers/AvailableContactsProvider.dart';
import 'package:alochat/Services/localization/language_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_contacts_to_task.dart';
import 'datetime_picker.dart';

class CreateTask extends StatefulWidget {
  final String currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final String taskName;
  const CreateTask({Key? key, required this.currentUserNo, required this.model, required this.prefs, this.taskName = ''}) : super(key: key);

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final _assigneeList = <Map<String, dynamic>>[];
  final _subscriberList = <Map<String, dynamic>>[];
  late final TextEditingController _taskNameController;
  late final TextEditingController _notesController;
  TaskDateTimeData? _pickedDateTime;
  _createState _state = _createState.no;

  void checkValidation() {
    if (_taskNameController.text.isNotEmpty) {
      if (_state == _createState.no) {
        setState(() {
          _state = _createState.yes;
        });
      }
    } else {
      if (_state == _createState.yes) {
        setState(() {
          _state = _createState.no;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController()..text = widget.taskName;
    _notesController = TextEditingController();
    if (widget.taskName.isNotEmpty) {
      _state = _createState.yes;
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final pickedDate = await Navigator.push<TaskDateTimeData?>(context, MaterialPageRoute(
        builder: (_) => const DateTimePicker())
    );
    if (pickedDate != null) {
      setState(() {
        _pickedDateTime = pickedDate;
      });
    }
  }

  Widget _buildDatePicker() {
    return Expanded(child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CalendarButton(
            icon: Icons.calendar_month_outlined,
            color: Colors.blue,
            caption: getTranslated(context, 'today'),
            onTap: () {
              setState(() {
                _pickedDateTime = TaskDateTimeData(
                  datetime: DateTime.now(),
                  alertTime: TaskAlertTime.whenDue
                );
              });
            },
          ),
          const SizedBox(width: 10),
          _CalendarButton(
            icon: Icons.calendar_month_outlined,
            color: Colors.green,
            caption: getTranslated(context, 'tomorrow'),
            onTap: () {
              setState(() {
                _pickedDateTime = TaskDateTimeData(
                    datetime: DateTime.now().add(const Duration(days: 1)),
                    alertTime: TaskAlertTime.whenDue
                );
              });
            },
          ),
          const SizedBox(width: 10),
          _CalendarButton(
              icon: Icons.calendar_month_outlined,
              caption: getTranslated(context, 'otherday'),
              onTap: () {
                _showDatePicker(context);
              }
          )
        ],
      ),
    ));
  }

  Widget _buildContactButton(BuildContext context, { required AvailableContactsProvider contactProvider, required String caption, required List<Map<String, dynamic>> list }) {
    return GestureDetector(
      onTap: () async {
        final List<Map<String, dynamic>>? selectedList = await Navigator.push(context, MaterialPageRoute(builder: (_) {
          return AddContactsToTask(
            currentUserNo: widget.currentUserNo,
            model: widget.model,
            biometricEnabled: false,
            prefs: widget.prefs,
            joinedUserList: list,
          );
        }));

        if (selectedList != null) {
          setState(() {
            list.addAll(selectedList);
          });
        }
      },
      child: list.isNotEmpty ?
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.0)
          ),
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: AlignmentDirectional.centerStart,
                fit: StackFit.passthrough,
                children: [
                  SizedBox(height: 30.0, width: 30.0 + (list.length * 10)),
                  ...list.map((e) {
                    return Positioned(
                        left: 10.0 * list.indexOf(e),
                        child: AvatarImage(contactProvider.getUserDoc(e[Dbkeys.phone]))
                    );
                  }).toList()
                ]
              ),
              const SizedBox(width: 5.0),
              Text(list.length > 1 ? '${list.length} people': list.first['name'] ?? list.first['nickname']),
              const SizedBox(width: 5.0),
              const Icon(Icons.chevron_right),
            ],
          ),
        )
        : Row(
          children: [
            Text(caption, style: TextStyle(color: Colors.grey[600]))
          ],
        ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      alignment: AlignmentDirectional.center,
      width: 75,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: _state == _createState.yes ? fiberchatDeepGreen : Colors.grey[400]!),
        borderRadius: BorderRadius.circular(5)
      ),
      padding: const EdgeInsets.all(3),
      child: _state == _createState.yes ?
        GestureDetector(
          onTap: () async {
            setState(() {
              _state = _createState.creating;
            });
            final result = await _createTask();
            if (result != null && mounted) {
              Navigator.pop(context, result);
            } else {
              if (mounted) {
                setState(() {
                  _state = _createState.yes;
                });
              }
            }
          },
          child: Text(getTranslated(context, 'create'), style: TextStyle(color: fiberchatDeepGreen, fontWeight: FontWeight.bold)),
        )
        : _state == _createState.creating ?
          Text(getTranslated(context, 'creating'), style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold))
          : Text(getTranslated(context, 'create'), style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
    );
  }

  Future<Task?> _createTask() async {
    try {
      var task = Task.fromMap({
        'name': _taskNameController.text,
        'notes': _notesController.text,
        'createdBy': widget.currentUserNo,
        'assignees': _assigneeList.map((e) => e[Dbkeys.phone]).toList(),
        'dueDate': _pickedDateTime?.datetime.millisecondsSinceEpoch,
        'subscribers': _subscriberList.map((e) => e[Dbkeys.phone]).toList(),
        'comments': null,
        'completedDate': null
      });
      final result = await FirebaseFirestore
          .instance.collection(DbPaths.collectiontasks)
          .add(task.toMap());
      task.id = result.id;
      return task;
    } catch(ex) {
      debugPrint(ex.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: alochatMain,
      ),
      body: Consumer<AvailableContactsProvider>(
        builder: (context, contactsProvider, child) => SizedBox(
          height: double.infinity,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Theme(
                data: ThemeData(
                    textTheme: const TextTheme(
                        bodyText1: TextStyle(
                            color: Colors.grey
                        )
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _taskNameController,
                          onChanged: (text) {
                            checkValidation();
                          },
                          decoration: InputDecoration(
                            hintText: getTranslated(context, 'task_addtask'),
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold
                            ),
                            border: InputBorder.none
                          )
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _notesController,
                          onChanged: (text) {
                            checkValidation();
                          },
                          decoration: InputDecoration(
                              hintText: getTranslated(context, 'task_addnotes'),
                              hintStyle: TextStyle(
                                  color: Colors.grey[600]
                              ),
                              border: InputBorder.none
                          )
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            _buildContactButton(context,
                              contactProvider: contactsProvider,
                              list: _assigneeList,
                              caption: getTranslated(context, 'task_addassignee'),
                            )
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            _pickedDateTime != null ?
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5.0)
                              ),
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showDatePicker(context);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Due: ${DateFormat("dd MMM yy, HH:mm").format(_pickedDateTime!.datetime)}'),
                                        const SizedBox(width: 5.0),
                                        const Icon(Icons.notifications_none),
                                        const SizedBox(width: 5.0),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _pickedDateTime = null;
                                      });
                                    },
                                    child: const Icon(Icons.close),
                                  )
                                ],
                              ),
                            )
                                : _buildDatePicker(),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Icon(Icons.add_alert_outlined, color: Colors.grey[600]),
                            const SizedBox(width: 10),
                            _buildContactButton(context,
                              contactProvider: contactsProvider,
                              list: _subscriberList,
                              caption: getTranslated(context, 'task_addsubscribers'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.all(15),
                  color: Colors.grey[200],
                  child: _buildSubmitButton(),
                )
              )
            ],
          ),
        ),
      )
    );
  }
}

class _CalendarButton extends StatelessWidget {
  final IconData icon;
  final String caption;
  final Color color;
  final VoidCallback onTap;
  const _CalendarButton({Key? key, this.color = Colors.black, required this.icon, required this.caption, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: AlignmentDirectional.bottomEnd,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey[200]
        ),
        child: Row(
          children: [
            Icon(icon, color: color,),
            const SizedBox(width: 10),
            Text(caption)
          ],
        ),
      ),
    );
  }
}

enum _createState {
  no,
  yes,
  creating
}