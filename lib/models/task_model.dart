class TaskModel {
  String? id;
  String title;
  String description;
  DateTime date;
  String status;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.status = 'To Do',
  });

  // Converts our Dart object into JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  // Converts Firestore JSON back into our Dart object
  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      status: map['status'] ?? 'To Do',
    );
  }
}