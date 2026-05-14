class UserModel {
  final String uid;
  final String name;
  final Map<String, num> goals;

  UserModel({
    required this.uid,
    required this.name,
    required this.goals,
  });

  factory UserModel.defaultUser(String uid, String name) {
    return UserModel(
      uid: uid,
      name: name,
      goals: {
        'steps': 10000,
        'water': 3.0,
        'calories': 2000,
        'sleep': 8,
      },
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      goals: Map<String, num>.from(data['goals'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'goals': goals,
    };
  }
}