import 'package:flutter/material.dart';
import 'package:task_manager/models/task_model.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final String status;
  final Function(String) onAction;

  const TaskItem({
    super.key,
    required this.task,
    required this.status,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.status == 'Done' ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.blueAccent),
                const SizedBox(width: 4),
                Text(
                  task.date.toString().split(' ')[0],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: onAction,
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'Edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit Task'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            if (status != 'To Do') const PopupMenuItem(value: 'To Do', child: Text('Move to To Do')),
            if (status != 'In Progress') const PopupMenuItem(value: 'In Progress', child: Text('Move to In Progress')),
            if (status != 'Done') const PopupMenuItem(value: 'Done', child: Text('Move to Done')),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'Delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Task', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}