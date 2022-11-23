import 'package:alochat/Configs/Dbkeys.dart';
import 'package:alochat/Configs/Dbpaths.dart';
import 'package:alochat/Screens/call_history/callhistory.dart';
import 'package:alochat/Services/localization/language_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  final String currentUserNo;
  const TaskPage({Key? key, required this.currentUserNo}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  _Filter _currentFilter = _Filter.ongoing;
  bool _ready = false;

  late final List<Task> _allTasks;
  late final List<Task> _completedTaskList;
  late final List<Task> _nonCompletedTaskList;
  late final List<Task> _scheduledTaskList;
  late final List<Task> _ongoingTaskList;
  late final List<Task> _followingTaskList;
  late final List<Task> _receivedTaskList;
  late final List<Task> _assignedTaskList;
  late final List<Task> _overdueTaskList;
  late final List<Task> _lessThanWeekTaskList;
  late final List<Task> _unscheduledTaskList;

  Future<void> loadTask() async {
    await FirebaseFirestore.instance.collection(DbPaths.collectiontasks).orderBy(Dbkeys.taskduedate).get().then((docs) {
      _allTasks = docs.docs.map((e) => Task.fromMap(e.data())).toList();
      _completedTaskList = _allTasks.where((e) => e.completeDate != null).toList();
      _nonCompletedTaskList = _allTasks.where((e) => e.completeDate == null).toList();
      _ongoingTaskList =
          _nonCompletedTaskList.where((e) => e.dueDate! > DateTime.now().millisecondsSinceEpoch).toList();
      _followingTaskList =
          _nonCompletedTaskList.where((e) => e.subscribers.any((s) => s['uid'] == widget.currentUserNo)).toList();
      _receivedTaskList =
          _nonCompletedTaskList.where((e) => e.assignees.any((s) => s['uid'] == widget.currentUserNo)).toList();
      _assignedTaskList = _nonCompletedTaskList.where((e) => e.createBy == widget.currentUserNo).toList();

      _scheduledTaskList = _nonCompletedTaskList.where((e) => e.dueDate != null).toList();
      _overdueTaskList = _scheduledTaskList.where((e) => e.dueDate! <= DateTime.now().millisecondsSinceEpoch).toList();
      _lessThanWeekTaskList = _scheduledTaskList
          .where((e) => DateTime.fromMillisecondsSinceEpoch(e.dueDate!).day < DateTime.now().day + 7)
          .toList();
      _unscheduledTaskList = _nonCompletedTaskList.where((e) => e.dueDate == null).toList();
    });
  }

  Future<void> initialize() async {
    await loadTask();
  }

  Widget _buildFilterBox({required String caption, required _Filter filter, required int? quantity}) {
    return TextButton(
      onPressed: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Row(
        children: [Text(caption), quantity != null && quantity != 0 ? Text(quantity.toString()) : Container()],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    late final bool visible;
    switch (_currentFilter) {
      case _Filter.complete:
        visible = task.completeDate != null;
        break;
      case _Filter.ongoing:
        visible = task.completeDate == null;
        break;
      case _Filter.received:
        visible = task.assignees.any((e) => e['uid'] == widget.currentUserNo);
        break;
      case _Filter.assigned:
        visible = task.createBy == widget.currentUserNo;
        break;
      case _Filter.following:
        visible = task.subscribers.any((e) => e['uid'] == widget.currentUserNo);
        break;
      default:
        break;
    }

    final color = task.dueDate! > DateTime.now().millisecondsSinceEpoch ? Colors.red : Colors.black;
    return Visibility(
      visible: visible,
      child: Row(
        children: [
          Checkbox(value: false, onChanged: (_) {}),
          Column(
            children: [
              task.completeDate != null
                  ? Text(task.name, style: const TextStyle(decoration: TextDecoration.lineThrough))
                  : Text(task.name),
              Wrap(
                children: task.assignees.map((e) => customCircleAvatarGroup(url: '', radius: 22)).toList(),
              ),
              task.completeDate != null
                  ? Row(children: [
                      Text(getTranslated(context, 'task_completedon')),
                      Text(DateTime.fromMillisecondsSinceEpoch(task.completeDate!).toString())
                    ])
                  : task.dueDate != null
                      ? Row(children: [
                          Icon(Icons.calendar_today, color: color),
                          Text(
                            task.dueDate.toString(),
                            style: TextStyle(color: color),
                          ),
                          Icon(Icons.notifications_none, color: color)
                        ])
                      : Container()
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTaskCard({required String title, required List<Task> taskList, bool isOverdueList = false}) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Text(title),
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
                      : Text(taskList.length.toString())
                  : Container()
            ],
          ),
          Column(
            children: taskList.map((e) => _buildTaskItem(e)).toList(),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initialize().then((_) {
      setState(() {
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _ready
            ? Column(children: [
                Wrap(
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTaskCard(
                            isOverdueList: true,
                            title: getTranslated(context, 'task_overdue'),
                            taskList: _overdueTaskList),
                        _buildTaskCard(
                            title: getTranslated(context, 'task_next7days'), taskList: _lessThanWeekTaskList),
                        _buildTaskCard(title: getTranslated(context, 'task_later'), taskList: _unscheduledTaskList)
                      ],
                    ),
                  ),
                )
              ])
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class Task {
  final String name;
  final String createBy;
  final List<Map<String, dynamic>> assignees;
  final int? dueDate;
  final List<Map<String, dynamic>> subscribers;
  final List<Map<String, dynamic>> comments;
  final int? completeDate;

  const Task(
      {required this.name,
      required this.createBy,
      required this.assignees,
      required this.dueDate,
      required this.subscribers,
      required this.comments,
      required this.completeDate});

  factory Task.fromMap(Map<String, dynamic> map) => Task(
      name: map['name'],
      createBy: map['createBy'],
      assignees: map['assignees'],
      dueDate: map['dueDate'],
      subscribers: map['subscribers'],
      comments: map['comments'],
      completeDate: map['completeDate']);
}

enum _Filter { ongoing, received, assigned, following, complete }
