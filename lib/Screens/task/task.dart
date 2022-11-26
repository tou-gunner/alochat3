import 'package:alochat/Configs/Dbkeys.dart';
import 'package:alochat/Configs/Dbpaths.dart';
import 'package:alochat/Configs/app_constants.dart';
import 'package:alochat/Models/DataModel.dart';
import 'package:alochat/Screens/call_history/callhistory.dart';
import 'package:alochat/Screens/task/create_task.dart';
import 'package:alochat/Services/Providers/AvailableContactsProvider.dart';
import 'package:alochat/Services/localization/language_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskPage extends StatefulWidget {
  final String currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  const TaskPage({Key? key, required this.currentUserNo, required this.model, required this.prefs}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  _Filter _currentFilter = _Filter.ongoing;
  AvailableContactsProvider? _availableContacts;
  bool _ready = false;

  late List<Task> _allTasks;
  late List<Task> _completedTaskList;
  late List<Task> _nonCompletedTaskList;
  late List<Task> _scheduledTaskList;
  late List<Task> _ongoingTaskList;
  late List<Task> _followingTaskList;
  late List<Task> _receivedTaskList;
  late List<Task> _assignedTaskList;
  late List<Task> _overdueTaskList;
  late List<Task> _lessThanWeekTaskList;
  late List<Task> _unscheduledTaskList;
  final _completedTaskCardList = <DateTime, List<Task>>{};

  Future<void> loadTask() async {
    await FirebaseFirestore.instance.collection(DbPaths.collectiontasks).orderBy(Dbkeys.taskduedate).get().then((docs) {
      _allTasks = [];
      for (final data in docs.docs ) {
        var task = Task.fromMap(data.data());
        task.id = data.reference.id;
        _allTasks.add(task);
      }
    });
  }

  Future<void> initialize() async {
    await loadTask();
  }

  Widget _buildFilterBox({required String caption, required _Filter filter, required int? quantity}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _currentFilter == filter ? fiberchatDeepGreen : Colors.grey[200]
        ),
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(caption,
              style: TextStyle(
                color: _currentFilter == filter ? Colors.white : Colors.black
              ),
            ),
            const SizedBox(width: 5.0),
            quantity != null && quantity != 0 ?
              Text(quantity.toString(),
                style: TextStyle(
                    color: _currentFilter == filter ? Colors.white : Colors.black
                )
              ) : Container()],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, bool createBottomLine) {
    late final bool visible;
    switch (_currentFilter) {
      case _Filter.complete:
        visible = task.completedDate != null;
        break;
      case _Filter.ongoing:
        visible = task.completedDate == null;
        break;
      case _Filter.received:
        visible = task.assignees.any((e) => e == widget.currentUserNo);
        break;
      case _Filter.assigned:
        visible = task.createdBy == widget.currentUserNo;
        break;
      case _Filter.following:
        visible = task.subscribers.any((e) => e == widget.currentUserNo);
        break;
      default:
        break;
    }

    final color = task.dueDate != null && task.dueDate! < DateTime.now().millisecondsSinceEpoch ?
      Colors.red : Colors.grey[400];
    return Visibility(
      visible: visible,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.completedDate != null,
            onChanged: task.completedDate == null ? (_) async {
              task.completedDate = DateTime.now().millisecondsSinceEpoch;
              await FirebaseFirestore
                  .instance.collection(DbPaths.collectiontasks)
                  .doc(task.id!)
                  .update(task.toMap());
              if (mounted) {
                setState(() {

                });
              }
            } : null
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              task.completedDate != null
                  ? Text(task.name, style: TextStyle(color: Colors.grey[200], decoration: TextDecoration.lineThrough))
                  : Text(task.name),
              const SizedBox(height: 10.0),
              Wrap(
                children: task.assignees.map((e) =>
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: AvatarImage(_availableContacts!.getUserDoc(e)),
                    )).toList(),
              ),
              const SizedBox(height: 10.0),
              task.completedDate != null
                  ? Row(children: [
                      Text(getTranslated(context, 'task_completedon'), style: TextStyle(color: Colors.grey[200])),
                      const SizedBox(width: 5.0),
                      Text(DateFormat('dd MMM yy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(task.completedDate!)),
                        style: TextStyle(color: Colors.grey[200])
                      )
                    ])
                  : task.dueDate != null
                      ? Row(children: [
                          Icon(Icons.calendar_today, color: color),
                          const SizedBox(width: 5.0),
                          Text(
                            DateFormat('dd MMM yy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(task.dueDate!)),
                            style: TextStyle(color: color),
                          ),
                          const SizedBox(width: 5.0),
                          Icon(Icons.notifications_none, color: color)
                        ])
                      : Container(),
              const SizedBox(height: 10.0),
              createBottomLine ? const Divider() : Container()
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTaskCard({required String title, required List<Task> taskList, bool isOverdueList = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Row(
              children: [
                Text(title),
                const SizedBox(width: 10.0),
                taskList.isNotEmpty
                    ? isOverdueList
                        ? Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[400],
                            ),
                            child: Text(taskList.length.toString(),
                                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                          )
                        : Text(taskList.length.toString(), style: TextStyle(color: Colors.grey[400]))
                    : Container()
              ],
            ),
            Column(
              children: taskList.map((e) => _buildTaskItem(e, taskList.indexOf(e) < taskList.length - 1)).toList(),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _availableContacts = Provider.of<AvailableContactsProvider>(context, listen: false);
    });
    initialize().then((_) {
      setState(() {
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      _completedTaskList = _allTasks.where((e) => e.completedDate != null).toList();
      _nonCompletedTaskList = _allTasks.where((e) => e.completedDate == null).toList();
      _ongoingTaskList =
          _nonCompletedTaskList.where((e) => e.completedDate == null).toList();
      _followingTaskList =
          _nonCompletedTaskList.where((e) => e.subscribers.any((s) => s == widget.currentUserNo)).toList();
      _receivedTaskList =
          _nonCompletedTaskList.where((e) => e.assignees.any((s) => s == widget.currentUserNo)).toList();
      _assignedTaskList = _nonCompletedTaskList.where((e) => e.createdBy == widget.currentUserNo).toList();

      _scheduledTaskList = _nonCompletedTaskList.where((e) => e.dueDate != null).toList();
      _overdueTaskList = _scheduledTaskList.where((e) => e.dueDate! < DateTime.now().millisecondsSinceEpoch).toList();
      _lessThanWeekTaskList = _scheduledTaskList
          .where((e) =>
            e.dueDate! >= DateTime.now().millisecondsSinceEpoch
            && DateTime.fromMillisecondsSinceEpoch(e.dueDate!).day < DateTime.now().day + 7)
          .toList();
      _unscheduledTaskList = _nonCompletedTaskList.where((e) =>
        e.dueDate == null
        || DateTime.fromMillisecondsSinceEpoch(e.dueDate!).day >= DateTime.now().day + 7).toList();

      _completedTaskCardList.clear();
      for (var task in _completedTaskList) {
        final date = DateTime.fromMillisecondsSinceEpoch(task.completedDate!);
        final month = date.month;
        final year = date.year;
        var monthCard = _completedTaskCardList.keys.firstWhereOrNull((d) => d.year == year && d.month == month);
        if (monthCard == null) {
          monthCard = DateTime(date.year, date.month);
          _completedTaskCardList[monthCard] = [];
        }
        _completedTaskCardList[monthCard]!.add(task);
      }
    }

    return SafeArea(
      child: Scaffold(
        body: _ready
            ? Consumer<AvailableContactsProvider>(
              builder: (context, contactsProvider, child) =>  Column(children: [
                Container(
                  width: double.infinity,
                  color: alochatMain,
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Wrap(
                    children: [
                      _buildFilterBox(
                        filter: _Filter.ongoing,
                        caption: getTranslated(context, 'task_ongoing'),
                        quantity: _ongoingTaskList.length,
                      ),
                      _buildFilterBox(
                        filter: _Filter.received,
                        caption: getTranslated(context, 'task_received'),
                        quantity: _receivedTaskList.length,
                      ),
                      _buildFilterBox(
                        filter: _Filter.assigned,
                        caption: getTranslated(context, 'task_assigned'),
                        quantity: _assignedTaskList.length,
                      ),
                      _buildFilterBox(
                        filter: _Filter.following,
                        caption: getTranslated(context, 'task_following'),
                        quantity: _followingTaskList.length,
                      ),
                      _buildFilterBox(
                        filter: _Filter.complete,
                        caption: getTranslated(context, 'task_completed'),
                        quantity: _completedTaskList.length,
                      )
                    ],
                  ),
                ),
                _currentFilter == _Filter.complete ?
                  Expanded(
                      child: _completedTaskList.isNotEmpty ? SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _completedTaskCardList.entries.map((e) => _buildTaskCard(
                            title: DateFormat("MMMM").format(e.key),
                            taskList: e.value
                          )).toList(),
                        ),
                      )
                          : Center(child: Text(getTranslated(context, 'task_nocompletedtask')))
                  )
                  : Expanded(
                    child: _nonCompletedTaskList.isNotEmpty ? SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _overdueTaskList.isNotEmpty ? _buildTaskCard(
                              isOverdueList: true,
                              title: getTranslated(context, 'task_overdue'),
                              taskList: _overdueTaskList)
                          : Container(),
                          _lessThanWeekTaskList.isNotEmpty ? _buildTaskCard(
                              title: getTranslated(context, 'task_next7days'), taskList: _lessThanWeekTaskList)
                          : Container(),
                          _unscheduledTaskList.isNotEmpty ? _buildTaskCard(title: getTranslated(context, 'task_later'), taskList: _unscheduledTaskList)
                          : Container(),
                        ],
                      ),
                    )
                    : Center(child: Text(getTranslated(context, 'task_notask'))),
                  )
              ])
            )
            : const Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: alochatMain,
          onPressed: () async {
            final result = await Navigator.push<Task?>(context, MaterialPageRoute(
              builder: (_) => CreateTask(
                currentUserNo: widget.currentUserNo,
                model: widget.model,
                prefs: widget.prefs,
              ))
            );
            if (result != null) {
              if (mounted) {
                setState(() {
                  _allTasks.add(result);
                });
              }
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}



class AvatarImage extends StatefulWidget {
  final Future<Map<String, dynamic>> userDoc;
  const AvatarImage(this.userDoc, {Key? key}) : super(key: key);

  @override
  State<AvatarImage> createState() => _AvatarImageState();
}

class _AvatarImageState extends State<AvatarImage> {
  String? _url;

  @override
  void initState() {
    super.initState();
    widget.userDoc.then((user) {
      if (mounted) {
        setState(() {
          _url = user[Dbkeys.photoUrl];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return customCircleAvatar(
      url: _url,
      radius: 15.0,
    );
  }
}

class Task {
  String? id;
  String name;
  String notes;
  String createdBy;
  List<String> assignees;
  int? dueDate;
  List<String> subscribers;
  List<Map<String, dynamic>>? comments;
  int? completedDate;

  Task(
      {required this.name,
      required this.notes,
      required this.createdBy,
      required this.assignees,
      required this.dueDate,
      required this.subscribers,
      required this.comments,
      required this.completedDate});

  factory Task.fromMap(Map<String, dynamic> map) => Task(
      name: map['name'],
      notes: map['notes'],
      createdBy: map['createdBy'],
      assignees: List<String>.from(map['assignees']),
      dueDate: map['dueDate'],
      subscribers: List<String>.from(map['subscribers']),
      comments: map['comments'],
      completedDate: map['completedDate']);

  Map<String, dynamic> toMap() => {
    'name': name,
    'notes': notes,
    'createdBy': createdBy,
    'assignees': assignees,
    'dueDate': dueDate,
    'subscribers': subscribers,
    'comments': comments,
    'completedDate': completedDate
  };
}

enum _Filter { ongoing, received, assigned, following, complete }
